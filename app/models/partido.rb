class Partido

  include Mongoid::Document

  SIGLAS_ESTADOS = ["AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"]


  field :nome,        :type=>String, :default=>nil
  field :_total_dinheiro_utilizado, :type=>Float, :default=>nil
  field :_gastos_fundo_partidario, :type=>Float, :default=>nil
  field :_doacoes_recebidas_pelos_candidatos, :type=>Float, :default=>nil
  field :_doacoes_recebidas_pelo_partido, :type=>Float, :default=>nil
  field :numero,        :type=>String, :default=>nil




  #antes tem que processar as doacoes dos candidatos
  def calcula_total_em_doacoes
    self._total_dinheiro_utilizado = 0.0
    self._gastos_fundo_partidario = 0.0
    self._doacoes_recebidas_pelos_candidatos = 0.0
    self._doacoes_recebidas_pelo_partido = 0.0

    Candidato.do_partido(self.id).each do |c|
      self._total_dinheiro_utilizado += c._total_em_doacoes
      self._gastos_fundo_partidario += c._total_em_doacoes_partido
      self._doacoes_recebidas_pelos_candidatos += c._total_em_doacoes_pessoas_via_direta
      self._doacoes_recebidas_pelo_partido += c._total_em_doacoes_pessoas_via_partido

    end

  end

  def self.extrai_partidos_dos_candidatos
    Candidato.all.distinct(:nome_partido).each do |nome_partido|
      p = Partido.create(:nome=>nome_partido)
      Candidato.where(:nome_partido=>nome_partido).update_all(:partido_id=>p.id)
    end
  end

  def self.atualiza_numero_dos_partidos
    Partido.all.each do |partido|
      numero_partido = Candidato.do_partido(partido.id).first.numero[0..1]
      partido.numero = numero_partido
      partido.save!
    end
  end


end




