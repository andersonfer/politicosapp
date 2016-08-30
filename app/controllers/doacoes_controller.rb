class DoacoesController < ApplicationController


  def index

    @candidato = Candidato.find params['candidato_id']
    @doador = Doador.find params['doador_id']

    @doacoes = @candidato.doacoes.do_doador(@doador.id)



  end


end
