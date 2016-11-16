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
    @dados_grafico2 = [['', '']]
    @dados_grafico3 = [["aa", "bb", { role: "style" } ]]
    @dados_grafico4 = [["aa", "bb", { role: "style" } ]]

    numero_eleitos = 0
    numero_eleitos_por_grupo = 0
    doacoes_do_grupo = 0
    tamanho_grupo = 150
    total = 0
    doacoes_do_1o = 0
    i = 0

    @dados_grafico5 = [['quem mais recebeu doações em $', 'eleitos', 'não-eleitos']]
    hash_dados_grafico6 = {}

    Candidato.desc(:ranking_total_em_doacoes).to_a.reverse.each do |candidato|

      qtde_de_100mil = candidato._total_em_doacoes / 10000000
      hash_dados_grafico6["#{qtde_de_100mil}x100K"] = {'eleitos'=>0, 'nao_eleitos'=>0} if not hash_dados_grafico6["#{qtde_de_100mil}x100K"]
      
      if candidato.eleito?
        hash_dados_grafico6["#{qtde_de_100mil}x100K"]['eleitos'] += 1
        numero_eleitos += 1 
        numero_eleitos_por_grupo += 1
        cor = "gold"
      else
        hash_dados_grafico6["#{qtde_de_100mil}x100K"]['nao_eleitos'] += 1
        cor = "silver"
      end

      total += 1

      percentual_de_influencia_do_capital = (100 * numero_eleitos.to_f / total).to_i
      @dados_grafico1 << [total, percentual_de_influencia_do_capital]
      @dados_grafico2 << [candidato.ranking_total_em_doacoes, candidato._total_em_doacoes/100]

      @dados_grafico3 << [percentual_de_influencia_do_capital, total , cor]


      if i % tamanho_grupo == (tamanho_grupo-1)
        @dados_grafico4 << [total, numero_eleitos_por_grupo.to_i, cor]
        # @dados_grafico5 << ["#{i-(tamanho_grupo-2)}-#{i+1}: #{doacoes_do_grupo/100000}", numero_eleitos_por_grupo.to_i, (tamanho_grupo-numero_eleitos_por_grupo.to_i)]
        @dados_grafico5 << ["#{doacoes_do_1o/100000} - #{candidato._total_em_doacoes/100000}", numero_eleitos_por_grupo.to_i, (tamanho_grupo-numero_eleitos_por_grupo.to_i)]
        numero_eleitos_por_grupo = 0 
        doacoes_do_grupo = 0

      elsif i % tamanho_grupo == 0
        doacoes_do_1o = candidato._total_em_doacoes
      end

      doacoes_do_grupo += candidato._total_em_doacoes
      i += 1

    end

    resto = i % tamanho_grupo

    @dados_grafico5 << ["de #{ i - resto + 1 } a #{i}", numero_eleitos_por_grupo.to_i, (resto-numero_eleitos_por_grupo.to_i)]

    @dados_grafico6 = [['quem mais recebeu doações em $', 'eleitos', 'não-eleitos']]
    hash_dados_grafico6.each do |x, hash_info|
      tot = hash_info['eleitos'] + hash_info['nao_eleitos']
      @dados_grafico6 << [x, (100*hash_info['eleitos'].to_f).round/tot, (100*hash_info['nao_eleitos'].to_f).round/tot]
    end

    puts @dados_grafico6

  end

end
