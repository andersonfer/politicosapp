class CandidatosController < ApplicationController

  def index

    @partidos = {}

    Partido.all.each do |p|

      @partidos[p.id.to_s] = p.nome
    end

    @consulta_candidatos = Candidato.asc(:nome).page(params['page'])
    @consulta_candidatos = @consulta_candidatos.where(:nome_pra_pesquisa=>/#{params['nome'].to_minusculas_sem_acentos_e_cia}/) if not params['nome'].blank?
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

    @totais = @soma.sort_by{|id,valor|valor}.reverse.each

  end

  def show
    @candidato = Candidato.find params['id']
    @doacoes = @candidato.doacoes.order(valor: :desc)

    @doadores = {}
    Doador.all.each do |d|
      @doadores[d.id.to_s] = d
    end



    @total = @doacoes.sum(:valor)

  end

end
