json = '{"id": 12345324234234,}'

class ParserJson
    def initialize
        @pilha = []
    end

    def push(e)
        if not e.nil?
            puts "Empilhou: " + e
            @pilha << e
        end
    end

    def pop
        @pilha.pop
    end

    def leituraJson(json)
        resultado = nil

        estado = :q0
        key_temporaria = ""
        numero_temporario = nil

        json.each_char.with_index do |char, index|
            puts "#{estado} Pilha: #{@pilha}"

            case [char, estado, @pilha.pop]
            in [/^\s$/, _, topo]
                @pilha.push(topo)
            in ["{", :q0, nil]
                estado = :q1
                @pilha.push("$")
                resultado = Hash.new
            in ['"', :q1, topo]
                @pilha.push(topo)
                estado = :q2
                @pilha.push("W")
            in [/^[a-zA-Z]$/, :q2, topo]
                @pilha.push(topo)
                estado = :q2
                key_temporaria << char
            in ['"', :q2, "W"]
                puts "#{key_temporaria}"
                estado = :q3
                resultado[key_temporaria] = nil
            in [":", :q3, topo]
                @pilha.push(topo)
                estado = :q4
                @pilha.push("P")
            # garantir que nao tem valores vazios
            in [/^\d$/, :q4, topo]
                @pilha.push(topo)
                estado = :q5
                numero_temporario = char
            in [/^\d$/, :q5, topo]
                @pilha.push(topo)
                numero_temporario << char
            in [",", :q5, "P"]
                estado = :q1
                resultado[key_temporaria] = numero_temporario
                key_temporaria = ""
                numero_temporario = nil
            in ["}", :q1, "$"]
                estado = :q6
                puts "JSON VÁLIDO"
            else
                puts "QUEBROUUUUUU #{char} #{index}"
                puts "#{estado}"
                break
            end
            puts "Character #{char} is at index #{index}"
        end
        return resultado
    end
end

# puts "Digite um JSON"
# name = gets.chomp
# puts name
teste = ParserJson.new
resultado = teste.leituraJson(json)

puts resultado["id"]