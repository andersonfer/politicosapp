class DoadoresController < ApplicationController

  def index

    @doadores = Doador.all.order(nome: :asc)

  end

  def show
    @doador = Doador.find params['id']
    @doacoes = @doador.doacoes.order(valor: :desc)

    @candidatos = {}
    Candidato.all.each do |c|
      @candidatos[c.id.to_s] = c
    end


    @total = @doacoes.sum(:valor)

  end


end