class PartidosController < ApplicationController

  def index

    @consulta_partidos = Partido.desc(:_total_em_doacoes)

  end

end
