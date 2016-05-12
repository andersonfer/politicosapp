class CandidatosController < ApplicationController

  def index

    @candidatos = Candidato.all.order(estado: :asc,partido: :asc,nome: :asc)

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
