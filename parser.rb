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

      in [/^[a-zA-Z]$/, :q2, topo] # TODO: por enquanto so aceitamos letras no key
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
              arr_atual << numero_temporario.to_i
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

        aux_niveis_objeto.pop

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
              arr_atual << numero_temporario.to_f
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

        aux_niveis_objeto.pop

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
              arr_atual << valor
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

        obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
        obj_atual[key_temporaria] = valor

        aux_niveis_objeto.pop

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

      in [/^[a-zA-Z0-9.\-:,\s]$/, :q7, topo] # TODO: estamos aceitando somente letras
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
              arr_atual << texto_temporario
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
        aux_niveis_objeto.pop

        topo = @pilha.pop
        @pilha.push(topo)

        if topo == 'A'
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
        @pilha.push('O')

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
            arr_atual = {}
            ultimo_index = aux_niveis_array.pop
            temp = resultado.dig(*aux_niveis_array)
            temp[key_temporaria] = arr_atual
            aux_niveis_array.push(ultimo_index)
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

      in ['}', :q20, 'O']
        estado = :q20
        aux_niveis_objeto.pop

        topo = @pilha.pop
        @pilha.push(topo)

        if topo == 'A'
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
        aux_niveis_array.pop

      in ['}', :q21, 'O']
        estado = :q20
        aux_niveis_objeto.pop

        topo = @pilha.pop
        @pilha.push(topo)

        if topo == 'A'
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

#json = '{"cu": [{"abc": 20, "cba": [0,2]}, 3, "teste"]}'
json = '{
  "glossary": {
      "title": "example glossary",
  "GlossDiv": {
          "title": "S",
    "GlossList": {
              "GlossEntry": {
                  "ID": "SGML",
        "SortAs": "SGML",
        "GlossTerm": "Standard Generalized Markup Language",
        "Acronym": "SGML",
        "Abbrev": "ISO 8879:1986",
        "GlossDef": {
                      "para": "A meta-markup language, used to create markup languages such as DocBook.",
          "GlossSeeAlso": ["GML", "XML"]
                  },
        "GlossSee": "markup"
              }
          }
      }
  }
}'

parser = ParserJSON.new
resultado = parser.leituraJSON(json)

puts resultado
