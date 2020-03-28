class Token
attr_accessor :type, :literal

  ILLEGAL = "ILLEGAL"
  EOF = "EOF"

  IDENT = "IDENT"
  INT = "INT"

  ASSIGN = "="
  PLUS = "+"

  COMMA = ","
  SEMICOLON = ";"

  LPAREN = "("
  RPAREN = ")"
  LBRACE = "{"
  RBRACE = "}"

  FUNCTION = "FUNCTION"
  LET = "LET"

  KeywordsMap = {
    "let" => LET,
    "fn" => FUNCTION
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


