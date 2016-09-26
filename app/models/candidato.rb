class Candidato

  include Mongoid::Document

  SIGLAS_ESTADOS = ["AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"]


  field :sequencial,        :type=>String, :default=>nil
  field :nome,        :type=>String, :default=>nil
  field :estado,        :type=>String, :default=>nil
  #field :partido,        :type=>String, :default=>nil
  field :coligacao,        :type=>String, :default=>nil
  field :qtde_votos,        :type=>Integer, :default=>nil
  field :eleito_em,        :type=>Integer, :default=>nil
  field :nome_partido,        :type=>String, :default=>nil
  field :numero,        :type=>String, :default=>nil
  field :cnpj,        :type=>String, :default=>nil
  field :candidato_a, :type=>String, :default=>nil
  field :_total_em_doacoes, :type=>Float, :default=>nil
  field :_total_em_doacoes_partido, :type=>Float, :default=>nil
  field :_total_em_doacoes_pessoas_via_direta, :type=>Float, :default=>nil
  field :_total_em_doacoes_pessoas_via_partido, :type=>Float, :default=>nil


  field :ranking_total_em_doacoes, :type=>Integer, :default=>nil

  field :nome_parlamentar,        :type=>String, :default=>nil
  field :titularidade,        :type=>String, :default=>nil
  field :endereco,        :type=>String, :default=>nil
  field :telefone  ,        :type=>String, :default=>nil
  field :fax ,        :type=>String, :default=>nil
  field :mes_dia_aniversario,        :type=>String, :default=>nil
  field :email,        :type=>String, :default=>nil
  field :tratamento,        :type=>String, :default=>nil
  field :profissões,        :type=>String, :default=>nil
  field :nome_civil,        :type=>String, :default=>nil

  field :nome_pra_pesquisa,        :type=>String, :default=>nil

  before_save :calcula_nome_pra_pesquisa


  belongs_to :partido
  has_many :doacoes, class_name:'Doacao'

  scope :dos_partidos, ->(partidos_ids) {self.and(:partido_id.in=>partidos_ids) }
  scope :do_partido, ->(partidos_id) {self.and(:partido_id=>partidos_id) }
  scope :com_numero, ->(num) {self.and(:numero=>num) }
  scope :do_estado, ->(est) {self.and(:estado=>est) }
  scope :eleitos, ->() {self.and(:eleito_em.ne=>nil) }


  validates_uniqueness_of :sequencial

  def self.calcula_rankings_doacoes

    Candidato.all.desc(:_total_em_doacoes).each_with_index do |c,index|
      c.ranking_total_em_doacoes = index + 1
      c.save!
    end



  end

  def cnpj_formatado
    "#{self.cnpj[0..1]}.#{self.cnpj[2..4]}.#{self.cnpj[5..7]}/#{self.cnpj[8..11]}-#{self.cnpj[12..13]}"
  end

  def eleito?
    (not self.eleito_em.nil?)
  end

  def calcula_nome_pra_pesquisa

    self.nome_pra_pesquisa = self.nome.to_s.to_minusculas_sem_acentos_e_cia
  end

  def self.le_arquivo_deputados_federais
    CSV.foreach('deputados.csv', {:col_sep=>";"}) do |linha|
      attrs_candidato = Candidato.attrs_candidato_from_linha_importacao(linha)

      if attrs_candidato['nome_civil'] == "ÁTILA SIDNEY LINS ALBUQUERQUE"
        attrs_candidato['nome_civil'] = "ATILA SIDNEY LINS DE ALBUQUERQUE"
      # elsif attrs_candidato['nome_civil'] == ''
      #   attrs_candidato['nome_civil'] = ''
      elsif attrs_candidato['nome_civil'] == 'BRUNIELE FERREIRA GOMES'
        attrs_candidato['nome_civil'] = 'BRUNIELE FERREIRA DA SILVA'
      elsif attrs_candidato['nome_civil'] == 'ELIZEU DIONIZIO SOUZA DA SILVA'
        attrs_candidato['nome_civil'] = 'ELIZEU DIONIZIO SOUZA  DA SILVA'
      elsif attrs_candidato['nome_civil'] == 'GIVALDO DE SÁ GOUVEIA'
        attrs_candidato['nome_civil'] = 'GIVALDO DE SÁ GOUVEIA CARIMBÃO'
      elsif attrs_candidato['nome_civil'] == 'ANTONIO PEDRO DE SIQUEIRA INDIO DA COSTA'
        attrs_candidato['nome_civil'] = 'ANTONIO PEDRO INDIO DA COSTA'
      elsif attrs_candidato['nome_civil'] == 'JOVAIR DE OLIVEIRA ARANTES'
        attrs_candidato['nome_civil'] = 'JOVAIR OLIVEIRA ARANTES'
      elsif attrs_candidato['nome_civil'] == 'JOZIANE ARAUJO NASCIMENTO'
        attrs_candidato['nome_civil'] = 'JOZIANE ARAUJO NASCIMENTO ROCHA'
      elsif attrs_candidato['nome_civil'] == 'JOZIANE ARAUJO NASCIMENTO'
        attrs_candidato['nome_civil'] = 'JOZIANE ARAUJO NASCIMENTO ROCHA'
      elsif attrs_candidato['nome_civil'] == 'JOSÉ CARLOS NUNES JÚNIOR'
        attrs_candidato['nome_civil'] = 'JOSE  CARLOS NUNES JUNIOR'

      end

      begin

        c = Candidato.find_by(:nome_pra_pesquisa=>attrs_candidato['nome_civil'].to_minusculas_sem_acentos_e_cia)
        c.update!(attrs_candidato)

      rescue Exception => e
        puts "candidato #{attrs_candidato['nome_civil']} não encontrado"
      end
    end

  end

  def self.attrs_candidato_from_linha_importacao linha_importacao

    #linha_importacao = linha_importacao.split(/[;]/)

    {'nome_parlamentar'     => linha_importacao[0].to_s.squish,
     'titularidade'          => linha_importacao[3].to_s.squish,
     'endereco'            => "#{linha_importacao[4].to_s.squish} #{linha_importacao[5].to_s.squish} #{linha_importacao[6].to_s.squish} #{linha_importacao[7].to_s.squish} #{linha_importacao[8].to_s.squish}",
     'telefone'    => linha_importacao[9].to_s.squish,
     'fax'           => linha_importacao[10].to_s.squish,
     'mes_dia_aniversario' => "#{linha_importacao[11].to_s.squish} #{linha_importacao[12].to_s.squish}",
     'email' => linha_importacao[13].to_s.squish,
     'tratamento' => linha_importacao[15].to_s.squish,
     'profissões'           => linha_importacao[16].to_s.squish,
     'nome_civil'           => linha_importacao[17].to_s.squish
   }
  end


  def calcula_total_em_doacoes

    self._total_em_doacoes = 0.0
    self._total_em_doacoes_partido = 0.0
    self._total_em_doacoes_pessoas_via_direta = 0.0
    self._total_em_doacoes_pessoas_via_partido = 0.0


    Doacao.do_candidato(self.id).each do |d|
      self._total_em_doacoes += d.valor
      if d.from_partido?
        self._total_em_doacoes_partido += d.valor
      elsif d.from_pessoa_via_partido?
        self._total_em_doacoes_pessoas_via_partido += d.valor
      else
        self._total_em_doacoes_pessoas_via_direta += d.valor
      end

    end

  end

  def self.carrega_dados_dos_cantidatos_a_deputado_federal

    CSV.open("candidatos_a_deputado_federal.csv", "ab") do |csv_candidatos|

      Candidato::SIGLAS_ESTADOS.each do |estado|
        puts "----------------- CANDIDATOS DO #{estado} ---------------------"

        url_com_os_nomes_e_sequenciais = "http://inter01.tse.jus.br/spceweb.consulta.receitasdespesas2014/candidatoAutoComplete.do"
        params = { "noCandLimpo" => "",
                    "sgUe" => estado,
                    "cdCargo" => 6,
                    "orderBy"=>"cand.NM_CANDIDATO"
        }
        response = Net::HTTP.post_form(URI.parse(url_com_os_nomes_e_sequenciais),params)
        pagina_com_os_nomes_e_sequenciais = Nokogiri::XML(response.body)

        pagina_com_os_nomes_e_sequenciais.css('name').each_with_index do |node_nome,index|


          sequencial = pagina_com_os_nomes_e_sequenciais.css('sqCand')[index].text.strip
          nome_civil = node_nome.text.strip
          #nome_civil_sem_acentos = I18n.transliterate(nome_civil)
          partido = pagina_com_os_nomes_e_sequenciais.css('partido')[index].text.strip
          numero = pagina_com_os_nomes_e_sequenciais.css('numero')[index].text.strip


          url_com_o_html_das_doacoes = "http://inter01.tse.jus.br/spceweb.consulta.receitasdespesas2014/resumoReceitasByCandidato.action"

          params = { "sqCandidato" => sequencial,
                    "sgUe" => "",
                    "sgUfMunicipio"=> "",
                    "filtro" => "S",
                    "tipoEntrega" => "0"}

          begin
            response = Net::HTTP.post_form(URI.parse(url_com_o_html_das_doacoes),params)
            puts "response ok"
          rescue
            puts '!!!!!!!!!! BODEEEEEEEEEEE !!!!!!'
            next
          end

          html_do_candidato = response.body

          pagina_com_as_doacoes = Nokogiri::HTML(html_do_candidato)

          if pagina_com_as_doacoes.css('.linhaPreenchida').size > 0  #quer dizer que o candidato recebeu alguma doação
            cnpj = pagina_com_as_doacoes.css('.linhaPreenchida').children[21].children.text.strip.gsub(/[\.\(\/-]/, '')
          end

          dados_candidato = [sequencial,nome_civil,estado,partido,numero,cnpj]
          csv_candidatos << dados_candidato
          print "#{dados_candidato} \n"

          CSV.open("doacoes_deputado_federal.csv", "ab") do |csv_doacoes|

            classes_td = ['.linhaPreenchida', '.linhaNaoPreenchida']

            classes_td.each do |classe|

              pagina_com_as_doacoes.css(classe).each do |tr|

                td = tr.children

                nome_doador = td[1].text.squish
                cnpj_cpf_doador = td[3].text.squish.gsub(/[\.\(\/-]/, '')


                nome_originario = td[5].text.squish.blank? ? nil : td[5].text.squish
                cpf_cnpj_originario = td[7].text.squish.blank? ? nil : td[7].text.squish.gsub(/[\.\(\/-]/, '')


                nro_recibo = td[11].text.squish
                data_doacao = Date.strptime(td[9].text.squish, '%m/%d/%y')
                #os valores vem com apenas 1 zero depois da virgula. a expressao abaixo adiciona mais 1 zero.
                valor_string = td[13].text.squish
                valor_ajustado = valor_string.split(/\./)[1].size == 2 ? valor_string : valor_string + "0"
                valor_em_cents = valor_ajustado.gsub(/[\,\(\/.]/, '').to_i


                especie_recurso = td[15].text.squish
                nro_documento = td[17].text.squish
                fonte_recurso = td[31].text.squish


                dados_doacao = [sequencial,nome_doador,cnpj_cpf_doador,nome_originario,cpf_cnpj_originario,nro_recibo,data_doacao,valor_em_cents,especie_recurso,nro_documento,fonte_recurso]
                csv_doacoes << dados_doacao

              end

            end
            puts "doacoes processadas"
          ###
          end


        end

      end

   end


  end

  def self.processa_csv_candidatos_a_deputado_federal
    CSV.foreach("candidatos_a_deputado_federal.csv") do |c|

      candidato = Candidato.new(:sequencial=>c[0],
                                :nome=>c[1],
                                :estado=>c[2],
                                :nome_partido=>c[3],
                                :numero=>c[4],
                                :cnpj=>c[5],
                                :candidato_a=>"deputado federal")

      if candidato.save!
        print "C"
      end

    end

  end


  def self.processa_csv_candidatos_eleitos_a_deputado_federal

    estados = []
    partidos = {}

    Partido.all.each do |p|
      partidos[p.nome] = p
    end

    File.readlines("arquivos/deputados_federais_eleitos_eleicoes_2014.csv")[1..-1].each do |linha|

      dados = linha.split(';').map {|dado| dado.gsub('"', '').squish}

      numero_candidato = dados[2]
      partido = partidos[dados[4]]

      if partido and not numero_candidato.blank?

        #NOTE: se tem o número, é um candidato.

        estado = dados[0]
        if estado.blank?
          estado = estados.last
        else
          estados << estado
        end

        #NOTE: pula dados[1] pq ele é o cargo e a gente está apenas processando deputados federais.
        #NOTE: pula dados[3] pq é o nome e não precisamos
        #NOTE: pula dados[6] pq ele é o turno e todos os deputados federais são eleitos em 1o turno.

        coligacao = dados[5]
        qtde_votos = dados[7].gsub('.', '').to_i

        if candidato = Candidato.com_numero(numero_candidato).do_estado(estado).first


          candidato.coligacao = coligacao
          candidato.qtde_votos = qtde_votos
          candidato.eleito_em = 2014
          candidato.save!
          print '.'
        else
          puts "tem que arrumar esse bug do GOMIDE!!!"
        end

      end

    end

    true
  end


end
