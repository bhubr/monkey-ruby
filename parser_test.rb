require "test/unit"
require_relative "./ast"
require_relative "./lexer"
require_relative "./parser"

class ParserTest < Test::Unit::TestCase
  def t_let_statement(s, name)
    assert_equal s.class.name, "LetStatement", "stmt not LetStatement, got #{s.class.name}"
    assert_equal s.token_literal, "let", "s.token_literal not 'let', got #{s.token_literal}"
    let_stmt_val = s.name.value
    assert_equal let_stmt_val, name, "let_stmt.name.value not '#{name}', got #{let_stmt_val}"
    let_stmt_literal = s.name.token_literal
    assert_equal let_stmt_literal, name, "let_stmt.name.token_literal not '#{name}', got #{let_stmt_literal}"
  end

  def t_integer_literal(il, value)
    assert_equal il.class.name, "IntegerLiteral", "stmt not IntegerLiteral, got #{il.class.name}"
    assert_equal il.value, value, "il.value not #{value}, got #{il.value}"
    assert_equal il.token_literal, "#{value}", "il.token_literal not '#{value}', got '#{il.token_literal}'"
  end

  def t_boolean_literal(exp, expected_bool)
    assert_equal exp.class.name, "Boolean", "exp not Boolean. got #{exp.class.name}"
    assert_equal exp.value, expected_bool, "exp.value not #{expected_bool}, got #{exp.value}"
    assert_equal exp.token_literal, expected_bool.to_s, "exp.token_literal not #{expected_bool}, got #{exp.token_literal}"
  end

  def t_identifier(exp, expected_val)
    assert_equal exp.class.name, "Identifier"
    assert_equal exp.value, expected_val, "exp.value not '#{expected_val}'. got=#{exp.value}"
    assert_equal exp.token_literal, expected_val, "exp.token_literal not '#{expected_val}'. got #{exp.token_literal}"
  end

  def t_literal_expression(exp, expected)
    v = expected.class.name
    case v
      when "Integer"
        return t_integer_literal(exp, expected)
      when "String"
        return t_identifier(exp, expected)
      when "TrueClass"
      when "FalseClass"
        return t_boolean_literal(exp, expected)
      else
        raise "Not handled: #{v}"
    end
  end

  def t_infix_expression(exp, left, operator, right)
    assert_equal exp.class.name, "InfixExpression", "exp not InfixExpression, got #{exp.class.name}"
    t_literal_expression(exp.left, left)
    assert_equal exp.operator, operator, "exp.operator is not '#{operator}', got '#{exp.operator}'"
    t_literal_expression(exp.right, right)
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
    t_identifier(ident, "foobar")
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

  def test_boolean_expression
    tests = [
      {
        :input => "true;",
        :value => true,
        :literal => "true",
      },
      {
        :input => "false;",
        :value => false,
        :literal => "false"
      },
    ]
    tests.each do |tt|
      l = Lexer.new(tt[:input])
      p = Parser.new(l)
      program = p.parse_program
      check_parser_errors(p)
      stmts_len = program.statements.length
      assert_equal stmts_len, 1, "program has not enough statements. got=#{stmts_len}"
      stmt = program.statements[0]
      bool = stmt.expression
      assert_equal bool.class.name, "Boolean", "bool is not a Boolean. got #{bool.class.name}"
      assert_equal bool.value, tt[:value], "bool.value not #{tt[:value]}. got=#{bool.value}"
      assert_equal bool.token_literal, tt[:literal], "bool.token_literal not '#{tt[:literal]}'. got #{bool.token_literal}"
    end
  end

  def test_parsing_prefix_expressions
    prefix_tests = [
      {
        :input => "!5;",
        :operator => "!",
        :value => 5
      },
      {
        :input => "-15;",
        :operator => "-",
        :value => 15
      },
      {
        :input => "!true;",
        :operator => "!",
        :value => true,
      },
      {
        :input => "!false;",
        :operator => "!",
        :value => false,
      },
    ]

    prefix_tests.each do |tt|
      l = Lexer.new(tt[:input])
      p = Parser.new(l)
      program = p.parse_program
      check_parser_errors(p)

      stmts_len = program.statements.length
      assert_equal stmts_len, 1, "program has not enough statements. got=#{stmts_len}"
      stmt = program.statements[0]
      stmt_class = stmt.class.name
      assert_equal stmt_class, "ExpressionStatement", "stmt not ExpressionStatement, got #{stmt_class}"
      exp = stmt.expression
      exp_class = exp.class.name
      assert_equal exp_class, "PrefixExpression", "exp not PrefixExpression, got #{exp_class}"
      assert_equal exp.operator, tt[:operator], "exp.operator is not '#{tt[:operator]}', got #{exp.operator}"
      t_literal_expression(exp.right, tt[:value])
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
      {
        :input => "true == true",
        :left_value => true,
        :operator => "==",
        :right_value => true
      },
      {
        :input => "true != false",
        :left_value => true,
        :operator => "!=",
        :right_value => false
      },
      {
        :input => "false == false",
        :left_value => false,
        :operator => "==",
        :right_value => false
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
      stmt_class = stmt.class.name
      assert_equal stmt_class, "ExpressionStatement", "stmt not ExpressionStatement, got #{stmt_class}"
      exp = stmt.expression
      t_infix_expression(exp, tt[:left_value], tt[:operator], tt[:right_value])
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
      },
      {
        :input => "true",
        :expected => "true",
      },
      {
        :input => "false",
        :expected => "false",
      },
      {
        :input => "3 > 5 == false",
        :expected => "((3 > 5) == false)",
      },
      {
        :input => "3 < 5 == true",
        :expected => "((3 < 5) == true)",
      },
      {
        :input => "1 + (2 + 3) + 4",
        :expected => "((1 + (2 + 3)) + 4)",
      },
      {
        :input => "(5 + 5) * 2",
        :expected => "((5 + 5) * 2)",
      },
      {
        :input => "2 / (5 + 5)",
        :expected => "(2 / (5 + 5))",
      },
      {
        :input => "-(5 + 5)",
        :expected => "(-(5 + 5))",
      },
      {
        :input => "!(true == true)",
        :expected => "(!(true == true))",
      },
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

  def t_if_else_expression(input, alt_literal)
    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program
    check_parser_errors(p)

    p_num_stmts = program.statements.length
    assert_equal p_num_stmts, 1, "program.statements does not contain 1 statement, got #{p_num_stmts}"
    first_st = program.statements[0]
    assert_equal first_st.class.name, "ExpressionStatement", "program.statements[0] not ExpressionStatement, got #{first_st.class.name}"
    exp = first_st.expression
    assert_equal exp.class.name, "IfExpression", "stmt.expression not IfExpression, got "#{exp.class.name}"
    t_infix_expression(exp.condition, "x", "<", "y")
    c_num_stmts = exp.consequence.statements.length
    assert_equal c_num_stmts, 1, "consequence has not 1 statement, got #{c_num_stmts}"
    c_first_st = exp.consequence.statements[0]
    assert_equal c_first_st.class.name, "ExpressionStatement", "consequence.stmts[0] not ExpressionStatement, got #{c_first_st.class.name}"
    t_identifier(c_first_st.expression, "x")
    if alt_literal == nil
      assert_equal exp.alternative, nil, "exp.alternative not nil, got #{exp.alternative}"
    else
      assert_not_equal exp.alternative, nil, "exp.alternative unexpectedly is nil"
      a_num_stmts = exp.alternative.statements.length
      assert_equal a_num_stmts,  1, "alternative has not 1 statement, got #{a_num_stmts}"
      a_first_st = exp.alternative.statements[0]
      assert_equal a_first_st.class.name, "ExpressionStatement", "alternative.stmts[0] not ExpressionStatement, got #{a_first_st.class.name}"
      t_identifier(a_first_st.expression, alt_literal)
    end
  end

  def test_if_expression
    t_if_else_expression("if (x < y) { x }", nil)
  end

  def test_if_else_expression
    t_if_else_expression("if (x < y) { x } else { y }", "y")
  end
end
