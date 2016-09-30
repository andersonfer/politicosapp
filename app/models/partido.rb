class Partido

  include Mongoid::Document

  SIGLAS_ESTADOS = ["AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"]


  field :nome,        :type=>String, :default=>nil
  field :_total_em_doacoes, :type=>Float, :default=>nil
  field :numero,        :type=>String, :default=>nil




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




