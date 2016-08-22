TO.DO












Partido.each do |p|
    p.calcula_total_em_doacoes
    p.save!
    puts "#{p.nome} - #{p._total_em_doacoes}"
  end


