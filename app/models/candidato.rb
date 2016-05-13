class Candidato

  include Mongoid::Document

  SIGLAS_ESTADOS = ["AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"]


  field :sequencial,        :type=>String, :default=>nil
  field :nome,        :type=>String, :default=>nil
  field :estado,        :type=>String, :default=>nil
  #field :partido,        :type=>String, :default=>nil
  field :nome_partido,        :type=>String, :default=>nil
  field :numero,        :type=>String, :default=>nil
  field :cnpj,        :type=>String, :default=>nil
  field :candidato_a, :type=>String, :default=>nil


  belongs_to :partido
  has_many :doacoes, class_name:'Doacao'

  scope :dos_partidos, ->(partidos_ids) {self.and(:partido_id.in=>partidos_ids) }


  validates_uniqueness_of :sequencial

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
                                :partido=>c[3],
                                :numero=>c[4],
                                :cnpj=>c[5],
                                :candidato_a=>"deputado federal")

      if candidato.save()
        puts "candidato #{candidato.nome} - #{candidato.sequencial} salvo"
      end

    end

  end


end
