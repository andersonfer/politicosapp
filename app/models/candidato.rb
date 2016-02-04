class Candidato

  include Mongoid::Document

  SIGLAS_ESTADOS = ["AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"]

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


  def self.carrega_dados_deputados_federais

    caminho = File.absolute_path("deputados_federais.xls")

    arq = Roo::Spreadsheet.open(caminho)

    arq.sheet(0).each_with_index do |linha,index|
      if index != 0
        nome_civil_sem_acentos = I18n.transliterate(linha[17].strip).upcase
        begin
          c = Candidato.find_by(:nome_civil_sem_acentos=>nome_civil_sem_acentos)
          c.update(:nome_parlamentar=>linha[0].strip,
                  :cargo=>"DEPUTADO FEDERAL")

        rescue

          puts "---------------- #{nome_civil_sem_acentos} ------------- não encontrado"
        end

      end

    end
    return
  end

  def self.migra_nomes
    nomes_site_tse = [ "ATILA SIDNEY LINS DE ALBUQUERQUE",
                        "BRUNIELE FERREIRA DA SILVA",
                        "GIVALDO DE SÁ GOUVEIA CARIMBÃO",
                        "ANTONIO PEDRO INDIO DA COSTA",
                        "JOÃO HENRIQUE HOLANDA CALDAS",
                        "JOVAIR OLIVEIRA ARANTES",
                        "JOSE  CARLOS NUNES JUNIOR"


    ]

    nomes_planilha_camara = ["ÁTILA SIDNEY LINS ALBUQUERQUE",
                            "BRUNIELE FERREIRA GOMES",
                            "GIVALDO DE SÁ GOUVEIA",
                            "ANTONIO PEDRO DE SIQUEIRA INDIO DA COSTA",
                            "JOAO HENRIQUE HOLANDA  CALDAS",
                            "JOVAIR DE OLIVEIRA ARANTES",
                            "JOSÉ CARLOS NUNES JÚNIOR"



    ]

    nomes_site_tse.each_with_index do |nome_civil, index|


      c = Candidato.find_by(:nome_civil=>nome_civil)
      c.update(:nome_civil=>nomes_planilha_camara[index], :nome_civil_sem_acentos=>I18n.transliterate(nomes_planilha_camara[index]))

      puts "#{nome_civil} ----> #{c.nome_civil} ----> #{c.nome_civil_sem_acentos}"
    end

  end

  def self.carrega_dados_candidatos_deputados_federais

    Candidato::SIGLAS_ESTADOS.each do |estado|

      puts "----------------- CANDIDATOS DO #{estado} ---------------------"

      url = "http://inter01.tse.jus.br/spceweb.consulta.receitasdespesas2014/candidatoAutoComplete.do"
      params = { "noCandLimpo" => "",
                  "sgUe" => estado,
                  "cdCargo" => 6,
                  "orderBy"=>"cand.NM_CANDIDATO"
      }
      response = Net::HTTP.post_form(URI.parse(url),params)
      pagina = Nokogiri::XML(response.body)

      pagina.css('name').each_with_index do |node_nome,index|

        nome_civil = node_nome.text.strip
        sequencial = pagina.css('sqCand')[index].text.strip
        partido = pagina.css('partido')[index].text.strip
        numero = pagina.css('numero')[index].text.strip
        nome_civil_sem_acentos = I18n.transliterate(nome_civil)

        c = Candidato.find_or_create_by(:nome_civil_sem_acentos=>nome_civil_sem_acentos)
        if c.update(:sequencial=>sequencial,
                    :nome_civil=>nome_civil,
                    :partido=>partido,
                    :estado=>estado,
                    :numero=>numero)
          puts "#{c.nome_civil} - #{c.sequencial} - #{c.nome_civil_sem_acentos} atualizado"
        else
          puts " ******************* #{c.nome_civil} - #{c.sequencial} deu bode "
        end

      end
    end
    return
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
