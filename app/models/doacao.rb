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
  belongs_to :doador_intermediario, :inverse_of=>nil, :class_name=>'Doador'

  validates_presence_of :candidato,:doador,:valor

  scope :dos_candidatos, ->(candidato_ids) {self.and(:candidato_id.in=>candidato_ids) }
  scope :do_candidato, ->(candidato_id) {self.and(:candidato_id=>candidato_id) }
  scope :do_doador, ->(doador_id) {self.and(:doador_id=>doador_id)}

  def from_partido?
    (self.doador_intermediario.nil? and self.doador.comite_financeiro?)
  end

  def from_pessoa_via_partido?
    ( (not self.doador_intermediario.nil?) and self.doador_intermediario.comite_financeiro?)
  end


  def self.carrega_doacoes_dos_cantidatos_a_deputado_federal

    doacoes = []

    CSV.foreach("doacoes_deputado_federal.csv") do |d|
      data_doacao = Date.strptime(d[6], '%Y-%m-%d')

      doacao = Doacao.new(:nro_recibo=>d[5],
                          :data=>data_doacao,
                          :valor=>d[7].to_i,
                          :especie_recurso=>d[8],
                          :nro_documento=>d[9],
                          :fonte_recurso=>d[10])


      candidato = Candidato.find_by(:sequencial=>d[0])
      doacao.candidato_id = candidato.id


      doador = Doador.find_by(:cnpj_cpf=>d[2])

      if d[4].blank?
        doacao.doador_id = doador.id
      else

        doacao.doador_intermediario_id = doador.id
        doador = Doador.find_by(:cnpj_cpf=>d[4])
        doacao.doador_id = doador.id

      end

      doacoes << doacao.as_document

      if doacoes.size > 400
        Doacao.create!(doacoes)
        doacoes = []
        print 'D'
      end

    end

  end


end
