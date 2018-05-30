class Row
  attr_accessor :pins
  attr_accessor :hints

  def initialize
    @NUMBER_OF_PINS = 4
    @pins = [" "] * @NUMBER_OF_PINS
    @hints = [" "] * @NUMBER_OF_PINS #"●","○"
  end

  def render
    hints_hash = {1=>"●", 0=>" ", -1=>"○"}

    puts " _______________"
    puts "| %s | %s | %s | %s |" % @pins
    puts "+---+---+---+---+"
    puts "| %s | %s | %s | %s |" % @hints.map! {|x| hints_hash[x]}
    puts "+---------------+"
  end
end

class Game
  def initialize
    @round = 0
  end

  def play
    player = Player.new
    comp = Computer.new
    puts "Lets play a game of Mastermind..."
    puts "enter four digits between 1-6"
    puts "you can always exit by entering: \"q\""
    while @round < 10
      row = Row.new
      guess = player.put_pins

      if guess.include? "q"
        puts "Goodbye"
        return
      end

      hints = comp.feedback guess

      if guess == comp.code
        puts "YOU WIN!!!"
        row.pins = guess; row.hints = hints; row.render
        return
      end
      row.pins = guess; row.hints = hints
      row.render
      @round+=1
    end
  end
end

class Player
  '''
  get input from player. sets input to an Array like ["1","2","3","4"]
  '''
  def put_pins
    puts "Please enter your guess"
    begin
      pins = gets.match(/^([1-6]{4}|q)$/)[0]
    rescue
      puts "enter four digits between 1-6 like: 1526"
      retry
    end
    if pins != "q"
      pins = pins.split("").map {|i| i.to_i}
    end
    return pins
  end
end


module Hints
  module_function
  def calc code, guess
    hint = []
    #first put in the exact matches
    guess.each_with_index do |g, idx|
      if g == code[idx]
        hint[idx] = 1
      else
        hint[idx] = 0
      end
    end

    #Second, put in the non-exact matches
    guess.each_with_index do |g, idx|
      if hint[idx] != 1
        code.each_with_index do |c, jdx|
          if g == c && hint[jdx] != 1
            hint[idx] = -1
          end
        end
      end
    end
    return hint
  end
end

class Computer
  include Hints
  attr_reader :code
  def initialize
    @code = Array.new(4) { rand 1..6 }
  end

  def feedback guess
    hint_back = Hints::calc @code, guess
    return hint_back
  end
end


game = Game.new
game.play


