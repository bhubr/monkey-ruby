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
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::EOF, "")
    ]

    l = Lexer.new(input)

    tests.each_with_index do |tt, index|
      tok = l.next_token

      if tok.type != tt.type
        raise "tests[#{index}] - tokentype wrong. expected=#{tt.type}, got=#{tok.type}"
      end

      if tok.literal != tt.literal
        raise "tests[#{index}] - literal wrong. expected=#{tt.literal}, got=#{tok.literal}"
      end

    end
  end
end
