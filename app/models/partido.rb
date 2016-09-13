class Partido

  include Mongoid::Document

  field :nome,        :type=>String, :default=>nil
  field :_total_em_doacoes, :type=>Float, :default=>nil


  validates_uniqueness_of :nome

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


end




