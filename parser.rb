require_relative './ast'
require_relative './lexer'
require_relative './token'

class Parser
  attr_accessor :cur_token, :errors
  def initialize(lexer)
    @l = lexer
    @peek_token = nil
    @errors = []
    next_token
    next_token
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

  def parse_statement
    case @cur_token.type
      when Token::LET
        return parse_let_statement
      when Token::RETURN
        return parse_return_statement
      else
        return nil
    end
  end

  def parse_program
    program = Program.new
    # puts @cur_token.type
    while !cur_token_is(Token::EOF)
      # puts "TOKEN #{@cur_token.type} #{@cur_token.literal}"
      stmt = parse_statement
      p stmt
      if stmt != nil
        program.statements.push(stmt)
      end
      next_token
    end
    return program
  end
end
