require "test/unit"
require_relative "./token"
require_relative "./lexer"

class LexerTest < Test::Unit::TestCase
  def test_next_token
    input = "=+(){},;"

    tests = [
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::PLUS, "+"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::LBRACE, "{"),
      Token.new(Token::RBRACE, "}"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::SEMICOLON, ","),
      Token.new(Token::EOF, "")
    ]

    l = Lexer.new(input)
  end
end
