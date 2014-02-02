require "ncursesw"

module SugarCane
  class Menu

  TITLE = <<-'SUGARCANE'
  ___ _   _  __ _  __ _ _ __ ___ __ _ _ __   ___
 / __| | | |/ _` |/ _` | '__/ __/ _` | '_ \ / _ \
 \__ \ |_| | (_| | (_| | | | (_| (_| | | | |  __/
 |___/\__,_|\__, |\__,_|_|  \___\__,_|_| |_|\___|
            |___/
  SUGARCANE

    # Don't trust ncursew keys as they don't always work
    KEY_C = 99
    KEY_Q = 113
    KEY_J = 106
    KEY_K = 107
    KEY_UP = 258
    KEY_DOWN = 259
    KEY_ENTER = 13

    def initialize(violations, height = 10)
      @data = violations
      @height = [violations.size, height].min
      @size = @data.size
      @min_position = 0
      @max_position = @height - 1
    end

    def run
      if @data.nil? or @data.empty?
        return nil
      end
      begin
        Ncurses.initscr
        Ncurses.cbreak
        Ncurses.start_color
        Ncurses.noecho
        Ncurses.nonl
        Ncurses.curs_set(0)
        # Ncurses.keypad(screen, true)
        @menu_position = 0
        @data_position = 0

        title_window = Ncurses::WINDOW.new(5, Ncurses.COLS - 2,2,1)
        menu = Ncurses::WINDOW.new(@height + 2, Ncurses.COLS - 2,7,1)
        fix_window = Ncurses::WINDOW.new(3, Ncurses.COLS - 2,@height+10,1)
        draw_menu(menu, @menu_position)
        draw_fix_window(fix_window)
        draw_title_window(title_window)
        while ch = menu.wgetch
          case ch
          when KEY_K, KEY_UP
            # draw_info menu, 'move up'
            @menu_position -= 1 unless @menu_position == @min_position
            @data_position -= 1 unless @data_position == 0
          when KEY_J, KEY_DOWN
            # draw_info menu, 'move down'
            @menu_position += 1 unless @menu_position == @max_position
            @data_position += 1 unless @data_position == @size - 1
          when KEY_C
            clone
            break
          when KEY_ENTER
            break
          when KEY_Q
            exit
          end
          # @data_position = @size - 1 if @data_position < 0
          # @data_position = 0 if @data_position > @size - 1
          draw_menu(menu, @menu_position)
          draw_fix_window(fix_window)
          draw_title_window(title_window)
        end
        return @data[@data_position]
      ensure
        clean_up
      end
    end

    def draw_menu(menu, active_index=nil)
      Ncurses.stdscr.border(*([0]*8))
      Ncurses.stdscr.refresh
      menu.clear
      menu.border(*([0]*8))
      @height.times do |i|
        menu.move(i + 1, 1)
        if i == active_index
          style = Ncurses::A_STANDOUT
        else
          style = Ncurses::A_NORMAL
        end
        menu.attrset(style)
        position = i + @data_position - @menu_position
        file = @data[position][:file]
        if @data[position][:line]
          line = " #{@data[position][:line]}: "
        else
          line = " "
        end
        desc = @data[position][:description] || ""
        menu_item = "#{file}#{line}#{desc}"
        if menu_item.length > Ncurses.COLS - 10
          menu_item << "..."
        end
        menu.addstr(menu_item)
      end
      menu.refresh
    end

    def draw_title_window(window)
      window.clear
      # window.border(*([0]*8))
      window.addstr(TITLE)
      window.refresh
    end

    def draw_fix_window(window)
      window.clear
      window.border(*([0]*8))
      current = @data[@data_position]
      label = current[:label] if current
      severity = " - Severity: #{current[:value]}" if current
      window.move(1, 1)
      line = "#{label} #{severity}"
      window.addstr(line)
      window.refresh
    end

    def clean_up
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
      Ncurses.endwin
    end

    def select(item)
      clean_up
    end
  end
end
