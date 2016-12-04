#!mruby

class Application

    def initialize
        Ssd1306.begin(0x3C)
        Ssd1306.set_text_wrap(false)
        Rtc.init
        Rtc.setTime([2016,10,27,0,0,0])
        Key.init
        Buzzer.init
        # Debug.init
        BluetoothKeyboard.init
        Application.set_mode(:setup)
    end

    def self.set_mode(mode)
        @@mode = mode
    end

    # def self.mode_eq(mode)
    #     @@mode == mode
    # end

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

            delay 20
        end

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
        @limit_seconds = Rtc.unixtime + minutes * 60
        @current_page = 0

        Debug.println("limit_seconds:#{@limit_seconds}")

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

        if Rtc.unixtime > @next_seconds and !@is_pause
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

        if @is_pause
            Ssd1306.set_text_size(3);
            Ssd1306.draw_text(0, CENTER_Y, "Pause")
        elsif @current_page < @total_page
            remain = (@next_seconds - Rtc.unixtime)
            b_w = (123 * remain / @seconds_per_page).round
            Ssd1306.draw_rect(0, 22, 127, 20)
            Ssd1306.fill_rect(2, 24, b_w, 16)

            if remain < ALERT_SECONDS and !@alert
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
            BluetoothKeyboard.send_key(BluetoothKeyboard::RIGHT_ARROW)
        else
            finish
        end
    end

    def back_page
        @current_page -= 1 if @current_page > 1
        set_next_seconds
        BluetoothKeyboard.send_key(BluetoothKeyboard::LEFT_ARROW)
    end

    def set_next_seconds
        @is_pause = false
        @alert = false

        remain_page = @total_page - @current_page
        return if remain_page == 0

        current_seconds = Rtc.unixtime
        @seconds_per_page = ((@limit_seconds - current_seconds) / remain_page).round
        @next_seconds = current_seconds + @seconds_per_page

        Debug.println("current_seconds:#{current_seconds}")
        Debug.println("seconds_per_page:#{@seconds_per_page}")
        Debug.println("next_seconds:#{@next_seconds}")
    end

end

class Setup < ScreenBase
    attr_accessor :pages, :minutes

    MODE = [:menu, :test, :pages, :minutes, :ok]
    MENU = ["Connection Test", "Pages", "Minutes", "Presentation Start"]
    MENU_TITLE = ["Test Mode", "Set Pages", "Set Minutes"]

    def initialize
        @cursol = 0
        @prev_cursol = -1
        @mode = :menu

        @pages = 10
        @minutes = 1
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
            else
                @mode = :menu
            end
        when Key::NEXT
            case @mode
            when :menu
                @cursol += 1
                @cursol = 0 if @cursol > MENU.count - 1
            when :test
                BluetoothKeyboard.send_key(BluetoothKeyboard::RIGHT_ARROW)
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
                BluetoothKeyboard.send_key(BluetoothKeyboard::LEFT_ARROW)
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
        pinMode(PIN_SELECT, 0x2)    # set pin to input_pullup
        pinMode(PIN_PREV, 0x2)      # set pin to input_pullup
        pinMode(PIN_NEXT, 0x2)      # set pin to input_pullup
        pinMode(PIN_BREAK, 0x2)     # set pin to input_pullup
    end

    def self.read
        return SELECT if digitalRead(PIN_SELECT) == 0
        return PREV if digitalRead(PIN_PREV) == 0
        return NEXT if digitalRead(PIN_NEXT) == 0
        return BREAK if digitalRead(PIN_BREAK) == 0
        NONE
    end
end

class Buzzer
    # pin definition
    PIN_BUZZER = 17 # pin for buzzer
    PIN_VIB = 16 # pin for buzzer

    DURATION = 100
    TONE = 3300

    def self.init
        pinMode(PIN_BUZZER, 0x1)    # set pin to output
        pinMode(PIN_VIB, 0x1)       # set pin to output
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
    RIGHT_ARROW = 0x4F
    LEFT_ARROW = 0x50
    DOWN_ARROW = 0x51
    UP_ARROW = 0x52

    @@serial = nil
    def self.init
        @@serial = Serial.new(1, 9600)
    end

    def self.send_key(key)
      self.send_keycode(key, 0x00);
      delay 5
      self.send_keycode(0x00, 0x00);
    end

    def self.send_keycode(key, modifier)
        [0xFD, 0x09, 0x01, modifier, 0x00, key, 0x00, 0x00, 0x00, 0x00, 0x00].each do |code|
            @@serial.write(code.chr, 1)
        end
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
