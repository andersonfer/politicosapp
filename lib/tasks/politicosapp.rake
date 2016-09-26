require File.join(File.dirname(__FILE__), '../dados_util.rb')

namespace :papp do

  desc "inicializa_dados"
  task :inicializa_dados => :environment do

    Candidato.processa_csv_candidatos_a_deputado_federal
    Partido.extrai_partidos_dos_candidatos
    Doador.carrega_doadores_para_deputado_federal
    Doacao.carrega_doacoes_dos_cantidatos_a_deputado_federal
    Candidato.processa_csv_candidatos_eleitos_a_deputado_federal

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

    Partido.atualiza_numero_dos_partidos

    Doador.marca_comites_financeiros

    Candidato.calcula_rankings_doacoes


  end

end
