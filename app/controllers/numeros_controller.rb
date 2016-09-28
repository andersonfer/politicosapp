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

      @percentuais_campo[:eleitos][campo] = @resultados[:eleitos][campo] / @resultados[:total][campo]
      @percentuais_campo[:nao_eleitos][campo] = @resultados[:nao_eleitos][campo] / @resultados[:total][campo]

      @percentuais_total_doacoes[:eleitos][campo] = @resultados[:eleitos][campo] / @resultados[:eleitos][:_total_em_doacoes]
      @percentuais_total_doacoes[:nao_eleitos][campo] = @resultados[:nao_eleitos][campo] / @resultados[:nao_eleitos][:_total_em_doacoes]

      @medias[:eleitos][campo] = @resultados[:eleitos][campo] / @resultados[:total_eleitos]
      @medias[:nao_eleitos][campo] = @resultados[:nao_eleitos][campo] / @resultados[:total_nao_eleitos]
      @medias[:total][campo] = (@resultados[:eleitos][campo] + @resultados[:nao_eleitos][campo]) / (@resultados[:total_eleitos] + @resultados[:total_nao_eleitos])



    end






  end

end
