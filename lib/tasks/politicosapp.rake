namespace :papp do


  desc "inicializa_dados"
  task :inicializa_dados => :environment do

    Candidato.processa_csv_candidatos_a_deputado_federal
    Partido.extrai_partidos_dos_candidatos
    Doador.carrega_doadores_para_deputado_federal
    Doacao.carrega_doacoes_dos_cantidatos_a_deputado_federal

    Candidato.all.each do |c|
      c.calcula_total_em_doacoes
      c.save!
    end

    Doador.all.each do |d|
      d.calcula_total_em_doacoes
      d.save!
    end

    Partido.all.each do |p|
      p.calcula_total_em_doacoes
      p.save!
    end


  end

end
