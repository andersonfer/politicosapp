class NumerosController < ApplicationController


  def medias

    @resultados =
    { :eleitos =>     { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
      :nao_eleitos => { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
      :total =>       { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
      :total_eleitos => 0, :total_nao_eleitos => 0
    }

    Candidato.all.each do |c|
      if c.eleito?
        @resultados[:total_eleitos] += 1
        @resultados[:eleitos][:_total_em_doacoes] += c._total_em_doacoes.to_f
        @resultados[:eleitos][:_total_em_doacoes_partido] += c._total_em_doacoes_partido.to_f
        @resultados[:eleitos][:_total_em_doacoes_pessoas_via_partido] += c._total_em_doacoes_pessoas_via_partido.to_f
        @resultados[:eleitos][:_total_em_doacoes_pessoas_via_direta] += c._total_em_doacoes_pessoas_via_direta.to_f
      else
        @resultados[:total_nao_eleitos] += 1
        @resultados[:nao_eleitos][:_total_em_doacoes] += c._total_em_doacoes.to_f
        @resultados[:nao_eleitos][:_total_em_doacoes_partido] += c._total_em_doacoes_partido.to_f
        @resultados[:nao_eleitos][:_total_em_doacoes_pessoas_via_partido] += c._total_em_doacoes_pessoas_via_partido.to_f
        @resultados[:nao_eleitos][:_total_em_doacoes_pessoas_via_direta] += c._total_em_doacoes_pessoas_via_direta.to_f
      end

    end

    @percentuais_campo =
    { :eleitos =>     { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
      :nao_eleitos => { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
    }

    @medias =
    { :eleitos =>     { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
      :nao_eleitos => { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
      :total =>       { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0}

    }

    @percentuais_total_doacoes =
    { :eleitos =>     { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
      :nao_eleitos => { :_total_em_doacoes => 0.0, :_total_em_doacoes_partido => 0.0, :_total_em_doacoes_pessoas_via_direta => 0.0, :_total_em_doacoes_pessoas_via_partido => 0.0},
    }


    [:_total_em_doacoes, :_total_em_doacoes_partido, :_total_em_doacoes_pessoas_via_direta, :_total_em_doacoes_pessoas_via_partido].each do |campo|

      @resultados[:total][campo] = @resultados[:eleitos][campo] + @resultados[:nao_eleitos][campo]

      @percentuais_campo[:eleitos][campo] = @resultados[:eleitos][campo] / @resultados[:total][campo] if @resultados[:total][campo] > 0.0
      @percentuais_campo[:nao_eleitos][campo] = @resultados[:nao_eleitos][campo] / @resultados[:total][campo] if @resultados[:total][campo] > 0.0

      @percentuais_total_doacoes[:eleitos][campo] = @resultados[:eleitos][campo] / @resultados[:eleitos][:_total_em_doacoes] if @resultados[:eleitos][:_total_em_doacoes] > 0.0
      @percentuais_total_doacoes[:nao_eleitos][campo] = @resultados[:nao_eleitos][campo] / @resultados[:nao_eleitos][:_total_em_doacoes] if @resultados[:nao_eleitos][:_total_em_doacoes] > 0.0

      @medias[:eleitos][campo] = @resultados[:eleitos][campo] / @resultados[:total_eleitos] if @resultados[:total_eleitos] > 0.0
      @medias[:nao_eleitos][campo] = @resultados[:nao_eleitos][campo] / @resultados[:total_nao_eleitos] if @resultados[:total_nao_eleitos] > 0.0
      @medias[:total][campo] = (@resultados[:eleitos][campo] + @resultados[:nao_eleitos][campo]) / (@resultados[:total_eleitos] + @resultados[:total_nao_eleitos]) if (@resultados[:total_eleitos] + @resultados[:total_nao_eleitos]) > 0.0



    end






  end


  def graficos

    @dados_grafico1 = [['número de candidatos', 'nome da linha']]
    @dados_grafico2 = [['Ranking', 'Doações recebidas']]

    numero_eleitos = 0
    total = 0

    Candidato.desc(:_total_em_doacoes).each do |candidato|

      numero_eleitos += 1 if candidato.eleito?
      total += 1

      percentual_de_influencia_do_capital = (100 * numero_eleitos.to_f / total).to_i
      @dados_grafico1 << [total, percentual_de_influencia_do_capital]
      @dados_grafico2 << [total, candidato._total_em_doacoes/100]

    end
  end

end
