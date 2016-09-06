class PartidosController < ApplicationController

  def index

    @consulta_partidos = Partido.desc(:_total_em_doacoes).page(params['page'])

  end

end
