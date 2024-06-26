# This class is used to parse the JSON
class ParserJSON
  def initialize
    @pilha = []
  end

  def push(estado)
    return if e.nil?

    puts "Empilhou: #{estado}"
    @pilha << e
  end

  def pop
    @pilha.pop
  end

  def leituraJSON(json)
    resultado = nil

    estado = :q0

    # key_array = ''

    key_temporaria = ''
    numero_temporario = nil
    texto_temporario = ''

    aux_niveis_objeto = [] # Pilha para auxiliar na ordem de objetos aninhados
    aux_niveis_array = []

    json.each_char.with_index do |char, index|
      puts "=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#{estado}=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
      puts "ANTES: Pilha: #{@pilha}"
      puts "Reading character #{char} at index #{index}"

      case [char, estado, @pilha.pop]

      in ['{', :q0, nil]
        estado = :q1
        @pilha.push('$')
        resultado = {}

      in ['"', :q1, topo]
        @pilha.push(topo)
        estado = :q2
        @pilha.push('WK')

      in [/^[a-zA-Z0-9.\-:,\s=;\/@\?&\*]$/, :q2, topo] # TODO: por enquanto so aceitamos letras no key
        @pilha.push(topo)
        estado = :q2
        key_temporaria << char

      in ['"', :q2, 'WK']
        estado = :q3

        topo = @pilha.pop
        @pilha.push(topo)

        if topo == '$'
          resultado[key_temporaria] = nil
        elsif topo == 'O'
          if !aux_niveis_array.empty?

            if !aux_niveis_objeto.empty?
              obj_atual = resultado.dig(*aux_niveis_objeto)
              arr_atual = obj_atual.dig(*aux_niveis_array)
            else
              arr_atual = resultado.dig(*aux_niveis_array)
            end

            arr_atual[key_temporaria] = nil
          elsif !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto)
            obj_atual[key_temporaria] = nil
          end
          # obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
          # obj_atual[key_temporaria] = nil
        end

      in [':', :q3, topo]
        @pilha.push(topo)
        estado = :q4

      # START NUM
      in [/^\d$/, :q4, topo] # garantir que nao tem valores vazios
        @pilha.push(topo)
        estado = :q5
        numero_temporario = char

      in [/^\d$/, :q5, topo]
        @pilha.push(topo)
        numero_temporario << char

      in [',', :q5, topo]
        @pilha.push(topo)

        estado = if topo == 'A'
                   :q4
                 else
                   :q1
                 end

        if topo == '$'
          resultado[key_temporaria] = numero_temporario.to_i
        elsif topo == 'O'
          if !aux_niveis_array.empty?
            if !aux_niveis_objeto.empty?
              obj_atual = resultado.dig(*aux_niveis_objeto)
              arr_atual = obj_atual.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = numero_temporario.to_i
            else
              arr_atual = resultado.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = numero_temporario.to_i
            end
          elsif !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
            obj_atual[key_temporaria] = numero_temporario.to_i
          end
          # obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
          # obj_atual[key_temporaria] = numero_temporario.to_i
        elsif topo == 'A'
          if !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto)
            arr_atual = obj_atual.dig(*aux_niveis_array)
            arr_atual << numero_temporario.to_i
          else
            arr_atual = resultado.dig(*aux_niveis_array)
            arr_atual << numero_temporario.to_i
          end
        end

        key_temporaria = ''
        numero_temporario = nil

      in [']', :q5, 'A']
        estado = :q21

        # arr_atual = resultado.dig(*aux_niveis_array) # esse asterisco passa o array como lista
        # arr_atual << numero_temporario.to_i
        if !aux_niveis_objeto.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto)
          arr_atual = obj_atual.dig(*aux_niveis_array)
          arr_atual << numero_temporario.to_i
        else
          arr_atual = resultado.dig(*aux_niveis_array)
          arr_atual << numero_temporario.to_i
        end

        aux_niveis_array.pop

        key_temporaria = ''
        numero_temporario = nil

      in ['}', :q5, 'O']
        estado = :q20

        if !aux_niveis_array.empty?

          if !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto)
            arr_atual = obj_atual.dig(*aux_niveis_array)
          else
            arr_atual = resultado.dig(*aux_niveis_array)
          end

          arr_atual[key_temporaria] = numero_temporario.to_i
          aux_niveis_array.pop
        elsif !aux_niveis_objeto.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto)
          obj_atual[key_temporaria] = numero_temporario.to_i
        end

        # obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
        # obj_atual[key_temporaria] = numero_temporario.to_i # TODO: por enquanto estamos aceitando somente inteiros

        if !@pilha.include?('O') 
          aux_niveis_objeto.pop
        end

        key_temporaria = ''
        numero_temporario = nil

      in ['}', :q5, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"
        resultado[key_temporaria] = numero_temporario.to_i # TODO: por enquanto estamos aceitando somente inteiros
        key_temporaria = ''
        numero_temporario = nil
        break

      in ['.', :q5, topo]
        @pilha.push(topo)
        estado = :q50
        numero_temporario << char

      in [/^\d$/, :q50, topo]
        @pilha.push(topo)
        numero_temporario << char

      in [',', :q50, topo]
        @pilha.push(topo)

        estado = if topo == 'A'
                   :q4
                 else
                   :q1
                 end

        if topo == '$'
          resultado[key_temporaria] = numero_temporario.to_f
        elsif topo == 'O'
          if !aux_niveis_array.empty?
            if !aux_niveis_objeto.empty?
              obj_atual = resultado.dig(*aux_niveis_objeto)
              arr_atual = obj_atual.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = numero_temporario.to_f
            else
              arr_atual = resultado.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = numero_temporario.to_f
            end
          elsif !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
            obj_atual[key_temporaria] = numero_temporario.to_f
          end
          # obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
          # obj_atual[key_temporaria] = numero_temporario.to_f
        elsif topo == 'A'
          if !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto)
            arr_atual = obj_atual.dig(*aux_niveis_array)
            arr_atual << numero_temporario.to_f
          else
            arr_atual = resultado.dig(*aux_niveis_array)
            arr_atual << numero_temporario.to_f
          end
        end

        key_temporaria = ''
        numero_temporario = nil

      in [']', :q50, 'A']
        estado = :q21

        # arr_atual = resultado.dig(*aux_niveis_array) # esse asterisco passa o array como list
        # arr_atual << numero_temporario.to_f

        if !aux_niveis_objeto.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto)
          arr_atual = obj_atual.dig(*aux_niveis_array)
          arr_atual << numero_temporario.to_f
        else
          arr_atual = resultado.dig(*aux_niveis_array)
          arr_atual << numero_temporario.to_f
        end

        aux_niveis_array.pop

        key_temporaria = ''
        numero_temporario = nil

      in ['}', :q50, 'O']
        estado = :q20

        obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
        obj_atual[key_temporaria] = numero_temporario.to_f

        if !@pilha.include?('O') 
          aux_niveis_objeto.pop
        end

        key_temporaria = ''
        numero_temporario = nil

      in ['}', :q50, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"
        resultado[key_temporaria] = numero_temporario.to_f
        key_temporaria = ''
        numero_temporario = nil
        break
      # END NUM

      # START BOOL
      in [/^(t|f|n)$/, :q4, topo]
        @pilha.push(topo)
        estado = :q14
        texto_temporario << char

      in [/^[rueals]$/, :q14, topo]
        @pilha.push(topo)
        texto_temporario << char

      in [',', :q14, topo]
        @pilha.push(topo)

        estado = if topo == 'A'
                   :q4
                 else
                   :q1
                 end

        valor = nil
        if texto_temporario == 'true'
          valor = true
        elsif texto_temporario == 'false'
          valor = false
        elsif texto_temporario == 'null'
          valor = nil
        end

        if topo == '$'
          resultado[key_temporaria] = valor
        elsif topo == 'O'
          if !aux_niveis_array.empty?
            if !aux_niveis_objeto.empty?
              obj_atual = resultado.dig(*aux_niveis_objeto)
              arr_atual = obj_atual.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = valor
            else
              arr_atual = resultado.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = valor
            end
          elsif !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
            obj_atual[key_temporaria] = valor
          end
          # obj_atual = resultado.dig(*aux_niveis_objeto)
          # obj_atual[key_temporaria] = valor
        elsif topo == 'A'
          if !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto)
            arr_atual = obj_atual.dig(*aux_niveis_array)
            arr_atual << valor
          else
            arr_atual = resultado.dig(*aux_niveis_array)
            arr_atual << valor
          end
        end

        key_temporaria = ''
        texto_temporario = ''

      in [']', :q14, 'A']
        estado = :q21

        valor = nil
        if texto_temporario == 'true'
          valor = true
        elsif texto_temporario == 'false'
          valor = false
        elsif texto_temporario == 'null'
          valor = nil
        end

        # arr_atual = resultado.dig(*aux_niveis_array)
        # arr_atual << valor

        if !aux_niveis_objeto.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto)
          arr_atual = obj_atual.dig(*aux_niveis_array)
          arr_atual << valor
        else
          arr_atual = resultado.dig(*aux_niveis_array)
          arr_atual << valor
        end

        aux_niveis_array.pop

        key_temporaria = ''
        texto_temporario = ''

      in ['}', :q14, 'O']
        estado = :q20

        valor = nil # TODO: se estiver escrito "fals" ou "tru", ele aceita....
        if texto_temporario == 'true'
          valor = true
        elsif texto_temporario == 'false'
          valor = false
        elsif texto_temporario == 'null'
          valor = nil
        end

        if !aux_niveis_array.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto)
          arr_atual = obj_atual.dig(*aux_niveis_array)
          arr_atual[key_temporaria] = valor
        else
          obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
          obj_atual[key_temporaria] = valor
        end

        if !@pilha.include?('O') 
          aux_niveis_objeto.pop
        end

        key_temporaria = ''
        texto_temporario = ''

      in ['}', :q14, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"

        if texto_temporario == 'true'
          resultado[key_temporaria] = true
        elsif texto_temporario == 'false'
          resultado[key_temporaria] = false
        elsif texto_temporario == 'null'
          resultado[key_temporaria] = nil
        end

        key_temporaria = ''
        texto_temporario = ''
        break
      # END BOOL

      # START STR
      in ['"', :q4, topo]
        @pilha.push(topo)
        estado = :q7
        @pilha.push('WV')

      in [/^[a-zA-Z0-9.\-:,\s=;\/@\?&\*]$/, :q7, topo] # TODO: estamos aceitando somente letras
        @pilha.push(topo)
        texto_temporario << char

      in ['"', :q7, 'WV']
        estado = :q19

        topo = @pilha.pop
        @pilha.push(topo)

        if topo == '$'
          resultado[key_temporaria] = texto_temporario
        elsif topo == 'O'
          if !aux_niveis_array.empty?
            if !aux_niveis_objeto.empty?
              obj_atual = resultado.dig(*aux_niveis_objeto)
              arr_atual = obj_atual.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = texto_temporario
            else
              arr_atual = resultado.dig(*aux_niveis_array)
              arr_atual[key_temporaria] = texto_temporario
            end
          elsif !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
            obj_atual[key_temporaria] = texto_temporario
          end
          # obj_atual = resultado.dig(*aux_niveis_objeto)
          # obj_atual[key_temporaria] = texto_temporario
        elsif topo == 'A'
          if !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto)
            arr_atual = obj_atual.dig(*aux_niveis_array)
            arr_atual << texto_temporario
          else
            arr_atual = resultado.dig(*aux_niveis_array)
            arr_atual << texto_temporario
          end
        end

        key_temporaria = ''
        texto_temporario = ''

      in ['}', :q19, 'O']
        estado = :q20

        if !@pilha.include?('O') || aux_niveis_objeto.length > 1
          aux_niveis_objeto.pop
        end

        if aux_niveis_array.length > 1
          aux_niveis_array.pop
        end

      in [',', :q19, topo]
        @pilha.push(topo)

        estado = if topo == 'A'
                   :q4
                 else
                   :q1
                 end

      in ['}', :q19, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"
        break

      in [']', :q19, 'A']
        estado = :q21
        aux_niveis_array.pop
      # END STR

      # START OBJ
      in ['{', :q4, topo]
        @pilha.push(topo)
        estado = :q1

        if !aux_niveis_array.empty?

          if !aux_niveis_objeto.empty?
            if key_temporaria != ''
              aux_niveis_array << key_temporaria
            end
            obj_atual = resultado.dig(*aux_niveis_objeto)
            arr_atual = obj_atual.dig(*aux_niveis_array)
          else
            if key_temporaria != ''
              aux_niveis_array << key_temporaria
            end
            arr_atual = resultado.dig(*aux_niveis_array)
          end

          if arr_atual == nil
            arr_atual = {}
            ultimo_index = nil

            if aux_niveis_array.length > 1
                ultimo_index = aux_niveis_array.pop
            end

            temp = if aux_niveis_objeto.length >= 1
                     obj_atual.dig(*aux_niveis_array)
                   else
                     resultado.dig(*aux_niveis_array)
                   end
            temp[key_temporaria] = arr_atual
            if !ultimo_index.nil?
              aux_niveis_array.push(ultimo_index)
            end
          else
            size = arr_atual.length 
            aux_niveis_array << size
            arr_atual << {}
          end
        elsif !aux_niveis_objeto.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto)
          obj_atual[key_temporaria] = {}
          aux_niveis_objeto << key_temporaria
        else
          resultado[key_temporaria] = {}
          aux_niveis_objeto << key_temporaria
        end

      # if !aux_niveis_objeto.empty?
      #   obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
      #   obj_atual[key_temporaria] = {}
      # else
      #   resultado[key_temporaria] = {}
      # end,

      # aux_niveis_objeto << key_temporaria
      key_temporaria = ''
      @pilha.push('O')

      in ['}', :q20, 'O']
        estado = :q20

        if !@pilha.include?('O') || aux_niveis_objeto.length > 1
          aux_niveis_objeto.pop
        end

        if aux_niveis_array.length > 1
          aux_niveis_array.pop
        end

      in ['}', :q20, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"

      in [',', :q20, topo]
        @pilha.push(topo)

        if topo == 'A'
          estado = :q4
          # aux_niveis_array.pop
        else
          estado = :q1
        end

      in [']', :q20, topo]
        #@pilha.push(topo)
        estado = :q20
        
        if !@pilha.include?('A')
          aux_niveis_array.clear
        else
          aux_niveis_array.pop
        end

      # END OBJ

      # START ARR
      in ['[', :q4, topo]
        @pilha.push(topo)
        estado = :q4
        @pilha.push('A')

        # if (aux_niveis_array.empty? && aux_niveis_objeto.empty?) || key_temporaria != ''
        #   # arr_atual = obj_atual.dig(*aux_niveis_array)
        #   # arr_atual = []
        #   resultado[key_temporaria] = []
        #   aux_niveis_array << key_temporaria
        if !aux_niveis_array.empty?
          if !aux_niveis_objeto.empty?
            obj_atual = resultado.dig(*aux_niveis_objeto)
            arr_atual = obj_atual.dig(*aux_niveis_array)
          else
            if key_temporaria != ''
              aux_niveis_array << key_temporaria
            end
            arr_atual = resultado.dig(*aux_niveis_array)
          end

          if arr_atual == nil
            arr_atual = []
            ultimo_index = aux_niveis_array.pop
            temp = resultado.dig(*aux_niveis_array)
            temp[key_temporaria] = arr_atual
            aux_niveis_array.push(ultimo_index)
          else
            size = arr_atual.length
            aux_niveis_array << size
            arr_atual << []
          end
        elsif !aux_niveis_objeto.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto)
          obj_atual[key_temporaria] = []
          aux_niveis_array << key_temporaria
        else
          resultado[key_temporaria] = []
          aux_niveis_array << key_temporaria
        end

        # key_array = key_temporaria
        # resultado[key_array] = []
        key_temporaria = ''

      in [',', :q21, topo]
        @pilha.push(topo)
        estado = if topo == 'A'
                   :q4
                 else
                   :q1
                 end

      in [']', :q21, 'A']
        estado = :q21

        if !@pilha.include?('A')
          aux_niveis_array.clear
        else
          aux_niveis_array.pop
        end

      in ['}', :q21, 'O']
        estado = :q20

        if !@pilha.include?('O') || aux_niveis_objeto.length > 1
          aux_niveis_objeto.pop
        end

        if aux_niveis_array.length > 1
          aux_niveis_array.pop
        end

      in ['}', :q21, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"
      # END ARR

      in [/^\s$/, _, topo]
        @pilha.push(topo)

      else
        puts "DEPOIS: Pilha: #{@pilha}"

        puts resultado

        resultado = nil # Dont return a valid object if json is wrong
        puts "\nInvalid JSON! Error in character #{char} at index #{index}"
        break
      end
      puts "DEPOIS: Pilha: #{@pilha}"
    end
    resultado
  end
end

json = '{"web-app": {
  "servlet": [
    {
      "servlet-name": "cofaxCDS",
      "servlet-class": "org.cofax.cds.CDSServlet",
      "init-param": {
        "configGlossary:installationAt": "Philadelphia, PA",
        "configGlossary:adminEmail": "ksm@pobox.com",
        "configGlossary:poweredBy": "Cofax",
        "configGlossary:poweredByIcon": "/images/cofax.gif",
        "configGlossary:staticPath": "/content/static",
        "templateProcessorClass": "org.cofax.WysiwygTemplate",
        "templateLoaderClass": "org.cofax.FilesTemplateLoader",
        "templatePath": "templates",
        "templateOverridePath": "",
        "defaultListTemplate": "listTemplate.htm",
        "defaultFileTemplate": "articleTemplate.htm",
        "useJSP": false,
        "jspListTemplate": "listTemplate.jsp",
        "jspFileTemplate": "articleTemplate.jsp",
        "cachePackageTagsTrack": 200,
        "cachePackageTagsStore": 200,
        "cachePackageTagsRefresh": 60,
        "cacheTemplatesTrack": 100,
        "cacheTemplatesStore": 50,
        "cacheTemplatesRefresh": 15,
        "cachePagesTrack": 200,
        "cachePagesStore": 100,
        "cachePagesRefresh": 10,
        "cachePagesDirtyRead": 10,
        "searchEngineListTemplate": "forSearchEnginesList.htm",
        "searchEngineFileTemplate": "forSearchEngines.htm",
        "searchEngineRobotsDb": "WEB-INF/robots.db",
        "useDataStore": true,
        "dataStoreClass": "org.cofax.SqlDataStore",
        "redirectionClass": "org.cofax.SqlRedirection",
        "dataStoreName": "cofax",
        "dataStoreDriver": "com.microsoft.jdbc.sqlserver.SQLServerDriver",
        "dataStoreUrl": "jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon",
        "dataStoreUser": "sa",
        "dataStorePassword": "dataStoreTestQuery",
        "dataStoreTestQuery": "SET NOCOUNT ON;select test=;",
        "dataStoreLogFile": "/usr/local/tomcat/logs/datastore.log",
        "dataStoreInitConns": 10,
        "dataStoreMaxConns": 100,
        "dataStoreConnUsageLimit": 100,
        "dataStoreLogLevel": "debug",
        "maxUrlLength": 500}},
    {
      "servlet-name": "cofaxEmail",
      "servlet-class": "org.cofax.cds.EmailServlet",
      "init-param": {
      "mailHost": "mail1",
      "mailHostOverride": "mail2"}},
    {
      "servlet-name": "cofaxAdmin",
      "servlet-class": "org.cofax.cds.AdminServlet"},
    {
      "servlet-name": "fileServlet",
      "servlet-class": "org.cofax.cds.FileServlet"},
    {
      "servlet-name": "cofaxTools",
      "servlet-class": "org.cofax.cms.CofaxToolsServlet",
      "init-param": {
        "templatePath": "toolstemplates/",
        "log": 1,
        "logLocation": "/usr/local/tomcat/logs/CofaxTools.log",
        "logMaxSize": "",
        "dataLog": 1,
        "dataLogLocation": "/usr/local/tomcat/logs/dataLog.log",
        "dataLogMaxSize": "",
        "removePageCache": "/content/admin/remove?cache=pages&id=",
        "removeTemplateCache": "/content/admin/remove?cache=templates&id=",
        "fileTransferFolder": "/usr/local/tomcat/webapps/content/fileTransferFolder",
        "lookInContext": 1,
        "adminGroupID": 4,
        "betaServer": true}}],
  "servlet-mapping": {
    "cofaxCDS": "/",
    "cofaxEmail": "/cofaxutil/aemail/*",
    "cofaxAdmin": "/admin/*",
    "fileServlet": "/static/*",
    "cofaxTools": "/tools/*"},
  "taglib": {
    "taglib-uri": "cofax.tld",
    "taglib-location": "/WEB-INF/tlds/cofax.tld"}}}'
# json = '{
#   "glossary": {
#       "title": "example glossary",
#       "GlossDiv": {
#           "title": "S",
#           "GlossList": {
#               "GlossEntry": {
#                   "ID": "SGML",
#                   "SortAs": "SGML",
#                   "GlossTerm": "Standard Generalized Markup Language",
#                   "Acronym": "SGML",
#                   "Abbrev": "ISO 8879:1986",
#                   "GlossDef": {
#                       "para": "A meta-markup language, used to create markup languages such as DocBook.",
#                       "GlossSeeAlso": ["GML", "XML"]
#                   },
#                   "GlossSee": "markup"
#               }
#           }
#       }
#   }
# }'
parser = ParserJSON.new
resultado = parser.leituraJSON(json)

puts resultado
