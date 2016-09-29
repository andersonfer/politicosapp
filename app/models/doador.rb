class Doador

  include Mongoid::Document

  field :nome, type:String, default:nil
  field :cnpj_cpf, type:String, default:nil

  field :_total_em_doacoes, :type=>Float, :default=>nil

  has_many :doacoes, class_name:'Doacao'
  belongs_to :partido


  validates_uniqueness_of :cnpj_cpf

  def calcula_total_em_doacoes
    self._total_em_doacoes = 0.0

    Doacao.do_doador(self.id).each do |d|
      self._total_em_doacoes += d.valor
    end

  end



  def cnpj_cpf_formatado
    if self.cnpj_cpf and self.cnpj_cpf.size == 11
      "#{self.cnpj_cpf[0..2]}.#{self.cnpj_cpf[3..5]}.#{self.cnpj_cpf[6..8]}-#{self.cnpj_cpf[9..10]}"
    else
      "#{self.cnpj_cpf[0..1]}.#{self.cnpj_cpf[2..4]}.#{self.cnpj_cpf[5..7]}/#{self.cnpj_cpf[8..11]}-#{self.cnpj_cpf[12..13]}"
    end
  end

  def self.carrega_doadores_para_deputado_federal tamanho_pagina=500

    doadores = {}
    doadores_para_salvar = []

    CSV.foreach("doacoes_deputado_federal.csv") do |d|

      doador = doadores[d[2]]

      if doador.nil?
        doador = Doador.new(:nome=>d[1], :cnpj_cpf=>d[2])
        doadores[doador.cnpj_cpf] = doador
        doadores_para_salvar << doador.as_document
      end

      if not d[4].blank?

        doador = doadores[d[4]]

        if doador.nil?
          doador = Doador.new(:nome=>d[3], :cnpj_cpf=>d[4])
          doadores[doador.cnpj_cpf] = doador
          doadores_para_salvar << doador.as_document
        end

      end

      if doadores_para_salvar.size > tamanho_pagina 
        Doador.create!(doadores_para_salvar)
        doadores_para_salvar = []
        print "."
      end

    end

    Doador.create!(doadores_para_salvar)

  end

  def self.descobre_comites_financeiros
    cnpjs_comites = []

    estados_mais_BR = Partido::SIGLAS_ESTADOS << 'BR'

    CSV.open("cnpjs_comites_financeiros.csv", "ab") do |csv|
      estados_mais_BR.each do |estado|

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
                dados_doador = [pagina.css('.linhaPreenchida').children[21].children.text.strip.gsub(/[\.\(\/-]/, ''),numero_partido,estado]
                csv << dados_doador
              end


            end
        end
      end




      end

    end

  end

  def self.marca_comites_financeiros

    Doador.update_all(:partido_id=>nil)

    CSV.foreach("cnpjs_comites_financeiros.csv") do |dados_doador|

      if doador = Doador.where(:cnpj_cpf=>dados_doador[0]).first
        partido = Partido.find_by(:numero=>dados_doador[1])
        doador.partido_id = partido.id
        doador.save!
      end

    end

  end

  def comite_financeiro?
    not (self.partido.nil?)
  end



end
