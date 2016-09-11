#!mruby

class Application

    def initialize
        # Rtc.init
        # Rtc.setTime([2016, 9, 7, 00, 00, 00])
        Ssd1306.begin(0x3C)
        Ssd1306.set_text_wrap(false)
        Key.init
        Debug.init
        Application.set_mode(:main)
    end

    def self.set_mode(mode)
        @@mode = mode
    end

    def self.mode_eq(mode)
        @@mode == mode
    end
    
    def splash
        Ssd1306.clear_display
        Ssd1306.set_text_size(1)
        Ssd1306.draw_text(0, 36, "PRESENStick")
        Ssd1306.display

        delay(1000)
    end

    def run
        # splash

        # presentation = Presentation.new
        # presentation.start(15, 1)
        setup = Setup.new


        loop do
            # キーの読み込み
            key = Key.read
            break if key == Key::BREAK  # for debug

            # 表示処理
            case @@mode
            when :main
                # presentation.loop(key)
                setup.loop(key)
            end

            delay(50)
        end

        # 終了処理
        Ssd1306.clear_display;
        Ssd1306.display
    end
end

# class Presentation
#     def start(pages, minutes)
#         Debug.println("start: #{micros}")
#         @total_page = pages
#         @limit_micros = micros + minutes * 60 * 1000 * 1000
#         @current_page = 0
#         @is_pause = false
        
#         next_page
#     end
    
#     def finish
#         Debug.println("end: #{micros}")
#         Application.set_mode(:menu)
#     end
    
#     def loop(key)

#         if micros > @next_micros and !@is_pause
#             next_page
#         else
#             case key
#             when Key::NEXT
#                 next_page
#             when Key::PREV
#                 back_page
#             when Key::SELECT
#                 @is_pause = true
#                 Debug.println("Paused")
#             end
#         end
        
#         Ssd1306.set_text_size(2);
#         Ssd1306.draw_text(0,62, "%d/%d" % [@current_page, @total_page])
        
#         Ssd1306.set_text_size(3);
#         if @is_pause
#             Ssd1306.draw_text(0, 36, "Paused")
#         elsif @current_page < @total_page
#             remain = ((@next_micros - micros) / 1000000)
#             Ssd1306.draw_text(0, 36, "%d" % [remain])
#         end

#     end
    
#     private

#     def next_page
#         if @current_page < @total_page
#             @current_page += 1
#             set_next_seconds
#         else
#             finish
#         end
#     end
    
#     def back_page
#         @current_page -= 1 if @current_page > 1
#         set_next_seconds
#     end
    
#     def set_next_seconds
#         @is_pause = false
#         remain_page = @total_page - @current_page
#         return if remain_page == 0
        
#         current_micros = micros
#         micros_per_page = (@limit_micros - current_micros) / remain_page
#         @next_micros = current_micros + micros_per_page
#     end

# end

class Setup
    MODE = [:menu, :pages, :minutes, :ok, :cancel]
    MENU = ["Pages", "Minutes", "OK", "Cancel"]
    
    def initialize
        @cursol = 0
        @prev_cursol = 0
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
                @mode = MODE[@cursol]
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
            when :pages
                @pages -= 1 if @pages > 0
            when :minutes
                @minutes -= 1 if @minutes > @pages > 0
            end
        end
        

        CENTER_X = 44
        CENTER_Y = 37
        MARGIN_X = 64 
        ANIMATION_STEPS = 2

        case @mode
        when :menu
            return if @cursol == @prev_cursol
            
            dx = (@cursol - @prev_cursol) * MARGIN_X / ANIMATION_STEPS

            x = CENTER_X - MARGIN_X * @prev_cursol
            ANIMATION_STEPS.times do
                x -= dx
                
                Ssd1306.clear_display;
                Ssd1306.set_text_size(3);
                Ssd1306.draw_text(x               , CENTER_Y, "%02d" % [@pages])
                Ssd1306.draw_text(x + MARGIN_X * 1, CENTER_Y, "%02d" % [@minutes])
                Ssd1306.draw_text(x + MARGIN_X * 2, CENTER_Y, "OK")
                Ssd1306.draw_text(x + MARGIN_X * 3, CENTER_Y, "CA")

                Ssd1306.set_text_size(1);
                Ssd1306.draw_text(0, 7, "Setup")
                Ssd1306.draw_text(0, 63, MENU[@cursol]);

                Ssd1306.draw_line(0, 32, 127 , 32);
                Ssd1306.draw_line(63, 0, 63 , 63);
                Ssd1306.draw_line(0, 0, 0, 63);
                Ssd1306.draw_line(127, 0, 127, 63);

                Ssd1306.display
            end
            
            @prev_cursol = @cursol


        when :pages
            Ssd1306.clear_display
            Ssd1306.set_text_size(1);
            Ssd1306.draw_text(0, 7, "Setup")

            Ssd1306.set_text_size(1);
            Ssd1306.set_cursor(0,36);
            Ssd1306.print("pages: #{@pages}");

            Ssd1306.set_text_size(1);
            Ssd1306.set_cursor(0,63);
            Ssd1306.print(MENU[@cursol]);

            Ssd1306.display
        when :minutes
            Ssd1306.clear_display
            Ssd1306.set_text_size(1);
            Ssd1306.draw_text(0, 7, "Setup")


            Ssd1306.set_text_size(1);
            Ssd1306.set_cursor(0,36);
            Ssd1306.print("minutes: #{@minutes}");

            Ssd1306.set_text_size(1);
            Ssd1306.set_cursor(0,63);
            Ssd1306.print(MENU[@cursol]);

            Ssd1306.display
        end

    end

    # @@cursol = 0

    # def self.set_time(key)
    #     year, month, day, hour, minute, second, weekday = Rtc.getTime

    #     case key
    #     when Key::SELECT
    #         if @@cursol == 5
    #             @@cursol = 0
    #             Application.set_mode(:watch)
    #             return
    #         end

    #         @@cursol += 1
    #         Debug.println("cursol=#{@@cursol}")

    #     when Key::NEXT, Key::PREV
    #         end_of_month = get_end_of_month(month)

    #         case @@cursol
    #         when 0
    #             year=   case key
    #                     when Key::NEXT
    #                         year + 1
    #                     when Key::PREV
    #                         year - 1
    #                     end
    #         when 1
    #             month=  case key
    #                     when Key::NEXT
    #                         month < 12 ? month + 1 : 1
    #                     when Key::PREV
    #                         month > 1 ? month - 1 : 12
    #                     end
    #         when 2
    #             day=    case key
    #                     when Key::NEXT
    #                         day < end_of_month ? day + 1 : 1
    #                     when Key::PREV
    #                         day > 1 ? day - 1 : end_of_month
    #                     end
    #         when 3
    #             hour=   case key
    #                     when Key::NEXT
    #                         hour < 23 ? hour + 1 : 0
    #                     when Key::PREV
    #                         hour > 1  ? hour - 1 : 23
    #                     end
    #         when 4
    #             minute= case key
    #                     when Key::NEXT
    #                         minute < 59 ? minute + 1 : 0
    #                     when Key::PREV
    #                         minute > 1  ? minute - 1 : 59
    #                     end
    #         when 5
    #             second = 0
    #         end

    #         Rtc.setTime([year, month, day, hour, minute, second])
    #     end

    #     # カーソルの表示
    #     case @@cursol
    #     when 0
    #         Ssd1306.draw_line(77, 6, 105-1 , 6);
    #     when 1
    #         Ssd1306.draw_line(49, 6, 70-1 , 6);
    #     when 2
    #         Ssd1306.draw_line(28, 6, 42-1 , 6);
    #     when 3
    #         Ssd1306.draw_line(0, 40, 38, 40);
    #     when 4
    #         Ssd1306.draw_line(51, 40, 88, 40);
    #     when 5
    #         Ssd1306.draw_line(93, 40, 119, 40);
    #     end

    #     # モードの表示
    #     Ssd1306.set_text_size(1);
    #     Ssd1306.set_cursor(0,63);
    #     Ssd1306.print(MODE[@@cursol]);
    # end
end


# class CalendarBase
#   MONTH = %w( January Feburary March April May June July August September October November December )
#   MONTH_SHORT = %w( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )
#   DAY_SHORT = %w( SUN MON TUE WED THU FRI SAT )
#   DAY_TINY = %w( SU MO TU WE TH FR SA )

#   # 月末日を取得
#   def self.get_end_of_month(month)
#     case month
#       when 2
#           28  # TODO:うるう年の考慮はできていない
#       when 4, 6, 9, 11
#           30
#       else
#           31
#       end
#   end

#   # 日付から曜日を取得 (戻り値が0=日曜日、6=土曜日)
#   def self.zeller(year, month, day)
#       case month
#       when 1, 2
#           monthind = month + 12
#           year -=1
#       else
#           monthind = month
#       end

#       monthind += 1
#       monthPart = ((monthind*26)/10).floor

#       yearPart = year + (year/4).floor
#       yearPart += 6*(year/100).floor
#       yearPart += (year/400).floor

#       h = (day + monthPart + yearPart) % 7
#       if h == 0
#           h = 6
#       else
#           h -= 1
#       end
#   end
# end

# class SetTime < CalendarBase
#     MODE = ["Set year", "Set month", "Set day", "Set hour", "Set minute", "Set second"]

#     @@cursol = 0

#     def self.set_time(key)
#         year, month, day, hour, minute, second, weekday = Rtc.getTime

#         case key
#         when Key::SELECT
#             if @@cursol == 5
#                 @@cursol = 0
#                 Application.set_mode(:watch)
#                 return
#             end

#             @@cursol += 1
#             Debug.println("cursol=#{@@cursol}")

#         when Key::NEXT, Key::PREV
#             end_of_month = get_end_of_month(month)

#             case @@cursol
#             when 0
#                 year=   case key
#                         when Key::NEXT
#                             year + 1
#                         when Key::PREV
#                             year - 1
#                         end
#             when 1
#                 month=  case key
#                         when Key::NEXT
#                             month < 12 ? month + 1 : 1
#                         when Key::PREV
#                             month > 1 ? month - 1 : 12
#                         end
#             when 2
#                 day=    case key
#                         when Key::NEXT
#                             day < end_of_month ? day + 1 : 1
#                         when Key::PREV
#                             day > 1 ? day - 1 : end_of_month
#                         end
#             when 3
#                 hour=   case key
#                         when Key::NEXT
#                             hour < 23 ? hour + 1 : 0
#                         when Key::PREV
#                             hour > 1  ? hour - 1 : 23
#                         end
#             when 4
#                 minute= case key
#                         when Key::NEXT
#                             minute < 59 ? minute + 1 : 0
#                         when Key::PREV
#                             minute > 1  ? minute - 1 : 59
#                         end
#             when 5
#                 second = 0
#             end

#             Rtc.setTime([year, month, day, hour, minute, second])
#         end

#         # カーソルの表示
#         case @@cursol
#         when 0
#             Ssd1306.draw_line(77, 6, 105-1 , 6);
#         when 1
#             Ssd1306.draw_line(49, 6, 70-1 , 6);
#         when 2
#             Ssd1306.draw_line(28, 6, 42-1 , 6);
#         when 3
#             Ssd1306.draw_line(0, 40, 38, 40);
#         when 4
#             Ssd1306.draw_line(51, 40, 88, 40);
#         when 5
#             Ssd1306.draw_line(93, 40, 119, 40);
#         end

#         # モードの表示
#         Ssd1306.set_text_size(1);
#         Ssd1306.set_cursor(0,63);
#         Ssd1306.print(MODE[@@cursol]);
#     end
# end

# class Calendar < CalendarBase
#     COL_PX = 18 # 列の幅
#     ROW_PX = 7  # 行の高さ

#     def self.display(key)
#         year, month, day, hour, minute, second, weekday = Rtc.getTime

#         Ssd1306.set_text_size(1);
#         Ssd1306.set_cursor(0, 4);
#         Ssd1306.print("#{MONTH[month - 1]} #{year}");

#         # 曜日の表示
#         DAY_TINY.each_with_index do |item, i|
#             Ssd1306.set_cursor(i * COL_PX, 11);
#             Ssd1306.print(item);
#         end

#         end_of_month = get_end_of_month(month)
#         week = zeller(year, month, 1)
#         Debug.println("week= #{week}")
#         y = 19

#         end_of_month.times do |d|
#             d += 1
#             Ssd1306.set_cursor(week * COL_PX, y)
#             if d < 10
#                 Ssd1306.print(" #{d}")
#             else
#                 Ssd1306.print("#{d}")
#             end

#             if d == day
#                 Ssd1306.draw_line(week * COL_PX, y + 1, week * COL_PX + 14, y + 1);
#             end

#             if week < 6
#                 week += 1
#             else
#                 week = 0
#                 y += ROW_PX
#             end
#         end

#         # ロゴの表示
#         Ssd1306.set_text_size(1);
#         Ssd1306.draw_text(0, 63, "Calendar");

#         Application.set_mode(:watch) if key == Key::PREV

#     end
# end

# class Watch < CalendarBase
#     def self.display(key)
#         year, month, day, hour, minute, second, weekday = Rtc.getTime

#         # 年月日の表示
#         Ssd1306.set_text_size(1)
#         Ssd1306.draw_text(0, 4, "#{DAY_SHORT[weekday]} #{day} #{MONTH_SHORT[month - 1]} #{year}")

#         # 時、分の表示
#         Ssd1306.set_text_size(3);
#         Ssd1306.draw_text(0, 36, "%02d:%02d" % [hour, minute])  # mrbgemのmruby-sprintfが必要

#         # 秒の表示
#         Ssd1306.set_text_size(2);
#         Ssd1306.draw_text(93, 37, "%02d" % second)   # mrbgemのmruby-sprintfが必要

#         # ロゴの表示
#         if Application.mode_eq(:watch)
#             Ssd1306.set_text_size(1)
#             Ssd1306.draw_text(0, 63, "Watch")
#         end

#         case key
#         when Key::SELECT
#             Application.set_mode(:set_time)
#         when Key::NEXT
#             Application.set_mode(:calendar)
#         end
#     end
# end

class Key
    # pin mode constant
    INPUT_PULLUP = 0x2
    LOW = 0

    # pin definition
    PIN_SELECT = 11 # pin for select button
    PIN_PREV = 12   # pin for previous button
    PIN_NEXT = 10   # pin for next button
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