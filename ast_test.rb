require "test/unit"
require_relative "./ast"
require_relative "./token"

class AstTest < Test::Unit::TestCase
  def test_string
    p = Program.new
    ls = LetStatement.new(
      Token.new(Token::LET, "let")
    )
    name_tok = Token.new(Token::IDENT, "myVar")
    ls.name = Identifier.new(name_tok, "myVar")
    value_tok = Token.new(Token::IDENT, "anotherVar")
    ls.value = Identifier.new(value_tok, "anotherVar")
    p.statements = [
      ls
    ]
    assert_equal p.string, "let myVar = anotherVar;", "program.string wrong. got #{p.string}"
  end
end
