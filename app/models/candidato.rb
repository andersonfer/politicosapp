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

  def self.pega_o_html_do_candidatos_e_salva

    Candidato.where(:html=>nil).distinct(:sequencial).each do |seqCandidato|

      puts "------------ buscando sequencial ----> #{seqCandidato} --------------"
      url = "http://inter01.tse.jus.br/spceweb.consulta.receitasdespesas2014/resumoReceitasByCandidato.action"

      params = { "sqCandidato" => seqCandidato,
                "sgUe" => "",
                "sgUfMunicipio"=> "",
                "filtro" => "S",
                "tipoEntrega" => "0"}

      begin
        response = Net::HTTP.post_form(URI.parse(url),params)
        puts "response ok"
      rescue
        puts '!!!!!!!!!! BODEEEEEEEEEEE !!!!!!'
        next
      end

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


  def processa_html_do_candidato

    pagina = Nokogiri::HTML(self.html)
    classes_td = ['.linhaPreenchida', '.linhaNaoPreenchida']

    classes_td.each do |classe|

      pagina.css(classe).each do |tr|

        td = tr.children

        nome_doador = td[1].text.squish
        cnpj_cpf_doador = td[3].text.squish.gsub(/[\.\(\/-]/, '')

        doador = Doador.find_or_create_by(:cnpj_cpf=>cnpj_cpf_doador)
        if doador.update(:nome=>nome_doador)
          #puts "DOADOR #{doador.nome} salvo ---  cpf/cnpj #{doador.cnpj_cpf}"
        end


        nome_originario = td[5].text.squish.blank? ? nil : td[5].text.squish
        cpf_cnpj_originario = td[7].text.squish.blank? ? nil : td[7].text.squish.gsub(/[\.\(\/-]/, '')

        if not cpf_cnpj_originario.nil?

          doador_originario = Doador.find_or_create_by(:cnpj_cpf=>cpf_cnpj_originario)
          if doador_originario.update(:nome=>nome_originario)
            #puts "DOADOR ORIGINÁRIO   #{doador_originario.nome}  cpf/cnpj  #{doador_originario.cnpj_cpf}"
          end

        end


        nro_recibo = td[11].text.squish
        data_doacao = Date.strptime(td[9].text.squish, '%m/%d/%y')
        #os valores vem com apenas 1 zero depois da virgula. a expressao abaixo adiciona mais 1 zero.
        valor_string = td[13].text.squish
        valor_ajustado = valor_string.split(/\./)[1].size == 2 ? valor_string : valor_string + "0"
        valor_em_cents = valor_ajustado.gsub(/[\,\(\/.]/, '').to_i


        especie_recurso = td[15].text.squish
        nro_documento = td[17].text.squish
        fonte_recurso = td[31].text.squish

        doacao = Doacao.find_or_create_by(:nro_recibo=>nro_recibo)


        if doacao.update(:data=>data_doacao,
                         :valor=>valor_em_cents,
                         :especie_recurso=>especie_recurso,
                         :nro_documento=>nro_documento,
                         :fonte_recurso=>fonte_recurso,
                         :candidato=>c,
                         :doador=>doador,
                         :doador_originario=>doador_originario)

            puts "doacao nro #{doacao.nro_recibo} com valor #{doacao.valor} do dia #{doacao.data} para o candidato #{self.sequencial} criada"
        end


      end

    end

  end


end
