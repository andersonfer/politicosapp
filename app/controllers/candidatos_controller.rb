class CandidatosController < ApplicationController

  def index

    @partidos = {}

    Partido.all.each do |p|

      @partidos[p.id.to_s] = p
    end

    @consulta_candidatos = Candidato.eleitos
    @consulta_candidatos = @consulta_candidatos.do_partido(params['partido_id']) if not params['partido_id'].blank?
    @consulta_candidatos = @consulta_candidatos.desc(:_total_em_doacoes).page(params['page'])

    nome_candidato = params['nome'].to_s.to_minusculas_sem_acentos_e_cia.split(" ").join(".*")
    @consulta_candidatos = @consulta_candidatos.where(:nome_pra_pesquisa=>/#{nome_candidato}/) if not params['nome'].blank?
    @candidatos = {}
    @consulta_candidatos.each do |c|
      @candidatos[c.id.to_s] = c
    end

    @soma = {}


    @doacoes = {}


    Doacao.dos_candidatos(@candidatos.keys).each do |d|

      if @doacoes[d.candidato_id.to_s]
        @doacoes[d.candidato_id.to_s].push d
      else
        @doacoes[d.candidato_id.to_s] = []
        @doacoes[d.candidato_id.to_s].push d
      end

    end



    @candidatos.each do |candidato_id,c|

      soma = 0
      if @doacoes[candidato_id]

        @doacoes[candidato_id].each do |d|
          soma += d.valor
        end

      end

      @soma[candidato_id] = soma

    end

    @totais = @soma.sort_by{|id,valor| -valor}

  end

  def show
    @candidato = Candidato.find params['id']
    @doacoes = @candidato.doacoes.order(valor: :desc)




    @doacoes_por_doador = {}

    @doacoes.each do |d|
      @doacoes_por_doador[d.doador_id.to_s] = {:valor=>0.0, :qtde=>0} if not @doacoes_por_doador[d.doador_id.to_s]
      @doacoes_por_doador[d.doador_id.to_s][:valor] += d.valor
      @doacoes_por_doador[d.doador_id.to_s][:qtde] += 1

    end



    @doadores = {}
    Doador.where(:id.in=>@doacoes_por_doador.keys).each do |d|
      @doadores[d.id.to_s] = d
    end

    @doacoes_por_doador = @doacoes_por_doador.sort_by{|id,valor| -valor[:valor]}

    @total = @doacoes.sum(:valor)

  end

end
