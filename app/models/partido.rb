class Partido

  include Mongoid::Document

   field :nome,        :type=>String, :default=>nil

   validates_uniqueness_of :nome


  def self.muda_o_campo_do_partido
    Candidato.all.each do |c|
      c.nome_partido = c.partido
      c.save
    end
  end

  def self.extrai_partidos_dos_candidatos
    Candidato.all.distinct(:nome_partido).each do |nome_partido|
      p = Partido.create(:nome=>nome_partido)
      Candidato.where(:nome_partido=>nome_partido).update_all(:partido_id=>p.id)
    end
  end


end




