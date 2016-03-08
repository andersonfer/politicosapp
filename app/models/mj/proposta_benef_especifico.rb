class Mj::PropostaBenefEspecifico

  include Mongoid::Document


  field :ano_proposta,                :type=>String, :default=>nil
  field :nr_proposta,                 :type=>String, :default=>nil
  field :ano_convenio,                :type=>String, :default=>nil
  field :nr_convenio,                 :type=>String, :default=>nil
  field :tx_modalidade,               :type=>String, :default=>nil
  field :tx_situacao,                 :type=>String, :default=>nil
  field :tx_subsituacao,              :type=>String, :default=>nil
  field :cd_programa,                 :type=>String, :default=>nil
  field :cd_acao_programa,            :type=>String, :default=>nil
  field :nm_programa,                 :type=>String, :default=>nil
  field :cd_orgao_superior,           :type=>String, :default=>nil
  field :nm_orgao_superior,           :type=>String, :default=>nil
  field :cd_orgao_concedente,         :type=>String, :default=>nil
  field :nm_orgao_concedente,         :type=>String, :default=>nil
  field :cd_identif_proponente,       :type=>String, :default=>nil
  field :nm_proponente,               :type=>String, :default=>nil
  field :tx_esfera_adm_proponente,    :type=>String, :default=>nil
  field :tx_regiao_proponente,        :type=>String, :default=>nil
  field :uf_proponente,               :type=>String, :default=>nil
  field :nm_municipio_proponente,     :type=>String, :default=>nil
  field :dt_proposta,                 :type=>String, :default=>nil
  field :dt_inicio_vigencia,          :type=>String, :default=>nil
  field :dt_fim_vigencia,             :type=>String, :default=>nil
  field :dt_assinatura,               :type=>String, :default=>nil
  field :ano_assinatura,              :type=>String, :default=>nil
  field :mes_assinatura,              :type=>String, :default=>nil
  field :dt_publicacao,               :type=>String, :default=>nil
  field :vl_global,                   :type=>String, :default=>nil
  field :vl_repasse,                  :type=>String, :default=>nil
  field :vl_repasse_exerc_atual,      :type=>String, :default=>nil
  field :vl_contrapartida,            :type=>String, :default=>nil
  field :vl_contrapartida_financ,     :type=>String, :default=>nil
  field :vl_contrapartida_bens_serv,  :type=>String, :default=>nil
  field :tx_qualific_proponente,      :type=>String, :default=>nil
  field :in_parecer_gestor_sn,        :type=>String, :default=>nil
  field :in_parecer_juridico_sn,      :type=>String, :default=>nil
  field :in_parecer_tecnico_sn,       :type=>String, :default=>nil
  field :nm_respons_proponente,       :type=>String, :default=>nil
  field :cd_respons_proponente,       :type=>String, :default=>nil
  field :nm_respons_concedente,       :type=>String, :default=>nil
  field :cd_respons_concedente,       :type=>String, :default=>nil
  field :nm_banco,                    :type=>String, :default=>nil
  field :tx_objeto_convenio,          :type=>String, :default=>nil
  field :tx_justificativa,            :type=>String, :default=>nil
  field :nr_cnpj_benef_especifico,    :type=>String, :default=>nil
  field :nm_benef_especifico,         :type=>String, :default=>nil
  field :vl_repasse_benef_especifico, :type=>String, :default=>nil
  field :id_proposta,                 :type=>String, :default=>nil
  field :id_convenio,                 :type=>String, :default=>nil
  field :id_prop_programa,            :type=>String, :default=>nil


end
