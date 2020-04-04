require_relative './ast'
require_relative './lexer'
require_relative './token'

class Parser
  attr_accessor :cur_token, :errors
  LOWEST = 10
  EQUALS = 20
  LESSGREATER = 30
  SUM = 40
  PRODUCT = 50
  PREFIX = 60
  CALL = 70

  def initialize(lexer)
    @l = lexer
    @peek_token = nil
    @errors = []
    @precedences = {
      Token::EQ => EQUALS,
      Token::NOT_EQ => EQUALS,
      Token::LT => LESSGREATER,
      Token::GT => LESSGREATER,
      Token::PLUS => SUM,
      Token::MINUS => SUM,
      Token::SLASH => PRODUCT,
      Token::ASTERISK => PRODUCT,
    }
    @prefix_parse_fns = {}
    @infix_parse_fns = {}
    register_prefix_fn(Token::IDENT, method(:parse_identifier))
    register_prefix_fn(Token::INT, method(:parse_integer_literal))
    register_prefix_fn(Token::BANG, method(:parse_prefix_expression))
    register_prefix_fn(Token::MINUS, method(:parse_prefix_expression))
    register_infix_fn(Token::PLUS, method(:parse_infix_expression))
    register_infix_fn(Token::MINUS, method(:parse_infix_expression))
    register_infix_fn(Token::SLASH, method(:parse_infix_expression))
    register_infix_fn(Token::ASTERISK, method(:parse_infix_expression))
    register_infix_fn(Token::EQ, method(:parse_infix_expression))
    register_infix_fn(Token::NOT_EQ, method(:parse_infix_expression))
    register_infix_fn(Token::LT, method(:parse_infix_expression))
    register_infix_fn(Token::GT, method(:parse_infix_expression))
    next_token
    next_token
  end

  def peek_precedence
    p = @precedences[@peek_token.type]
    if p
      return p
    end
    LOWEST
  end

  def cur_precedence
    p = @precedences[@cur_token.type]
    if p
      return p
    end
    LOWEST
  end

  def register_prefix_fn(token_type, parse_fn)
    @prefix_parse_fns[token_type] = parse_fn
  end

  def register_infix_fn(token_type, parse_fn)
    @infix_parse_fns[token_type] = parse_fn
  end

  def no_prefix_parse_fn_error(token_type)
    @errors.push("no prefix parse fn for #{token_type} found")
  end

  def next_token
    @cur_token = @peek_token
    @peek_token = @l.next_token
    # if @cur_token != nil
    #   puts "#{@cur_token.type} #{@cur_token.literal} / #{@peek_token.type} #{@peek_token.literal}"
    # end
  end

  def cur_token_is(token_type)
    @cur_token.type == token_type
  end

  def peek_token_is(token_type)
    @peek_token.type == token_type
  end

  def expect_peek(token_type)
    if peek_token_is(token_type)
      next_token
      return true
    else
      peek_error(token_type)
      return false
    end
  end

  def peek_error(token_type)
    msg = "expected next token to be #{token_type}, got #{@peek_token.type}"
    @errors.push(msg)
  end

  def parse_let_statement
    stmt = LetStatement.new(@cur_token)
    if !expect_peek(Token::IDENT)
      return nil
    end

    stmt.name = Identifier.new(@cur_token, @cur_token.literal)
    if !expect_peek(Token::ASSIGN)
      return nil
    end

    while !cur_token_is(Token::SEMICOLON)
      next_token
    end

    return stmt
  end

  def parse_return_statement
    stmt = ReturnStatement.new(@cur_token)
    next_token

    while !cur_token_is(Token::SEMICOLON)
      next_token
    end

    return stmt
  end

  def parse_identifier
    Identifier.new(@cur_token, @cur_token.literal)
  end

  def parse_integer_literal
    lit = IntegerLiteral.new(@cur_token)
    lit.value = @cur_token.literal.to_i
    lit
  end

  def parse_prefix_expression
    expression = PrefixExpression.new(@cur_token, @cur_token.literal)
    next_token
    expression.right = parse_expression(PREFIX)
    expression
  end

  def parse_infix_expression(left)
    expression = InfixExpression.new(
      @cur_token,
      @cur_token.literal,
      left
    )
    precedence = cur_precedence
    next_token
    expression.right = parse_expression(precedence)
    expression
  end

  def parse_expression(precedence)
    prefix_fn = @prefix_parse_fns[@cur_token.type]
    if prefix_fn == nil
      no_prefix_parse_fn_error(@cur_token.type)
      return nil
    end
    left_exp = prefix_fn.call

    while !peek_token_is(Token::SEMICOLON) && precedence < peek_precedence
      infix_fn = @infix_parse_fns[@peek_token.type]
      if infix_fn == nil
        return left_exp
      end

      next_token
      left_exp = infix_fn.call(left_exp)
    end
    left_exp
  end

  def parse_expression_statement
    stmt = ExpressionStatement.new(@cur_token)
    stmt.expression = parse_expression(LOWEST)

    if peek_token_is(Token::SEMICOLON)
      next_token
    end

    return stmt
  end

  def parse_statement
    case @cur_token.type
      when Token::LET
        return parse_let_statement
      when Token::RETURN
        return parse_return_statement
      else
        return parse_expression_statement
    end
  end

  def parse_program
    program = Program.new
    # puts @cur_token.type
    while !cur_token_is(Token::EOF)
      # puts "TOKEN #{@cur_token.type} #{@cur_token.literal}"
      stmt = parse_statement
      # p stmt
      if stmt != nil
        program.statements.push(stmt)
      end
      next_token
    end
    return program
  end
end
