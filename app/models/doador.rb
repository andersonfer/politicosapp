class Doador

  include Mongoid::Document

  field :nome, type:String, default:nil
  field :cnpj_cpf, type:String, default:nil


  validates_uniqueness_of :cnpj_cpf


end
