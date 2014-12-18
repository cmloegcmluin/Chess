class HumanPlayer

  def initialize
    @cursor = [4,4]
    @start_pos = []
    @end_pos = []
    @grabbing = false

    @turn_time = 0
    @max_turn_time = 0
  end

  def play_turn
    @successful_move = false
    @timer = Time.now.to_i
    @turn_time = 0
    until @successful_move
      if Time.now.to_i > @timer + @turn_time
        update_timer
      else
        wait_for_input
      end
    end
  end

  def update_timer
    @turn_time = Time.now.to_i - @timer
    @board.render
    if @turn_time > @max_turn_time
      @turn_time = @max_turn_time
      puts "\nOUT OF TIME!"
      exit
    end
  end

  def wait_for_input
    begin
      input(read_char)
      @board.render
    rescue ArgumentError => bad_move
      puts bad_move.message
      retry
    end
  end

  def toggle_grabbing
    @grabbing = (@grabbing == true ? false : true)
  end

  def input(key)
    case key
    when "\e[A"
      @cursor[0] -= 1 if @cursor[0] > 0
    when "\e[D"
      @cursor[1] -= 1 if @cursor[1] > 0
    when "\e[B"
      @cursor[0] += 1 if @cursor[0] < 7
    when "\e[C"
      @cursor[1] += 1 if @cursor[1] < 7
    when "\r"
      attempt_action
    when 's'
      File.open("chess_#{Time.now}.yml", "w") do |f|
        f.puts self.to_yaml
      end
    when 'l'
      print "Filename: "
      File.open(gets.chomp) do |f|
        loaded_game = YAML.load(f)
        load_game(loaded_game)
      end
    when "\e"
      exit
    else
      puts key
    end
  end

  def attempt_action
    @grabbing ? @end_pos = @cursor.dup : @start_pos = @cursor.dup
    raise NoPiece.new("\n\nNo piece there! ") if @board[@start_pos].nil?
    raise NotYours.new("\n\nThat's not your piece! ") if @board[@start_pos].color != turn
    toggle_grabbing
    @board.move(@start_pos, @end_pos) unless @grabbing
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!
    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!
    return input
  end

end
