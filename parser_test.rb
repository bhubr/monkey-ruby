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

  def t_integer_literal(il, value)
    assert_equal il.value, value, "il.value not #{value}, got #{il.value}"
    assert_equal il.token_literal, "#{value}", "il.token_literal not '#{value}', got '#{il.token_literal}'"
  end

  def check_parser_errors(p)
    errors = p.errors
    if (errors.length == 0)
      return
    end
    errors.each do |err|
      puts "parser error: #{err}"
    end
    assert_equal errors.length, 0, "parser had #{errors.length} error(s)"
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
    check_parser_errors(p)

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

  def test_return_statements  
    input = <<-END
      return 5;
      return 10;
      return 993322;
    END

    l = Lexer.new(input)
    p = Parser.new(l)

    program = p.parse_program
    check_parser_errors(p)

    assert_not_equal program, nil, "parse_program returned nil"
    assert_equal program.statements.length, 3, "program.statements does not contain 3 statements"

    program.statements.each do |stmt|
      stmt_class = stmt.class.name
      assert_equal stmt.class.name, "ReturnStatement", "stmt not ReturnStatement, got #{stmt_class}"
      assert_equal stmt.token_literal, "return", "return_stmt.token_literal not 'return', got #{stmt.token_literal}"
    end
  end

  def test_identifier_expression
    input = "foobar;"
    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program
    check_parser_errors(p)
    stmts_len = program.statements.length
    assert_equal stmts_len, 1, "program has not enough statements. got=#{stmts_len}"
    stmt = program.statements[0]
    ident = stmt.expression
    assert_equal ident.value, "foobar", "ident.value not 'foobar'. got=#{ident.value}"
    assert_equal ident.token_literal, "foobar", "ident.token_literal not 'foobar'. got #{ident.token_literal}"
  end

  def test_integer_expression
    input = "55;"
    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program
    check_parser_errors(p)
    stmts_len = program.statements.length
    assert_equal stmts_len, 1, "program has not enough statements. got=#{stmts_len}"
    stmt = program.statements[0]
    int = stmt.expression
    assert_equal int.value, 55, "int.value not 55. got=#{int.value}"
    assert_equal int.token_literal, "55", "int.token_literal not '55'. got #{int.token_literal}"
  end

  def test_parsing_prefix_expressions
    prefix_tests = [
      {
        :input => "!5;",
        :operator => "!",
        :int_val => 5
      },
      {
        :input => "-15;",
        :operator => "-",
        :int_val => 15
      }
    ]

    prefix_tests.each do |tt|
      l = Lexer.new(tt[:input])
      p = Parser.new(l)
      program = p.parse_program
      check_parser_errors(p)

      stmts_len = program.statements.length
      assert_equal stmts_len, 1, "program has not enough statements. got=#{stmts_len}"
      stmt = program.statements[0]
      exp = stmt.expression
      assert_equal exp.operator, tt[:operator], "exp.operator is not '#{tt[:operator]}', got #{exp.operator}"
      if !t_integer_literal(exp.right, tt[:int_val])
        return
      end
    end
  end

  def test_parsing_infix_expressions
    infix_tests = [
      {
        :input => "5 + 5;",
        :left_value => 5,
        :operator => "+",
        :right_value => 5
      },
      {
        :input => "5 - 5;",
        :left_value => 5,
        :operator => "-",
        :right_value => 5
      },
      {
        :input => "5 * 5;",
        :left_value => 5,
        :operator => "*",
        :right_value => 5
      },
      {
        :input => "5 / 5;",
        :left_value => 5,
        :operator => "/",
        :right_value => 5
      },
      {
        :input => "5 > 5;",
        :left_value => 5,
        :operator => ">",
        :right_value => 5
      },
      {
        :input => "5 < 5;",
        :left_value => 5,
        :operator => "<",
        :right_value => 5
      },
      {
        :input => "5 == 5;",
        :left_value => 5,
        :operator => "==",
        :right_value => 5
      },
      {
        :input => "5 != 5;",
        :left_value => 5,
        :operator => "!=",
        :right_value => 5
      },
    ]
    infix_tests.each do |tt|
      l = Lexer.new(tt[:input])
      p = Parser.new(l)
      program = p.parse_program
      check_parser_errors(p)

      stmts_len = program.statements.length
      assert_equal stmts_len, 1, "program has not enough statements. got=#{stmts_len}"
      stmt = program.statements[0]
      exp = stmt.expression
      if !t_integer_literal(exp.left, tt[:left_value])
        return
      end
      assert_equal exp.operator, tt[:operator], "exp.operator is not '#{tt[:operator]}', got #{exp.operator}"
      if !t_integer_literal(exp.right, tt[:right_value])
        return
      end

    end
  end

  def test_operator_precedence_parsing
    tests = [
      {
        :input => "-a * b",
        :expected => "((-a) * b)",
      },
      {
        :input => "!-a",
        :expected => "(!(-a))",
      },
      {
        :input => "a + b + c",
        :expected => "((a + b) + c)",
      },
      {
        :input => "a + b - c",
        :expected => "((a + b) - c)",
      },
      {
        :input => "a * b * c",
        :expected => "((a * b) * c)",
      },
      {
        :input => "a * b / c",
        :expected => "((a * b) / c)",
      },
      {
        :input => "a + b / c",
        :expected => "(a + (b / c))",
      },
      {
        :input => "a + b * c + d / e - f",
        :expected => "(((a + (b * c)) + (d / e)) - f)",
      },
      {
        :input => "3 + 4; -5 * 5",
        :expected => "(3 + 4)((-5) * 5)",
      },
      {
        :input => "5 > 4 == 3 < 4",
        :expected => "((5 > 4) == (3 < 4))",
      },
      {
        :input => "5 < 4 != 3 > 4",
        :expected => "((5 < 4) != (3 > 4))",
      },
      {
        :input => "3 + 4 * 5 == 3 * 1 + 4 * 5",
        :expected => "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))",
      }
    ]
    tests.each do |tt|
      l = Lexer.new(tt[:input])
      p = Parser.new(l)
      program = p.parse_program
      check_parser_errors(p)

      actual = program.string
      assert_equal actual, tt[:expected], "expected #{tt[:expected]} got=#{actual}"
    end
  end

end
