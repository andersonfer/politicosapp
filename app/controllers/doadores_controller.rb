class DoadoresController < ApplicationController

  def index

    @doadores = Doador.all.order(nome: :asc)

  end

  def show
    @doador = Doador.find params['id']
    @doacoes = @doador.doacoes.order(data: :asc)

    @total = @doacoes.sum(:valor)

  end


end
