#!mruby

class Application

    def initialize
        Ssd1306.begin(0x3C)
        Ssd1306.set_text_wrap(false)
        Key.init
        Buzzer.init
        Debug.init
        BluetoothKeyboard.init
        Application.set_mode(:setup)
    end

    def self.set_mode(mode)
        @@mode = mode
    end

    def self.mode_eq(mode)
        @@mode == mode
    end
    
    def run
        presentation = Presentation.new
        setup = Setup.new

        loop do
            # キーの読み込み
            key = Key.read
            break if key == Key::BREAK  # for debug

            # 表示処理
            case @@mode
            when :setup
                setup.loop(key)
            when :main
                presentation.loop(key)
            when :start
                presentation.start(setup.pages, setup.minutes)
                Application.set_mode(:main)
            when :end
                setup = Setup.new
                Application.set_mode(:setup)
            end

            delay(20)
        end

        # 終了処理
        Ssd1306.clear_display;
        Ssd1306.display
    end
end

class ScreenBase
    CENTER_X = 44
    CENTER_Y = 37
    MARGIN_X = 64
    ANIMATION_STEPS = 2

    def draw_window(title, subtitle)
        Ssd1306.set_text_size(1)
        Ssd1306.draw_text(0, 7, title)
        Ssd1306.draw_text(0, 63, subtitle)
    end
    
    def draw_cursol
        Ssd1306.draw_line(32, 22, 32, 42)
        Ssd1306.draw_line(32, 22, 36, 22)
        Ssd1306.draw_line(32, 42, 36, 42)
        
        Ssd1306.draw_line(95, 22, 95, 42)
        Ssd1306.draw_line(91, 22, 95, 22)
        Ssd1306.draw_line(91, 42, 95, 42)
    end
end

class Presentation < ScreenBase
    ALERT_SECONDS = 5 # 5秒前にアラートする
    BREAK_LIMIT = 10 # 一時停止から強制終了までのしきい値
    
    def start(pages, minutes)
        @total_page = pages
        @limit_micros = micros + minutes * 60_000_000
        @current_page = 0
        
        @is_pause = false
        @alert = false
        @break_counter = 0
        
        next_page
    end
    
    def finish
        Application.set_mode(:end)
    end
    
    def loop(key)
        Ssd1306.clear_display;

        if micros > @next_micros and !@is_pause
            next_page
        else
            case key
            when Key::NEXT
                next_page
            when Key::PREV
                back_page
            when Key::SELECT
                @is_pause = true
                @break_counter += 1
                finish if @break_counter > BREAK_LIMIT
            else
                @break_counter = 0
            end
        end
        
        Ssd1306.set_text_size(3);
        if @is_pause
            Ssd1306.draw_text(0, CENTER_Y, "Pause")
        elsif @current_page < @total_page
            remain = (@next_micros - micros)
            b_w = (123 * remain / @micros_per_page).round
            Ssd1306.draw_rect(0, 22, 127, 20)
            Ssd1306.fill_rect(2, 24, b_w, 16)

            if remain < ALERT_SECONDS * 1_000_000 and !@alert
                @alert = true
                Buzzer.beep
            end
        end
        
        draw_window("Presentation Mode", "%d/%d" % [@current_page, @total_page])
        
        Ssd1306.display;
    end
    
    private

    def next_page
        if @current_page < @total_page
            @current_page += 1
            set_next_seconds
            BluetoothKeyboard.right_arrow
        else
            finish
        end
    end
    
    def back_page
        @current_page -= 1 if @current_page > 1
        set_next_seconds
        BluetoothKeyboard.left_arrow
    end
    
    def set_next_seconds
        @is_pause = false
        @alert = false

        remain_page = @total_page - @current_page
        return if remain_page == 0
        
        current_micros = micros
        @micros_per_page = (@limit_micros - current_micros) / remain_page
        @next_micros = current_micros + @micros_per_page
    end

end

class Setup < ScreenBase
    attr_accessor :pages, :minutes
    
    MODE = [:menu, :test, :pages, :minutes, :ok]
    MENU = ["Connection Test", "Pages", "Minutes", "Presentation Start"]
    MENU_TITLE = ["Test Mode", "Set Pages", "Set Minutes", "Presentation Mode"]

    def initialize
        @cursol = 0
        @prev_cursol = -1
        @mode = :menu
        
        @pages = 10
        @minutes = 1
        
        @dx = 0
    end
    
    def loop(key)
        
        case key
        when Key::SELECT
            case @mode
            when :menu
                @mode = MODE[@cursol + 1]
                if @mode == :ok
                    Application.set_mode(:start)
                    return
                end
            when :test
                @mode = :menu
            when :pages
                @mode = :menu
            when :minutes
                @mode = :menu
            end
        when Key::NEXT
            case @mode
            when :menu
                @cursol += 1
                @cursol = 0 if @cursol > MENU.count - 1
            when :test
                BluetoothKeyboard.right_arrow
            when :pages
                @pages += 1
            when :minutes
                @minutes += 1
            end
        when Key::PREV
            case @mode
            when :menu
                @cursol -= 1
                @cursol = MENU.count - 1 if @cursol < 0
            when :test
                BluetoothKeyboard.left_arrow
            when :pages
                @pages -= 1 if @pages > 0
            when :minutes
                @minutes -= 1 if @minutes > 0
            end
        end
        
        menu = MENU[@cursol]
        menu = MENU_TITLE[@cursol] if @mode == :test || @mode == :pages || @mode == :minutes

        if @cursol != @prev_cursol
            dx = (@cursol - @prev_cursol) * MARGIN_X / ANIMATION_STEPS
            x = CENTER_X - MARGIN_X * @prev_cursol
            
            ANIMATION_STEPS.times do
                x -= dx
                Ssd1306.clear_display;
                draw(x, menu)
                Ssd1306.display
            end
            
            @prev_cursol = @cursol
        elsif key != Key::NONE
            Ssd1306.clear_display;
            draw(CENTER_X - MARGIN_X * @cursol, menu)
            Ssd1306.draw_line(44, 48, 83, 48) if @mode == :test || @mode == :pages || @mode == :minutes
            Ssd1306.display
        end
    end

    private
    
    def draw(x, menu)
        Ssd1306.set_text_size(2);
        Ssd1306.use_dingbats_font
        Ssd1306.draw_text(x                + 6, CENTER_Y + 8, 179.chr)
        Ssd1306.draw_text(x + MARGIN_X * 3 + 6, CENTER_Y + 6, 204.chr)
        Ssd1306.reset_font
        Ssd1306.set_text_size(3);
        Ssd1306.draw_text(x + MARGIN_X * 1, CENTER_Y, "%02d" % [@pages])
        Ssd1306.draw_text(x + MARGIN_X * 2, CENTER_Y, "%02d" % [@minutes])

        draw_window("PRESENStick", menu)
        draw_cursol
    end

end

class Key
    # pin mode constant
    INPUT_PULLUP = 0x2
    LOW = 0

    # pin definition
    PIN_SELECT = 11 # pin for select button
    PIN_PREV = 10   # pin for previous button
    PIN_NEXT = 12   # pin for next button
    PIN_BREAK = 14  # pin for break button (for debug)

    # key code
    BREAK = -1
    NONE = 0
    PREV = 1
    NEXT = 2
    SELECT = 3

    def self.init
        pinMode(PIN_SELECT, INPUT_PULLUP)    # set pin to input
        pinMode(PIN_PREV, INPUT_PULLUP)      # set pin to input
        pinMode(PIN_NEXT, INPUT_PULLUP)      # set pin to input
        pinMode(PIN_BREAK, INPUT_PULLUP)     # set pin to input
    end

    def self.read
        return SELECT if digitalRead(PIN_SELECT) == LOW
        return PREV if digitalRead(PIN_PREV) == LOW
        return NEXT if digitalRead(PIN_NEXT) == LOW
        return BREAK if digitalRead(PIN_BREAK) == LOW
        NONE
    end
end

class Buzzer
    # pin mode constant
    OUTPUT = 0x1
    
    # pin definition
    PIN_BUZZER = 17 # pin for buzzer
    PIN_VIB = 16 # pin for buzzer

    DURATION = 100
    TONE = 3300
    
    def self.init
        pinMode(PIN_BUZZER, OUTPUT)    # set pin to putput
        pinMode(PIN_VIB, OUTPUT)
    end
    
    def self.beep
        digitalWrite(PIN_VIB, 1)
        3.times do
            tone(PIN_BUZZER, TONE, DURATION)
            delay(DURATION)
        end
        digitalWrite(PIN_VIB, 0)
    end
end

class BluetoothKeyboard
    @@serial = nil
    def self.init
        @@serial = Serial.new(1, 9600)
    end
    def self.right_arrow
        Debug.println("next")
        self.send_key(0x4F)
    end

    def self.left_arrow
        Debug.println("prev")
        self.send_key(0x50)
    end

    def self.send_key(key)
      self.send_keycode(key, 0x00);
      delay 50
      self.send_keycode(0x00, 0x00);
    end
    
    def self.send_keycode(key, modifier)
        @@serial.write(0xFD.chr, 1) # Raw Report Mode
        @@serial.write(0x09.chr, 1) # Length
        @@serial.write(0x01.chr, 1) # Descriptor 0x01=Keyboard
    
        @@serial.write(modifier.chr, 1)
        @@serial.write(0x00.chr, 1)
        @@serial.write(key.chr, 1)
        @@serial.write(0x00.chr, 1)
        @@serial.write(0x00.chr, 1)
        @@serial.write(0x00.chr, 1)
        @@serial.write(0x00.chr, 1)
        @@serial.write(0x00.chr, 1)
    end
end

class Debug
    @@serial = nil
    def self.init
        @@serial = Serial.new(0, 115200)
    end

    def self.println(message)
        @@serial.println(message) unless @@serial.nil?
    end
end

Application.new.run