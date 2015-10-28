require './lib/colorize.rb'

class Tile
  attr_reader :value, :given, :selected
  def initialize(value, selected = false)
    if value.zero?
      @given = false
    else
      @given = true
    end
    @value = value
    @selected = selected
  end

  def to_s
    if @given
        @value.to_s.colorize(:red)
      end
    elsif @value.zero? && @selected
      ' '.colorize(:background => :light_blue)
    elsif @selected
      @value.to_s.colorize(:background => :light_blue)
    elsif @value.zero?
      ' '
    else
      @value.to_s
    end
  end

  def set_value(val)
    @value = val
  end

  def select
    @selected = true
  end

  def unselect
    @selected = false
  end

end

class Board

  attr_reader :grid
  def initialize(grid)
    @grid = grid
  end

  def self.from_file(file)
    f = File.readlines(file)
    numbers_array = f.map do |line|
      line.chomp.split("").map!(&:to_i)
    end
    grid = numbers_array.map do |line|
      line.map! do |num|
        num = Tile.new(num)
      end
    end
    Board.new(grid)
  end

  def line_breaker
    print '  '
    print '+---'*9
    puts '+'
  end

  def print_row(tiles_ary)
    strings = tiles_ary.map(&:to_s)
    print "| #{strings.join(' | ')} |"
  end

  def render
    print('    ')
    print((1..9).to_a.join('   '))
    puts ''
    line_breaker
    @grid.each_with_index do |row, idx|
      print (idx + 1).to_s + ' '
      print_row(row)
      puts ''
      line_breaker
    end
  end

  def sub_square(pos)
    row = pos[0]*3
    column = pos[1]*3
    square = []
    (row...row+3).each do |row|
      sub_array = []
      (column...column+3).each do |col|
          sub_array << @grid[row][col]
        end
        square << sub_array
      end
    to_nums(square.flatten)
  end

  #sub_square([1,1]) ===> [[7,6,1],[8,5,3],[9,2,4]]
  def solved?
    0.upto(2) do |row|
      0.upto(2) do |col|
        return false unless sub_solved?(sub_square([row,col]))
      end
    end
    @grid.each do |row|
      return false unless sub_solved?(to_nums(row))
    end
    columns.each do |col|
      return false unless sub_solved?(to_nums(col))
    end
    true
  end

  def to_nums(tiles_ary)
    tiles_ary.map { |tile| tile.value }
  end

  def columns
    @grid.transpose
  end

  def sub_solved?(arr)
    sorted = (1..9).to_a
    return false if arr.sort != sorted
    true
  end
end

class Game
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def solved?
    @board.solved?
  end

  def render
    @board.render
  end

  def play
    render
    until solved?
      print "Where? (row, column) > "
      pos = gets.chomp.split(",").map {|num| num.to_i - 1}
      @board.grid[pos[0]][pos[1]].select
      system("clear")
      render
      print "What number? > "
      num = gets.chomp.to_i
      @board.grid[pos[0]][pos[1]].set_value(num)
      @board.grid[pos[0]][pos[1]].unselect
      system("clear")
      render
    end
    puts "YOU WIN"
  end



end

if __FILE__ == $PROGRAM_NAME
  g = Game.new(Board.from_file('sudoku1-almost.txt'))
  g.play
end
