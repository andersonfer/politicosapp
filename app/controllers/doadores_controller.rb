class DoadoresController < ApplicationController

  def index

    @doadores = Doador.all.order(_total_em_doacoes: :desc).page(params['page'])

    @partidos = {}

    Partido.all.each do |p|
      @partidos[p.id.to_s] = p
    end


  end

  def show
    @doador = Doador.find params['id']

    @doacoes = @doador.doacoes
    @doacoes = @doacoes.do_candidato(params['candidato_id']) if not params['candidato_id'].blank?
    @doacoes = @doacoes.order(valor: :desc)
    candidato_ids = @doacoes.distinct(:candidato_id)

    @candidatos = {}

    Candidato.where(:id.in=>candidato_ids).each do |c|
      @candidatos[c.id.to_s] = c
    end

    @totais_por_candidato = {}

    @doacoes.each do |d|
      @totais_por_candidato[d.candidato_id.to_s] = {:total=>0.0, :qtde=>0} if not @totais_por_candidato[d.candidato_id.to_s]

      @totais_por_candidato[d.candidato_id.to_s][:total] += d.valor
      @totais_por_candidato[d.candidato_id.to_s][:qtde] += 1


    end

    @totais_por_candidato = @totais_por_candidato.sort_by {|candidato_id,valor| -valor[:total]}


    @total = @doacoes.sum(:valor)

  end




end
