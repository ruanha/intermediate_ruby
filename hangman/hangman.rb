class Game

  def initialize
    @MAX_MISTAKES = 7
  end

  def play
    word_engine = Word.new
    word_displayer = Display.new
    player = Player.new
    serialize = Serialize.new

    puts "Lets play Hangman!"
    puts "do you want to load a game? (press l)"
    puts "or do you want to play a new? (press any key)"
    choice = gets.chomp
    if choice == "l"
      @mistakes, @word, @guessed = serialize.load
    else
      @mistakes = 0
      @word = word_engine.new_word.downcase
      @guessed = ""
    end

    puts @word

    game_on = true
    while game_on == true

      puts "Enter a character a-z or enter '?' to save the game"
      puts " guessed: #{@guessed}, mistakes: #{@mistakes}"
      @view = word_displayer.word_to_view @word, @guessed
      puts @view


      guess = player.get_character
      if guess == "?"
        serialize.save @mistakes, @word, @guessed
        puts "game saved"
        return
      else
        @guessed << guess
        @mistakes = (@word.include? guess) ? @mistakes : @mistakes+1

        @view = word_displayer.word_to_view @word, @guessed
        puts @view

        game_on = test_status
      end
    end
    puts @word
  end

  def test_status
    if !@view.include? "_"
      game_on = false
    elsif (@mistakes >= @MAX_MISTAKES)
      game_on = false
    else
      game_on = true
    end
    game_on
  end
end

# Serialize load/save game data
class Serialize
  def load
    lines = []
    File.open("savegames/savegames.data", "r") do |file|
      lines = file.readlines
    end

    lines.each_with_index { |line, idx| puts "#{idx} #{line}"}

    puts "choose a save file, numbers 0-#{lines.length-1}"
    begin
      choice = gets.chomp.match(/[0-#{lines.length-1}]{1}/)[0]
      load_data = lines[choice.to_i].chomp
    rescue
      puts "try again"
      retry
    end
    load_data = load_data.split(", ")
    load_data[0] = load_data[0].to_i
    load_data
  end

  def save mistakes, word, guessed
    Dir.mkdir("savegames") unless Dir.exists?("savegames")
    if !File.file?("savegames/savegames.data")
      File.open("savegames/savegames.data", "w") do |file|
        10.times { file.puts "..." }
      end
    end
    lines = []
    File.open("savegames/savegames.data", "r") do |file|
      lines = file.readlines
      lines.each_with_index {|line, idx| puts "#{idx} #{line}"}
      puts "choose a save slot numbers 0-#{lines.length}"
    end

    begin
      choice = gets.chomp.match(/[0-#{lines.length}]{1}/)[0]
    rescue
      puts "try again"
      retry
    end
  end
end

# takes a word and a list of words, and displays the
# word hangman style eg. w o _ d
class Display
  def word_to_view word, guessed
    view = ""
    word.each_char do |char|
      if guessed.include? char
        view << " #{char} "
      else
        view << " _ "
      end
    end
    view
  end
end


# Player returns a character guess from the player
class Player
  def initialize
    @score = 0
  end

  def get_character
    begin
      word = gets.match(/[a-zA-Z\?]{1}/)[0]
    rescue
      puts "please enter any (one) character"
      retry
    end
    word.downcase
  end
end


# Word class returns a random word from list
class Word

  def initialize (filename = "words.txt")
    if defined?(@@instance_count)
      @@instance_count += 1
    else
      @@instance_count = 1
      @@word_list = get_word_list filename
      @@word_count = @@word_list.length
    end
  end

  def new_word
    @@word_list[ rand( @@word_count ) ]
  end

  def Word.count
    @@instance_count
  end

  def get_word_list filename
    lines = []
    File.open(filename, "r") do |file|
      file.each do |line|
        word = line.chomp
        if  (word.length >= 5 && word.length <= 12)
          lines << line.chomp
        end
      end
    end
    lines
  end
end

game = Game.new
game.play