require "test/unit"
require_relative "./token"
require_relative "./lexer"

class LexerTest < Test::Unit::TestCase
  def test_next_token
    input = <<-END
  let five = 5;
  let ten = 10;
  let add = fn(x, y) { x + y; };
  let sub = fn(x, y) { x - y; };
  let mul = fn(x, y) { x * y; };
  let div = fn(x, y) { x / y; };
  let add_res = add(five, ten);
  let sub_res = sub(ten, five);
  let mul_res = mul(add_res, sub_res);
  let div_res = div(mul_res, 2);
  let is_true = (4 < five);
  let is_false = (6 < five);
  false == true;
  false != true;
  !-/*5;
  5 < 6 > 5;
  if (5 < 10) { return true; }
  else { return false; }
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
      Token.new(Token::IDENT, "sub"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::FUNCTION, "fn"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::LBRACE, "{"),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::MINUS, "-"),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::RBRACE, "}"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "mul"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::FUNCTION, "fn"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::LBRACE, "{"),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::ASTERISK, "*"),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::RBRACE, "}"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "div"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::FUNCTION, "fn"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::LBRACE, "{"),
      Token.new(Token::IDENT, "x"),
      Token.new(Token::SLASH, "/"),
      Token.new(Token::IDENT, "y"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::RBRACE, "}"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "add_res"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::IDENT, "add"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "five"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "ten"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "sub_res"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::IDENT, "sub"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "ten"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "five"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "mul_res"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::IDENT, "mul"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "add_res"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::IDENT, "sub_res"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "div_res"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::IDENT, "div"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::IDENT, "mul_res"),
      Token.new(Token::COMMA, ","),
      Token.new(Token::INT, "2"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "is_true"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::INT, "4"),
      Token.new(Token::LT, "<"),
      Token.new(Token::IDENT, "five"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::LET, "let"),
      Token.new(Token::IDENT, "is_false"),
      Token.new(Token::ASSIGN, "="),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::INT, "6"),
      Token.new(Token::LT, "<"),
      Token.new(Token::IDENT, "five"),
      Token.new(Token::RPAREN, ")"), 
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::FALSE, "false"),
      Token.new(Token::EQ, "=="),
      Token.new(Token::TRUE, "true"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::FALSE, "false"),
      Token.new(Token::NOT_EQ, "!="),
      Token.new(Token::TRUE, "true"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::BANG, "!"),
      Token.new(Token::MINUS, "-"),
      Token.new(Token::SLASH, "/"),
      Token.new(Token::ASTERISK, "*"),
      Token.new(Token::INT, "5"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::INT, "5"),
      Token.new(Token::LT, "<"),
      Token.new(Token::INT, "6"),
      Token.new(Token::GT, ">"),
      Token.new(Token::INT, "5"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::IF, "if"),
      Token.new(Token::LPAREN, "("),
      Token.new(Token::INT, "5"),
      Token.new(Token::LT, "<"),
      Token.new(Token::INT, "10"),
      Token.new(Token::RPAREN, ")"),
      Token.new(Token::LBRACE, "{"),
      Token.new(Token::RETURN, "return"),
      Token.new(Token::TRUE, "true"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::RBRACE, "}"),
      Token.new(Token::ELSE, "else"),
      Token.new(Token::LBRACE, "{"),
      Token.new(Token::RETURN, "return"),
      Token.new(Token::FALSE, "false"),
      Token.new(Token::SEMICOLON, ";"),
      Token.new(Token::RBRACE, "}"),
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
