class Doador

  include Mongoid::Document

  field :nome, type:String, default:nil
  field :cnpj_cpf, type:String, default:nil

  field :_total_em_doacoes, :type=>Float, :default=>nil

  has_many :doacoes, class_name:'Doacao'


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

  def self.carrega_doadores_para_deputado_federal

    doadores = {}

    CSV.foreach("doacoes_deputado_federal.csv") do |d|
      doador = doadores[d[2]]

      if doador.nil?
        doador = Doador.new(:nome=>d[1],
                            :cnpj_cpf=>d[2])
        if doador.save!
          doadores[doador.cnpj_cpf] = doador
          puts "#{doador.nome} - #{doador.cnpj_cpf} salvo"
        end

      end

      if not d[4].blank?
        doador_originario = doadores[d[4]]
        if doador_originario.nil?
          doador_originario = Doador.new(:nome=>d[3],
                                         :cnpj_cpf=>d[4])
          if doador_originario.save!
            doadores[doador_originario.cnpj_cpf] = doador_originario
            puts "#{doador_originario.nome} - #{doador_originario.cnpj_cpf} salvo"
          end

        end

      end

    end

  end


end
