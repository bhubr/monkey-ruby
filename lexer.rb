class Lexer
  def initialize(input)
    @input = input
    @read_position = 0
    @position = 0
    read_char
  end

  def read_char
    if @read_position >= @input.length
      @ch = "\x00"
    else
      @ch = @input[@read_position]
    end
    @position = @read_position
    @read_position += 1
  end
end
