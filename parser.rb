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

    key_temporaria = ''
    numero_temporario = nil
    texto_temporario = ''

    aux_niveis_objeto = [] # Piilha para auxiliar na ordem de objetos filhos

    json.each_char.with_index do |char, index|
      puts "=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#{estado}=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
      puts "ANTES: Pilha: #{@pilha}"
      puts "Reading character #{char} at index #{index}"

      case [char, estado, @pilha.pop]

      in [/^\s$/, _, topo]
        @pilha.push(topo)

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
          obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
          obj_atual[key_temporaria] = nil
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
        estado = :q1

        topo = @pilha.pop
        @pilha.push(topo)

        if topo == '$'
          resultado[key_temporaria] = numero_temporario.to_i # TODO: por enquanto estamos aceitando somente inteiros
        elsif topo == 'O'
          obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
          obj_atual[key_temporaria] = numero_temporario.to_i # TODO: por enquanto estamos aceitando somente inteiros
        end

        key_temporaria = ''
        numero_temporario = nil

      in ['}', :q5, 'O']
        estado = :q20

        obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
        obj_atual[key_temporaria] = numero_temporario.to_i # TODO: por enquanto estamos aceitando somente inteiros

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
        estado = :q1

        topo = @pilha.pop
        @pilha.push(topo)

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
          obj_atual = resultado.dig(*aux_niveis_objeto)
          obj_atual[key_temporaria] = valor
        end

        key_temporaria = ''
        texto_temporario = ''

      in ['}', :q14, 'O']
        estado = :q20

        valor = nil
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

      in [/^[a-zA-Z]$/, :q7, topo] # TODO: estamos aceitando somente letras
        @pilha.push(topo)
        texto_temporario << char

      in ['"', :q7, 'WV']
        estado = :q19

        topo = @pilha.pop
        @pilha.push(topo)

        if topo == '$'
          resultado[key_temporaria] = texto_temporario
        elsif topo == 'O'
          obj_atual = resultado.dig(*aux_niveis_objeto)
          obj_atual[key_temporaria] = texto_temporario
        end

        key_temporaria = ''
        texto_temporario = ''

      in ['}', :q19, 'O']
        estado = :q20
        aux_niveis_objeto.pop

      in [',', :q19, topo]
        @pilha.push(topo)
        estado = :q1

      in ['}', :q19, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"
        break
      # END STR

      # START OBJ
      in ['{', :q4, topo]
        @pilha.push(topo)
        estado = :q1
        @pilha.push('O')

        if !aux_niveis_objeto.empty?
          obj_atual = resultado.dig(*aux_niveis_objeto) # esse asterisco passa o array como lista
          obj_atual[key_temporaria] = {}
        else
          resultado[key_temporaria] = {}
        end

        aux_niveis_objeto << key_temporaria
        key_temporaria = ''

      in ['}', :q20, 'O']
        estado = :q20
        aux_niveis_objeto.pop

      in ['}', :q20, '$']
        puts "DEPOIS: Pilha: #{@pilha}"
        estado = :q6
        puts "\nValid JSON!"

      in [',', :q20, topo]
        @pilha.push(topo)
        estado = :q1
      # END OBJ

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

json = '{"cu":"toba", "id": null, "nome": "Chrystian", "silvafeio":false, "idade": 21, "vivo":true, "sobrenome": "Oliveira", "obj": {"nome": "ERICKJOGANDOCLASHFDP", "fiofo": {"limpinho": "filhodamae","celular": null}}, "erick":"lindao", "yuri":{"cachorro":"aindaperde"}}'.freeze
parser = ParserJSON.new
resultado = parser.leituraJSON(json)

puts resultado
puts resultado['cu']
