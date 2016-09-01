class Doacao

  include Mongoid::Document


  field :nro_recibo,        :type=>String, :default=>nil
  field :data,              :type=>Time, default:nil
  field :valor,             :type=>Integer, :default=>nil #valor em centavos
  field :especie_recurso,   :type=>String, :default=>nil
  field :nro_documento,     :type=>String, :default=>nil
  field :fonte_recurso,     :type=>String, :default=>nil


  belongs_to :candidato, :inverse_of=>nil
  belongs_to :doador, :inverse_of=>nil
  belongs_to :doador_originario, :inverse_of=>nil, :class_name=>'Doador'
  belongs_to :doador_intermediario, :inverse_of=>nil, :class_name=>'Doador'

  validates_presence_of :candidato,:doador,:valor

  scope :dos_candidatos, ->(candidato_ids) {self.and(:candidato_id.in=>candidato_ids) }
  scope :do_candidato, ->(candidato_id) {self.and(:candidato_id=>candidato_id) }
  scope :do_doador, ->(doador_id) {self.and(:doador_id=>doador_id)}



  def self.carrega_doacoes_dos_cantidatos_a_deputado_federal

    candidatos = {}
    doadores = {}

    CSV.foreach("doacoes_deputado_federal.csv") do |d|
      data_doacao = Date.strptime(d[6], '%Y-%m-%d')

      doacao = Doacao.new(:nro_recibo=>d[5],
                          :data=>data_doacao,
                          :valor=>d[7].to_i,
                          :especie_recurso=>d[8],
                          :nro_documento=>d[9],
                          :fonte_recurso=>d[10])

      candidato = candidatos[d[0]]
      if candidato.nil?
        candidato = Candidato.find_by(:sequencial=>d[0])
        candidatos[candidato.sequencial] = candidato
      end
      doacao.candidato_id = candidato.id

      doador = doadores[d[2]]

      if doador.nil?
        doador = Doador.find_by(:cnpj_cpf=>d[2])
        doadores[doador.cnpj_cpf] = doador
      end

      if d[4].blank?
        doacao.doador_id = doador.id
      else
        doacao.doador_intermediario_id = doador.id

        doador = doadores[d[4]]

        if doador.nil?
          doador = Doador.find_by(:cnpj_cpf=>d[4])
          doadores[doador.cnpj_cpf] = doador
        end

        doacao.doador_id = doador.id

      end
      if doacao.save!
        puts "#{candidato.nome} - #{doacao.nro_recibo} - #{doacao.valor}  - #{doacao.data}"
      end
    end

  end


end
