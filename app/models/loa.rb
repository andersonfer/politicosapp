class LeiOrcamentariaAnual

  include Mongoid::Document

  field :ano, type:Integer, default:nil
  field :pdf, type:String, default:nil

  field :uniao_receita_estimada, type:Float, default:nil
  field :uniao_despesa_estimada, type:Float, default:nil

  field :orcamento_fiscal_receita_estimada, type:Float, default:nil
  field :orcamento_fiscal_despesa_estimada, type:Float, default:nil

  field :seguridade_social_receita_estimada, type:Float, default:nil
  field :seguridade_social_despesa_estimada, type:Float, default:nil
  field :seguridade_social_parcela_custeada_orcamento_fiscal, type:Float, default:nil

  field :refinanciamento_divida_publica_federal_receita_estimada, type:Float, default:nil
  field :refinanciamento_divida_publica_federal_despesa_estimada, type:Float, default:nil



  def self.insere_loa ano
    
    if ano == 2016
      
      loa = LeiOrcamentariaAnual.new

      loa.pdf = 'http://www.camara.gov.br/internet/comissao/index/mista/orca/orcamento/or2016/lei/Lei13255-2016.pdf'
      
      loa.uniao_receita_estimada = 3050613438544.0
      loa.uniao_despesa_estimada = 3050613438544.0

      loa.orcamento_fiscal_receita_estimada                       = 1425398520951.0
      loa.orcamento_fiscal_despesa_estimada                       = 1202774527131.0

      loa.seguridade_social_receita_estimada                      =  643147536053.0
      loa.seguridade_social_despesa_estimada                      =  865771529873.0
      loa.seguridade_social_parcela_custeada_orcamento_fiscal     =  222623993820.0

      loa.refinanciamento_divida_publica_federal_receita_estimada =  885000330304.0
      loa.refinanciamento_divida_publica_federal_despesa_estimada =  885000330304.0


    end

  end
end