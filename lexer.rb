require_relative "./token"

class Lexer
  def initialize(input)
    @input = input
    @read_position = 0
    @position = 0
    read_char
  end

  def read_char
    if @read_position >= @input.length
      @ch = "\x00"
    else
      @ch = @input[@read_position]
    end
    @position = @read_position
    @read_position += 1
  end

  def next_token
    tok = nil
    case @ch
      when "="
        tok = Token.new(Token::ASSIGN, "=")
      when "+"
        tok = Token.new(Token::PLUS, "+")
      when ";"
        tok = Token.new(Token::SEMICOLON, ";")
      when ","
        tok = Token.new(Token::COMMA, ",")
      when "("
        tok = Token.new(Token::LPAREN, "(")
      when ")"
        tok = Token.new(Token::RPAREN, ")")
      when "{"
        tok = Token.new(Token::LBRACE, "{")
      when "}"
        tok = Token.new(Token::RBRACE, "}")
      when "\x00"
        tok = Token.new(Token::EOF,"")
    end
    read_char
    tok
  end
end
