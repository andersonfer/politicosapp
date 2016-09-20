class Partido

  include Mongoid::Document

  SIGLAS_ESTADOS = ["AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"]


  field :nome,        :type=>String, :default=>nil
  field :_total_em_doacoes, :type=>Float, :default=>nil
  field :numero,        :type=>String, :default=>nil



  validates_uniqueness_of :nome, :numero

  #antes tem que processar as doacoes dos candidatos
  def calcula_total_em_doacoes
    self._total_em_doacoes = 0.0

    Candidato.do_partido(self.id).each do |c|
      self._total_em_doacoes += c._total_em_doacoes
    end

  end

  def self.extrai_partidos_dos_candidatos
    Candidato.all.distinct(:nome_partido).each do |nome_partido|
      p = Partido.create(:nome=>nome_partido)
      Candidato.where(:nome_partido=>nome_partido).update_all(:partido_id=>p.id)
      print "P"
    end
  end

  def self.atualiza_numero_dos_partidos
    Partido.all.each do |partido|
      numero_partido = Candidato.do_partido(partido.id).first.numero[0..1]
      partido.numero = numero_partido
      partido.save!

    end
  end

  def self.descobre_comites_financeiros
    cnpjs_comites = []


    Partido::SIGLAS_ESTADOS.each do |estado|

      Partido.distinct(:numero).each do |numero_partido|
        puts "------------------- #{estado} ----------------- #{numero_partido}"
        url = "http://inter01.tse.jus.br/spceweb.consulta.receitasdespesas2014/listaComiteDirecaoPartidaria.action?"
        params = {
        "nrPartido" =>numero_partido,
        "siglaUf" => estado
        }


        begin
          response = Net::HTTP.post_form(URI.parse(url),params)
        rescue
          puts "!!!!!!!!!!!!!  PALA NO #{estado} #{partido} !!!!!!!! #{url}"
          next
        end

        pagina = Nokogiri::XML(response.body)

        sequencial = ""

        if pagina.css('.linhaPreenchida').size > 0 #quer dizer que existem comites praquele partido e praquele estado

          pagina.css('a').each do |a_href|
            sequencial =  a_href.children[0].text.strip


            url = "http://inter01.tse.jus.br/spceweb.consulta.receitasdespesas2014/resumoReceitasByComite.action"
            params = {
              "sqComiteFinanceiro" => sequencial,
              "sgUe" => estado,
              "rb1"=>"on",
              "rbTipo"=>"on",
              "tipoEntrega"=>"0"

            }

            begin
              response = Net::HTTP.post_form(URI.parse(url),params)
            rescue
              puts "!!!!!!!!!!!!!  PALA NO #{estado} #{partido} !!!!!!!! #{url}"
              next
            end


            pagina = Nokogiri::XML(response.body)

            if pagina.css('.linhaPreenchida').size > 0
              cnpjs_comites << pagina.css('.linhaPreenchida').children[21].children.text.strip.gsub(/[\.\(\/-]/, '')
            end


          end
      end
    end




    end

    CSV.open("cnpjs_comites_financeiros.csv", "ab") do |csv|
      csv << cnpjs_comites
    end

  end


end




