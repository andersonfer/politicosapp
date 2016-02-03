class Candidato



  include Mongoid::Document

  field :numero,        :type=>String, :default=>nil
  field :nome_civil,        :type=>String, :default=>nil
  field :nome_parlamentar,        :type=>String, :default=>nil
  field :nome_civil_sem_acentos,        :type=>String, :default=>nil
  field :partido,        :type=>String, :default=>nil
  field :estado,        :type=>String, :default=>nil
  field :cargo,        :type=>String, :default=>nil
  field :html,        :type=>String, :default=>nil
  field :cnpj,        :type=>String, :default=>nil
  field :sequencial,        :type=>String, :default=>nil

  validates_uniqueness_of :nome_parlamentar, :cnpj

  def self.carrega_dados_deputados_federais

    caminho = File.absolute_path("deputados_federais.xls")

    arq = Roo::Spreadsheet.open(caminho)

    arq.sheet(0).each_with_index do |linha,index|
      if index != 0
        c = Candidato.find_or_create_by(:nome_parlamentar=>linha[0])
        c.update(:partido=>linha[1],
                :estado=>linha[2],
                :nome_civil=> linha[17],
                :nome_civil_sem_acentos=>I18n.transliterate(linha[17]),
                :cargo=>'deputado federal'
                )

        print '.'
      end

    end

  end

  def self.pega_o_html_do_candidato_e_salva seqCandidato

    url = "http://inter01.tse.jus.br/spceweb.consulta.receitasdespesas2014/resumoReceitasByCandidato.action"

    params = { "sqCandidato" => seqCandidato,
              "sgUe" => "",
              "sgUfMunicipio"=> "",
              "filtro" => "S",
              "tipoEntrega" => "0"}

    response = Net::HTTP.post_form(URI.parse(url),params)

    html = response.body

    pagina = Nokogiri::HTML(html)

    numero = pagina.css('.clsCabecalhoCol00')[0]['value']
    nome_civil = pagina.css('.clsCabecalhoCol00')[1]['value']
    nome_civil_sem_acentos = I18n.transliterate(nome_civil)
    estado = pagina.css('.clsCabecalhoCol00')[2]['value']
    partido = pagina.css('.clsCabecalhoCol00')[3]['value']

    if pagina.css('.linhaPreenchida').size > 0  #quer dizer que o candidato recebeu alguma doação
      cnpj = pagina.css('.linhaPreenchida').children[21].children.text.strip.gsub(/[\.\(\/-]/, '')
    end



    c = Candidato.find_or_create_by(:nome_civil_sem_acentos=>nome_civil_sem_acentos)
    if c.update(:numero=>numero,
            :nome_civil=>nome_civil,
            :estado=>estado,
            :partido=>partido,
            :cnpj=>cnpj,
            :html=>html,
            :sequencial=> seqCandidato
      )
        puts " #{c.nome_civil} - #{c.numero} - #{c.sequencial} atualizado com sucesso"
    end


  end




end
