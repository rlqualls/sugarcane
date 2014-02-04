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

    def initialize(checks, opts, height = 30)
      @checks = checks
      @opts = opts
      @height = height
      check_violations
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
        if Ncurses.has_colors?
          @background_color = Ncurses::COLOR_BLACK
          Ncurses.init_pair(1, Ncurses::COLOR_WHITE, @background_color)
          Ncurses.init_pair(2, Ncurses::COLOR_BLUE, @background_color)
          Ncurses.init_pair(3, Ncurses::COLOR_CYAN, @background_color)
          Ncurses.init_pair(4, Ncurses::COLOR_RED, @background_color)
          Ncurses.init_pair(5, Ncurses::COLOR_GREEN, @background_color)
        end

        title_window = Ncurses::WINDOW.new(5, Ncurses.COLS - 2,2,1)
        menu = Ncurses::WINDOW.new(@height + 2, Ncurses.COLS - 2,7,1)
        fix_window = Ncurses::WINDOW.new(3, Ncurses.COLS - 2,@height+9,1)
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
          when KEY_ENTER
            edit_file(@data[@data_position][:file], @data[@data_position][:line])
            check_violations
          when KEY_Q
            clean_up
            break
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
        position = i + @data_position - @menu_position
        file = @data[position][:file]
        if @data[position][:line]
          line = " #{@data[position][:line]}: "
        else
          line = " "
        end
        desc = @data[position][:menu_description] || ""
        if desc.length > Ncurses.COLS - 10
          desc << "..."
        end
        if i == active_index
          style = Ncurses::A_STANDOUT
          menu.attrset(style)
          menu.addstr(file)
          menu.addstr(line)
          menu.addstr(desc)
        else
          # style = Ncurses::A_NORMAL
          menu.attrset(Ncurses.COLOR_PAIR(2))
          menu.addstr(file)
          menu.attrset(Ncurses.COLOR_PAIR(3))
          menu.addstr(line)
          menu.attrset(Ncurses.COLOR_PAIR(4))
          menu.addstr(desc)
          menu.attrset(Ncurses.COLOR_PAIR(1))
        end
      end
      menu.refresh
    end

    def draw_title_window(window)
      window.clear
      # window.border(*([0]*8))
      window.attrset(Ncurses.COLOR_PAIR(5))
      window.addstr(TITLE)
      window.attrset(Ncurses.COLOR_PAIR(1))
      window.refresh
    end

    def draw_fix_window(window)
      window.clear
      window.border(*([0]*8))
      window.move(1, 1)
      line = "Violations left: #{@data.size}"
      window.addstr(line)
      window.refresh
    end

    def clean_up
      Ncurses.stdscr.clear
      Ncurses.stdscr.refresh
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
      Ncurses.endwin
    end

    def select(item)
      clean_up
    end

    def edit_file(file, line)
      if ENV['VISUAL']
        system("#{ENV['VISUAL']} +#{line} #{file}")
      elsif program_exist? "vim"
        system("vim +#{line} #{file}")
      elsif program_exist? "gedit"
        system("gedit +#{line} #{file}")
      elsif program_exist? "geany"
        system("geany +#{line} #{file}")
      elsif program_exist? "nano"
        system("nano +#{line} #{file}")
      else
        # :(
        system("notepad.exe #{file}")
      end
    end

    # Allegedly cross-platform way to determine if an executable is in PATH
    def program_exist?(command)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(::File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = ::File.join(path, "#{command}#{ext}")
          return exe if ::File.executable? exe
        }
      end
      return nil
    end

    def check_violations
      violations = @checks.
        map {|check| check.new(@opts).violations }.
        flatten
      @data = violations
      @height = [@data.size,@height].min
      @size = @data.size
      @min_position = 0
      @max_position = @height - 1
      @data_position ||= 0
      @menu_position ||= 0
      if @data_position > @size - 1
        @data_position = @size - 1
      end
      return violations
    end
  end
end
