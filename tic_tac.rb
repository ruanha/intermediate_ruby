class Array
  def get_cols
    ''' Yields the columns of a 2d array / matrix
    '''
    self.transpose.each do |col|
      yield col
    end
  end

  def get_diagonals
    ''' Yields the two diagonals of square 2d array / matrix
    '''
    diag1 = []
    for i in 0...self.length
      diag1 << self[i][i]
    end 
    yield diag1

    diag2 = []
    for i in 0...self.length
      diag2 << self[i][self.length-1-i]
    end 
    yield diag2
  end

  def set_2d_coord(coord1, coord2, val)
    self[coord1][coord2] = val
    self
  end

  def all_equal?
    ''' returns true if all elements in the array are equal'''
    self.each do |elem|
      return false if self[0] != elem
    end
    return true
  end
end


class Board
  attr_accessor :internal_board
  def initialize
    @board = board
    @internal_board =  [[7,8,9],[4,5,6],[1,2,3]]
  end

  def render round
    puts (round>1) ? @board.gsub(/[1-9]/, " ") : @board
  end

  def record_move move, active_player
    @board.sub!(move, active_player)
    update_internal_board move, active_player
  end

  def update_internal_board move, active_player
    move = move.to_i
    num_to_coord = {7=>[0,0], 8=>[0,1], 9=>[0,2], 4=>[1,0], 5=>[1,1], 6=>[1,2],
                    1=>[2,0], 2=>[2,1], 3=>[2,2]}
    @internal_board = @internal_board.set_2d_coord(num_to_coord[move][0], num_to_coord[move][1], active_player)
  end

  def board
    "
     7 | 8 | 9
    ---+---+--
     4 | 5 | 6
    ---+---+--
     1 | 2 | 3"
  end
end

class Game
  def initialize
    @active_player = "X"
    @round = 1
    @MAX_ROUND = 10
    @free = "123456789"
    @winner = ""
  end

  def play
    board = Board.new

    while @winner == ""
      puts "round: #{@round}"
      puts "Choose wisely Player #{@active_player}"
      board.render @round
      move = get_move
      
      return "exit" if move == "q"

      @free.sub!(move, "")
      board.record_move move, @active_player

      win_position? board.internal_board

      @round += 1

      switch_player if @winner == ""

      if @round == @MAX_ROUND
        puts "game over, no more legal moves"
        board.render @round
        return
      end
    end
    puts "YOU WIN PLAYER #{@active_player}!!"
    board.render @round
  end

  def get_move
    begin
      move = gets.match(/^[#{@free}q]$/)[0] #the [0] ensures we get an (index?)error if the regex don't match input, and a digit otherwise
    rescue
      puts "fool, you must enter a valid move"
      retry
    end
    move
  end

  def win_position? pos
    #check rows
    pos.each { |row| @winner = @active_player if row.all_equal? }
    #check cols
    pos.get_cols { |col| @winner = @active_player if col.all_equal? }
    #check diagonals
    pos.get_diagonals { |dia| @winner = @active_player if dia.all_equal? }
  end

  def switch_player
    @active_player = (@active_player == "X") ? "0" : "X"
  end

end

game = Game.new
game.play

