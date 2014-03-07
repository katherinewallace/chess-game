#!/usr/bin/env ruby
require_relative 'piece.rb'
require_relative 'board.rb'

class Game

  def initialize
    @board = Board.new
    @current_player = :white
  end

  def play
    until lost?
      puts
      @board.render
      take_turn
      @current_player == :white ? @current_player = :black : @current_player = :white
    end
    puts
    puts "Checkmate, #{@current_player} loses!"
  end

  def take_turn
    begin
      puts
      puts "#{@current_player}, enter your move:"
      user_input = gets.chomp
      usable_input = parse_input(user_input)
      raise WrongColorError if @board[usable_input[0]].color != @current_player
      @board.move(usable_input[0],usable_input[1])
    rescue InvalidMoveError
      puts "That piece can't move there, human. Try again."
      retry
    rescue NoMethodError
      puts "No piece at that location. Try again."
      retry
    rescue WrongColorError
      puts "Please move a #{@current_player} piece. Try again."
      retry
    end
  end

  private

  def parse_input(user_input)
    input_arr = user_input.split(",").map(&:strip)
    usable_input = []
    input_arr.each do |pos|
      usable_input << [Integer(pos[1])-1, pos[0].ord - "a".ord]
    end
    usable_input
  end

  def lost?
    @board.checkmate?(@current_player)
  end

end

class WrongColorError < StandardError
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end