class PartidosController < ApplicationController

  def index

    @consulta_partidos = Partido.page(params['page'])

    @partidos = {}

    Candidato.dos_partidos(@consulta_partidos.distinct(:id)).each do |c|

      @partidos[c.partido_id.to_s] = [] if not @partidos[c.partido_id.to_s]
      @partidos[c.partido_id.to_s] << c.id


    end

    @doacoes = {}

    @partidos.each do |partido_id,candidato_ids|

      Doacao.dos_candidatos(candidato_ids).each do |d|

        @doacoes[partido_id] = 0 if not @doacoes[partido_id]
        @doacoes[partido_id] += d.valor

      end

    end



  end

end
