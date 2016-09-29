class PartidosController < ApplicationController

  def index

    @consulta_partidos = Partido.all.desc([:_total_em_doacoes, :nome])

  end

end
