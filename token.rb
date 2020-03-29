class Token
  attr_accessor :type, :literal

  ILLEGAL = "ILLEGAL"
  EOF = "EOF"

  IDENT = "IDENT"
  INT = "INT"

  ASSIGN = "="
  PLUS = "+"
  MINUS = "-"
  ASTERISK = "*"
  SLASH = "/"
  BANG = "!"

  LT = "<"
  GT = ">"

  EQ = "=="
  NOT_EQ = "!="

  COMMA = ","
  SEMICOLON = ";"

  LPAREN = "("
  RPAREN = ")"
  LBRACE = "{"
  RBRACE = "}"

  FUNCTION = "FUNCTION"
  LET = "LET"
  IF = "IF"
  ELSE = "ELSE"
  RETURN = "RETURN"
  TRUE = "TRUE"
  FALSE = "FALSE"

  KeywordsMap = {
    "let" => LET,
    "fn" => FUNCTION,
    "if" => IF,
    "else" => ELSE,
    "return" => RETURN,
    "true" => TRUE,
    "false" => FALSE
  }

  def initialize(type, literal)
    @type = type
    @literal = literal
  end

  def self.get_type(word)
    kw = KeywordsMap[word]
    kw ? kw : IDENT
  end
end


