module ApplicationHelper

	def menu_interno
		if request.path.gsub(/\?.*/, '').include?(usuarios_path)
			menu_usuarios
		end
	end

	def menu_usuarios
		links = {}
		links['lista'] = {'path'=>usuarios_path}
		links['novo'] = {'path'=>new_usuario_path}

		links.each do |nome, dados|
			if dados['path']==request.path.gsub(/\?.*/, '')
				links[nome]['ativo'] = true
			else
				links[nome]['ativo'] = false
			end 
		end
		links
	end

end
