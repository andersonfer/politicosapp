require File.join(File.dirname(__FILE__), '../dados_util.rb')

namespace :papp do

  desc "inicializa_dados"
  task :inicializa_dados => :environment do

    tam_pagina = 1000

    puts "\n\n"
    puts "Inserindo CANDIDATOS. Cada ponto são #{tam_pagina}."
    Candidato.collection.drop
    Candidato.processa_csv_candidatos_a_deputado_federal(tam_pagina)

    puts "\n\n"
    print "Inserindo PARTIDOS... "
    Partido.collection.drop
    Partido.extrai_partidos_dos_candidatos
    Partido.atualiza_numero_dos_partidos
    print "OK"

    puts "\n\n"
    puts "Inserindo DOAÇÕES e DOADORES. Cada ponto são #{tam_pagina} documentos."
    Doacao.carrega_doacoes_e_doadores_deputado_federal(tam_pagina)

    # puts "\n\n"
    # puts "Inserindo DOADORES. Cada ponto são #{tam_pagina}."
    # Doador.collection.drop
    # Doador.carrega_doadores_para_deputado_federal(tam_pagina)

    # puts "\n\n"
    # puts "Inserindo DOAÇÕES. Cada ponto são #{tam_pagina}."
    # Doacao.collection.drop
    # Doacao.carrega_doacoes_dos_cantidatos_a_deputado_federal(tam_pagina)

    puts "\n\n"
    print "Marcando eleitos... "
    Candidato.processa_csv_candidatos_eleitos_a_deputado_federal
    print "OK"

    puts "\n\n"
    print "Marcando comitês financeiros... "
    Doador.marca_comites_financeiros
    print "OK"

    puts "\n\n"
    puts "Calculando totais de doação para CANDIDATOS... "
    DadosUtil.percorrer_paginado(Candidato.all, 100) do |candidato|
      candidato.calcula_total_em_doacoes
      candidato.save!
    end
    print "OK"

    puts "\n\n"
    puts "Calculando totais de doação para DOADORES... "
    DadosUtil.percorrer_paginado(Doador.all, 100) do |doador|
      doador.calcula_total_em_doacoes
      doador.save!
    end
    print "OK"

    puts "\n\n"
    puts "Calculando totais de doação para PARTIDOS... "
    DadosUtil.percorrer_paginado(Partido.all, 100) do |partido|
      partido.calcula_total_em_doacoes
      partido.save!
    end

    puts "\n\n"
    print "Calculando ranking de doações... "
    Candidato.calcula_rankings_doacoes
    puts "OK"


  end


  desc "re-processa dados iniciados"
  task :reprocassa_dados_iniciados => :environment do

    Partido.atualiza_numero_dos_partidos
    Doador.marca_comites_financeiros

    DadosUtil.percorrer_paginado(Candidato.all, 100) do |candidato|
      candidato.calcula_total_em_doacoes
      candidato.save!
    end

    DadosUtil.percorrer_paginado(Doador.all, 100) do |doador|
      doador.calcula_total_em_doacoes
      doador.save!
    end

    DadosUtil.percorrer_paginado(Partido.all, 100) do |partido|
      partido.calcula_total_em_doacoes
      partido.save!
    end



    Candidato.calcula_rankings_doacoes

  end

end
