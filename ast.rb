class Program
  attr_accessor :statements
  def initialize
    @statements = []
  end

  def token_literal
    if @statements.length > 0
      return @statements[0].token_literal
    else
      return ""
    end
  end
end

class Node
  def initialize(token)
    @token = token
  end

  def token_literal
  end
end

class Statement < Node
  def statement_node
  end
end

class Expression < Node
  def expression_node
  end
end

class LetStatement < Statement
  attr_accessor :name
  def statement_node

  end

  def token_literal
    return @token.literal
  end
end

class Identifier < Expression
  attr_accessor :value
  def initialize(token, value)
    @token = token
    @value = value
  end

  def expression_node

  end

  def token_literal
    return @token.literal
  end
end

