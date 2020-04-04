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

  def string
    out = ""
    @statements.each do |stmt|
      out += stmt.string
    end
    out
  end
end

class Node
  def initialize(token)
    @token = token
  end

  def token_literal
    return @token.literal
  end
end

class Statement < Node
  def statement_node
  end
end

class Expression < Node
  attr_accessor :value
  def expression_node
  end

  def token_literal
    return @token.literal
  end

  def string
    @value
  end
end

class LetStatement < Statement
  attr_accessor :name, :value

  def statement_node
  end

  def string
    out = "#{token_literal} #{@name.string} = "
    if @value
      out += @value.string
    end
    out += ";"
    out
  end
end

class ReturnStatement < Statement
  attr_accessor :return_value

  def string
    out = "#{token_literal} "
    if @return_value
      out += @return_value.string
    end
    out += ";"
    out
  end
end

class ExpressionStatement < Statement
  attr_accessor :expression
  def string
    if @expression
      @expression.string
    end
  end
end

class Identifier < Expression
  def initialize(token, value)
    @token = token
    @value = value
  end
end

class IntegerLiteral < Expression
end

class Boolean < Expression
end

class PrefixExpression < Expression
  attr_accessor :operator, :right
  def initialize(token, operator)
    @token = token
    @operator = operator
  end
  def string
    "(#{@operator}#{@right.string})"
  end
end

class InfixExpression < Expression
  attr_accessor :operator, :left, :right
  def initialize(token, operator, left)
    @token = token
    @operator = operator
    @left = left
  end
  def string
    "(#{@left.string} #{@operator} #{@right.string})"
  end
end

