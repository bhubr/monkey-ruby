require_relative "./token"

def is_letter(ch)
  ch =~ /[_a-zA-Z]/
end

def is_digit(ch)
  ch =~ /\d/
end

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

  def peek_char
    if @read_position >= @input.length
      "\x00"
    else
      @input[@read_position]
    end
  end

  def read_identifier
    pos = @position
    while is_letter(@ch)
      read_char
    end
    @input[pos..@position - 1]
  end

  def read_integer
    pos = @position
    while is_digit(@ch)
      read_char
    end
    @input[pos..@position - 1]
  end

  def skip_whitespace
    while @ch =~ /\s/
      read_char
    end
  end

  def next_token
    tok = nil
    skip_whitespace
    case @ch
      when "="
	next_char = peek_char
	if next_char == "="
	  read_char
	  tok = Token.new(Token::EQ, "==")
	else
	  tok = Token.new(Token::ASSIGN, "=")
	end
      when "!"
        next_char = peek_char
        if next_char == "="
          read_char
          tok = Token.new(Token::NOT_EQ, "!=")
	else
	  tok = Token.new(Token::BANG, "!")
	end
      when "+"
        tok = Token.new(Token::PLUS, "+")
      when "-"
        tok = Token.new(Token::MINUS, "-")
      when "*"
        tok = Token.new(Token::ASTERISK, "*")
      when "/"
        tok = Token.new(Token::SLASH, "/")
      when "<"
        tok = Token.new(Token::LT, "<")
      when ">"
        tok = Token.new(Token::GT, ">")
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
      else
	if is_letter(@ch)
	  literal = read_identifier
	  tok = Token.new(Token.get_type(literal), literal)
          return tok
	elsif is_digit(@ch)
	  tok = Token.new(Token::INT, read_integer)
	  return tok
	else
          tok = Token.new(Token::ILLEGAL, @ch)
        end
    end
    if !tok
      raise "Unexpected token [#{@ch}]"
    end
    read_char
    tok
  end
end
