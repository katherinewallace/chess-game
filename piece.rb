class Piece
  attr_reader :color
  attr_accessor :pos, :board

  UNICODES = {
    :w_king => "\u2654",
    :w_queen => "\u2655",
    :w_rook => "\u2656",
    :w_bishop => "\u2657",
    :w_knight => "\u2658",
    :w_pawn => "\u2659",
    :b_king => "\u265A",
    :b_queen => "\u265B",
    :b_rook => "\u265C",
    :b_bishop => "\u265D",
    :b_knight => "\u265E",
    :b_pawn => "\u265F"
  }

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def to_sym
    "#{@color[0]}_#{self.class}".downcase.to_sym
  end

  def render
    "#{UNICODES[self.to_sym]} "
  end

  def valid_moves
    all_moves = moves
    all_moves.reject { |move| move_into_check?(move) }
  end

  private

  def off_board?(pos)
    !(pos[0].between?(0,7) && pos[1].between?(0,7))
  end

  def move_into_check?(pos)
    duped_board = @board.dup
    duped_board.move!(@pos, pos).in_check?(@color)
  end

end

# SteppingPieces: King/Knight

class SteppingPiece < Piece

  def moves
    possible_moves = []

    move_dirs.each do |move_dir|
      current_pos = [@pos[0] + move_dir[0],
        @pos[1] + move_dir[1]]
      next if off_board?(current_pos)
      possible_moves << current_pos if board[current_pos].nil? ||
        board[current_pos].color != self.color
    end

    possible_moves
  end

end

class King < SteppingPiece
  DELTAS = [
    [1,0],
    [-1,0],
    [0,1],
    [0,-1],
    [1,1],
    [-1,-1],
    [1,-1],
    [-1,1]
  ]

  def move_dirs
    DELTAS
  end

end

class Knight < SteppingPiece
  DELTAS = [
    [-2, -1],
    [-2,  1],
    [-1, -2],
    [-1,  2],
    [ 1, -2],
    [ 1,  2],
    [ 2, -1],
    [ 2,  1]
  ]

  def move_dirs
    DELTAS
  end

end


class Pawn < Piece

  def moves
    row, col = @pos
    moves = []

    if @color == :white
      moves << [row + 1, col]
      moves << [row + 2, col] if row == 1 && @board[[row + 1, col]].nil?
    elsif @color == :black
      moves << [row - 1, col]
      moves << [row - 2, col] if row == 6 && @board[[row - 1, col]].nil?
    end
    moves = moves.select { |move| @board[move].nil? }

    take_moves = []
    if color == :white
      take_moves << [row + 1, col + 1] unless @board[[row + 1, col + 1]].nil?
      take_moves << [row + 1, col - 1] unless @board[[row + 1, col - 1]].nil?
    elsif color == :black
      take_moves << [row-1, col+1] unless @board[[row-1, col+1]].nil?
      take_moves << [row-1, col-1] unless @board[[row-1, col-1]].nil?
    end
    take_moves = take_moves.select { |move| @board[move].color != self.color }
    moves += take_moves
  end
end


# Sliding Pieces: Biship / Rook / Queen

class SlidingPiece < Piece

  def moves
    possible_moves = []

    move_dirs.each do |move_dir|
      current_pos = @pos
      begin
        current_pos = [current_pos[0] + move_dir[0],
        current_pos[1] + move_dir[1]]
        break if off_board?(current_pos)
        possible_moves << current_pos if board[current_pos].nil?
      end while board[current_pos].nil?

      next if off_board?(current_pos)
      possible_moves << current_pos if board[current_pos].color != self.color
    end

    possible_moves
  end

end

class Rook < SlidingPiece

  DELTAS = [
    [1,0],
    [-1,0],
    [0,1],
    [0,-1]
  ]

  def move_dirs
    DELTAS
  end

end

class Bishop < SlidingPiece

  DELTAS = [
    [1,1],
    [-1,-1],
    [1,-1],
    [-1,1]
  ]

  def move_dirs
    DELTAS
  end
end

class Queen < SlidingPiece
  DELTAS = [
    [1,0],
    [-1,0],
    [0,1],
    [0,-1],
    [1,1],
    [-1,-1],
    [1,-1],
    [-1,1]
  ]

  def move_dirs
    DELTAS
  end
end

class InvalidMoveError < StandardError
end
