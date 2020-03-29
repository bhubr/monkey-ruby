require "test/unit"
require_relative "./ast"
require_relative "./lexer"
require_relative "./parser"

class ParserTest < Test::Unit::TestCase
  def t_let_statement(s, name)
    assert_equal s.token_literal, "let", "s.token_literal not 'let', got #{s.token_literal}"
    # p s
    # let_stmt = s.let_statement
    let_stmt_val = s.name.value
    assert_equal let_stmt_val, name, "let_stmt.name.value not '#{name}', got #{let_stmt_val}"
    let_stmt_literal = s.name.token_literal
    assert_equal let_stmt_literal, name, "let_stmt.name.token_literal not '#{name}', got #{let_stmt_literal}"
  end

  def test_let_statements  
    input = <<-END
      let x = 5;
      let y = 10;
      let foobar = 838383;
    END

    l = Lexer.new(input)
    p = Parser.new(l)

    program = p.parse_program
    assert_not_equal program, nil, "parse_program returned nil"

    assert_equal program.statements.length, 3, "program.statements does not contain 3 statements"

    tests = [
      "x", "y", "foobar"
    ]

    tests.each_with_index do |tt, index|
      stmt = program.statements[index]
      t_let_statement(stmt, tt)
    end
  end
end
