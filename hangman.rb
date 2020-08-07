
require 'yaml'

class String
    def is_number?
        true if Float(self) rescue false
    end
end

class Game
    attr_accessor :name, :word, :word_letters, :word_length, :incorrect_guesses, :correct_guesses, :incorrect_count, :correct_count, :guessing_line

    def initialize
        @name = Time.now
    end

    def find_word
        begin
            @word = File.readlines("dictionary.txt").sample.strip
            @word_letters = @word.upcase.split("")
            @word_length = @word_letters.length
        rescue 
            retry if @word_length >= 5 || @word_length <= 12
        end
    end

    def set_up
        @guessing_line = []
        @incorrect_guesses = []
        @correct_guesses = []
        @incorrect_count = 0
        @correct_count = 0

        0.upto(@word_length - 1) do
            @guessing_line.append("_")
        end

        puts @guessing_line.join(" ")
    end

    def play_game
        until @incorrect_count == 6 || @correct_count == @word_letters.uniq.length do
            puts "Options: save(1) load(2) delete save(3) quit(4)\n\n"
            puts "Guess a letter"
            
            begin
                guess = gets.chomp.upcase
                if guess.is_number?
                    raise if (guess.to_i > 4) || (guess.to_i < 1)
                else
                    raise if (@correct_guesses.include? guess) || (@incorrect_guesses.include? guess) || (guess.length != 1)
                end
            rescue
                puts "Please give a valid character"
                retry
            end
        
            if guess == "1"
                $game.save_game
            elsif guess == "2"
                $game.load_game
            elsif guess == "3"
                $game.delete_files
            elsif guess == "4"
                puts "\n\nSorry to hear it. JK, fuck you too."
                abort
            else
                if @word_letters.include? guess
                    @word_letters.each_with_index { |letter, index|
                        if letter == guess
                            @guessing_line[index] = guess
                        end
                    }
                    @correct_guesses.append(guess)
                    @correct_count += 1
                else
                    @incorrect_guesses.append(guess)
                    @incorrect_count += 1
                end
            end
        
            puts File.read("/home/stevenobadiah/ruby/hangman/displays/hang_display#{@incorrect_count}.txt")
            puts @guessing_line.join(" ")
            puts "\nIncorrect guesses: #{@incorrect_guesses}\n\n\n"
        end

        if @incorrect_count == 6
            puts "The correct word was #{@word}\n\n"
        end
    end

    def save_game
        Dir.mkdir("saved_games") unless Dir.exists?("saved_games")

        puts "Please name your file, or press \"enter\" to keep the default file name."
        filename_input = gets.chomp
        if filename_input != ""
            @name = filename_input
        end

        filename = "saved_games/game_#{@name}.yml"

        File.open(filename, "w") do |file|
            file.write(YAML.dump({
                :word => @word, :word_letters => @word_letters, :word_length => @word_length, :incorrect_guesses => @incorrect_guesses,
                :incorrect_count => @incorrect_count,:correct_guesses => @correct_guesses, :correct_count => @correct_count, :guessing_line => @guessing_line
            }))
        end
    end

    def list_files
        $saved_files = {}
        file_number = 0
        Dir.each_child("/home/stevenobadiah/ruby/hangman/saved_games") do |child|
            file_number += 1
            $saved_files[file_number] = child
        end

        $saved_files.each do |key, value|
            puts "\t#{key}...#{value}"
        end
    end

    def load_game
        list_files
        puts "Choose a file to load or type \'Q\' to go back"
        begin
            file_selection = gets.chomp
            if file_selection.upcase == "Q"
                puts "\nBack to the game\n"
            elsif $saved_files.key?(file_selection.to_i)
                selected_file = File.read "/home/stevenobadiah/ruby/hangman/saved_games/" + $saved_files[file_selection.to_i]
                data = YAML.load selected_file
    
                self.word = data[:word]
                self.word_letters = data[:word_letters]
                self.word_length = data[:word_length]
                self.incorrect_guesses = data[:incorrect_guesses]
                self.incorrect_count = data[:incorrect_count]
                self.correct_guesses = data[:correct_guesses]
                self.correct_count = data[:correct_count]
                self.guessing_line = data[:guessing_line]
            end
            raise if $saved_files.key?(file_selection.to_i) == false && file_selection.upcase != "Q"
        rescue
            puts "Invalid selection"
            retry
        end
    end

    def delete_files
        list_files
        puts "Choose a file to delete or type \'Q\' to go back"
        begin
            $file_selection = gets.chomp
            if $file_selection.upcase == "Q"
                puts "\nBack to the game\n"
            elsif $saved_files.key?($file_selection.to_i)
                file = ("/home/stevenobadiah/ruby/hangman/saved_games/" + $saved_files[$file_selection.to_i])
                File.delete(file)
            end
            raise if $saved_files.key?($file_selection.to_i) == false && $file_selection.upcase != "Q"
        rescue
            puts "Invalid selection"
            retry
        end
    end
end

play_again_choice = "y"
until play_again_choice == "n"
    $game = Game.new
    $game.find_word
    $game.set_up
    $game.play_game

    puts "Would you like to play again? (y/n)"
    play_again_choice = gets.chomp
end
