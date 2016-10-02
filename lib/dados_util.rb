class DadosUtil

  def self.percorrer_paginado(consulta, tamanho_pagina)
    total = consulta.count
    puts "São #{total}. Cada ponto são #{tamanho_pagina} documentos." unless Rails.env.test?
    ultimo = 0
    while ultimo < total do
      count = 0
      consulta.skip(ultimo).limit(tamanho_pagina).each do |model|
        if (count+=1) % tamanho_pagina == 0
          print '.' unless Rails.env.test?
        end
        yield(model)
      end
      ultimo += tamanho_pagina
    end
  end



end
