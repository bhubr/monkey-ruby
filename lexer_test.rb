require "test/unit"
require_relative "./token"
require_relative "./lexer"

class LexerTest < Test::Unit::TestCase
  def test_next_token
    input = <<-END
  let five = 5;
  let ten = 10;
  let add = fn(x, y) { x + y; };
  let result = add(five, ten);
    END

    tests = [
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "five"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::INT, "5"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "ten"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::INT, "10"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "add"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::FUNCTION, "fn"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::LBRACE, "{"),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::PLUS, "+"),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::RBRACE, "}"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "result"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::IDENT, "add"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "five"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "ten"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::EOF, "")
    ]

    l = Lexer.new(input)

    tests.each_with_index do |tt, index|
      tok = l.next_token
      assert_equal tt.type, tok.type, "tests[#{index}] - tokentype wrong. expected=#{tt.type}, got=#{tok.type}"
      assert_equal tt.literal, tok.literal, "tests[#{index}] - literal wrong. expected=#{tt.literal}, got=#{tok.literal}"
    end
  end
end
