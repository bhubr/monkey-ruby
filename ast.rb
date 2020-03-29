class Program
  def token_literal
    if @statements.length > 0
      return @statements[0].token_literal
    else
      return ""
    end
  end
end

class LetStatement
  def statement_node

  end

  def token_literal
    return @token.literal
  end
end

class Identifier
  def expression_node

  end

  def token_literal
    return @token.literal
  end
end

