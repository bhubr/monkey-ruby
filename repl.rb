require_relative "./lexer"
require_relative "./token"

PROMPT = ">> "

def start_repl
  while true
    print PROMPT
    scanned = gets
    if !scanned
      return
    end

    l = Lexer.new(scanned)
    loop do
      tok = l.next_token
      break if tok.type == Token::EOF
      puts "{Type:#{tok.type} Literal:#{tok.literal}}"
    end
  end
end 
