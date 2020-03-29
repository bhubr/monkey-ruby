require_relative './ast'
require_relative './lexer'
require_relative './token'

class Parser
  def initialize(lexer)
    @l = lexer
    @peek_token = nil
    next_token
    next_token
  end

  def next_token
    @cur_token = @peek_token
    @peek_token = @l.next_token
  end

  def parse_program
    nil
  end
end
