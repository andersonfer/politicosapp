

namespace :mj do

  
  desc "importa models: proposta_benef_especifico"
  task :importa_csvs => :environment do

    arqs_models = {"arquivos_mj/01_ConveniosProgramas.csv" =>         Mj::ConvenioProgramas,
                   "arquivos_mj/03_Empenhos.csv" =>                   Mj::Empenho,
                   "arquivos_mj/04_ExecucaoFinanceira.csv" =>         Mj::ExecucaoFinanceira,
                   "arquivos_mj/05_PropostasPrograma.csv" =>          Mj::PropostaPrograma,
                   "arquivos_mj/07_PropostasDadosBancarios.csv" =>    Mj::PropostaDadosBancarios,
                   "arquivos_mj/08_PropostasDadosResponsaveis.csv" => Mj::PropostaDadosResponsaveis,
                   "arquivos_mj/09_PropostasDadosProponente.csv" =>   Mj::PropostaDadosProponente,
                   "arquivos_mj/10_PropostasEmendaParlamentar.csv" => Mj::PropostaEmendaParlamentar,
                   "arquivos_mj/11_PropostasBenefEspecifico.csv" =>   Mj::PropostaBenefEspecifico,
                   "arquivos_mj/14_Programas.csv" =>                  Mj::Programa,
                   "arquivos_mj/15_ProgramasUFHabilitadas.csv" =>     Mj::ProgramaUfHabilitada,
                   "arquivos_mj/16_Documento_Liquidacao.csv" =>       Mj::DocumentoLiquidacao,
                   "arquivos_mj/17_Pagamento_OBTV.csv" =>             Mj::PagamentoObtv,
                   "arquivos_mj/18_Discriminacao_OBTV.csv" =>         Mj::DiscriminacaoObtv,
                   "arquivos_mj/19_CronogramaFisicoPT.csv" =>         Mj::CronogramaFisicoPt,
                   "arquivos_mj/20_CronogramaDesembolsoPT.csv" =>     Mj::CronogramaDesembolsoPt,
                   "arquivos_mj/21_PlanoAplicacaoPT.csv" =>           Mj::PlanoAplicacaoPt}

    arqs_models.each do |path_arquivo, model|

      puts "\n=== Importando arquivo #{path_arquivo}. Cada ponto são 500 modelos inseridos no banco."

      File.open(path_arquivo) do |f| 

        linha = f.readline
        campos = linha.split(';').map{|el| el.gsub('"', '').strip.downcase}

        contador = 0
        begin
          
          while linha = f.readline

            # cria uma instância sem nada,
            model_pra_gravar = model.new

            # preenche com os dados da linha
            linha.split(';').each_with_index do |valor, index|
              valor = valor.gsub('"', '').strip
              model_pra_gravar[campos[index]] = valor
            end

            # e salva
            model_pra_gravar.save!

            contador += 1
            print '.' if contador % 500 == 499
          end

        rescue Exception => e
          # o readline deu pau e acabou o arquivo
          puts "\nfim\n"
        end
      end

    end


  end

end
