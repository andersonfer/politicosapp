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


  def from_fundo_partidario?
    self.from_partido?
  end

  def para_candidato?
    (self.doador_intermediario.nil? and not self.doador.comite_financeiro?)
  end

  def para_partido?
    (not self.doador_intermediario.nil? and not self.doador.comite_financeiro?)
  end


  def self.carrega_doacoes_e_doadores_deputado_federal tamanho_pagina=500

    Doador.collection.drop
    Doacao.collection.drop

    doadores_para_salvar = []
    doacoes_para_salvar = []
    doadores = {}

    CSV.foreach("doacoes_deputado_federal.csv") do |d|
      data_doacao = Date.strptime(d[6], '%Y-%m-%d')

      # cria a doação sem ligações
      doacao = Doacao.new(:nro_recibo=>d[5],
                          :data=>data_doacao,
                          :valor=>d[7].to_i,
                          :especie_recurso=>d[8],
                          :nro_documento=>d[9],
                          :fonte_recurso=>d[10])


      # liga o candidato
      candidato = Candidato.find_by(:sequencial=>d[0])
      doacao.candidato_id = candidato.id

      # encontra o doador e, se for o caso, coloca ele para salvar
      cnpj_cpf_doador = d[2]
      if not doadores[cnpj_cpf_doador]
        doadores[cnpj_cpf_doador] = Doador.new(:nome=>d[1], :cnpj_cpf=>cnpj_cpf_doador)
        doadores_para_salvar << doadores[cnpj_cpf_doador].as_document
      end

      # se não tiver doador intermediário (indicado pelo campo d[4]), o d[2] é o cpf/cnpj do doador principal
      if d[4].blank?
        doacao.doador_id = doadores[cnpj_cpf_doador].id

      else

        # caso contrátio, temos o doador intermediário na mão (comitês financeiros, na maioria dos casos)
        doacao.doador_intermediario_id = doadores[cnpj_cpf_doador].id

        # e o doador principal (dono da grana) é outro doador (o cnpj/cpf do campo d[4])
        cnpj_cpf_doador = d[4]
        if not doadores[cnpj_cpf_doador]
          doadores[cnpj_cpf_doador] = Doador.new(:nome=>d[3], :cnpj_cpf=>cnpj_cpf_doador)
          doadores_para_salvar << doadores[cnpj_cpf_doador].as_document
        end

        doacao.doador_id = doadores[cnpj_cpf_doador].id


      end

      doacoes_para_salvar << doacao.as_document

      # salva um monte de doações e um monte de doadores
      if ( (doacoes_para_salvar.size + doadores_para_salvar.size) >= tamanho_pagina )

        Doador.create!(doadores_para_salvar)
        doadores_para_salvar = []

        Doacao.create!(doacoes_para_salvar)
        doacoes_para_salvar = []

        print '.'

      end

    end

    Doador.create!(doadores_para_salvar)
    Doacao.create!(doacoes_para_salvar)



  end

end
