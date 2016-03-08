# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end



ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'ConvenioProgramas', 'ConveniosProgramas'
  inflect.plural 'Empenho', 'Empenhos'
  inflect.plural 'ExecucaoFinanceira', 'ExecucoesFinanceira'
  inflect.plural 'PropostaPrograma', 'PropostasPrograma'
  inflect.plural 'PropostaDadosBancarios', 'PropostasDadosBancarios'
  inflect.plural 'PropostaDadosResponsaveis', 'PropostasDadosResponsaveis'
  inflect.plural 'PropostaDadosProponente', 'PropostasDadosProponente'
  inflect.plural 'PropostaEmendaParlamentar', 'PropostasEmendaParlamentar'
  inflect.plural 'PropostaBenefEspecifico', 'PropostasBenefEspecifico'
  inflect.plural 'Programa', 'Programas'
  inflect.plural 'ProgramaUfHabilitada', 'ProgramaUfHabilitadas'
  inflect.plural 'DocumentoLiquidacao', 'DocumentosLiquidacao'
  inflect.plural 'PagamentoObtv', 'PagamentosObtv'
  inflect.plural 'DiscriminacaoObtv', 'DiscriminacoesObtv'
  inflect.plural 'CronogramaFisicoPt', 'CronogramasFisicoPt'
  inflect.plural 'CronogramaDesembolsoPt', 'CronogramasDesembolsoPt'
  inflect.plural 'PlanoAplicacaoPt', 'PlanosAplicacaoPt'

end
