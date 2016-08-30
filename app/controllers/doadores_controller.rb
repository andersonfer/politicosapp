class DoadoresController < ApplicationController

  def index

    @doadores = Doador.all.order(_total_em_doacoes: :desc).page(params['page'])


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
      @totais_por_candidato[d.candidato_id.to_s] = {:direto=>{:total=>0.0, :qtde=>0},:indireto=>{:total=>0.0, :qtde=>0}} if not @totais_por_candidato[d.candidato_id.to_s]
      if d.doador_intermediario_id
        @totais_por_candidato[d.candidato_id.to_s][:indireto][:total] += d.valor
        @totais_por_candidato[d.candidato_id.to_s][:indireto][:qtde] += 1

      else
        @totais_por_candidato[d.candidato_id.to_s][:direto][:total] += d.valor
        @totais_por_candidato[d.candidato_id.to_s][:direto][:qtde] += 1

      end

    end

    @totais_por_candidato = @totais_por_candidato.sort_by {|candidato_id,valor| -(valor[:direto][:total] + valor[:indireto][:total])}


    @total = @doacoes.sum(:valor)

  end




end
