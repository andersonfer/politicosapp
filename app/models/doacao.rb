class Doacao

  include Mongoid::Document

  #valor em centavos
  field :valor,             :type=>Integer, :default=>nil
  field :data,              :type=>Time, default:nil
  field :nro_recibo,        :type=>String, :default=>nil
  field :especie_recurso,   :type=>String, :default=>nil
  field :fonte_recurso,     :type=>String, :default=>nil
  field :nro_documento,     :type=>String, :default=>nil


  belongs_to :candidato, :inverse_of=>nil
  belongs_to :doador, :inverse_of=>nil
  belongs_to :doador_originario, :inverse_of=>nil, :class_name=>'Doador'



end
