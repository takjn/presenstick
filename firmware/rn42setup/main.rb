#!mruby

class Setup

    def initialize
        @debug = Serial.new(0,115200)
        @rn42 = Serial.new(1, 115200)
    end

    def send_command(cmd)
        @debug.print(cmd)
        @rn42.print(cmd)
        delay 1000
        while @rn42.available > 0 do
            c = @rn42.read
            @debug.print c
        end
    end

    def run
        @debug.println("SETUP start")
        send_command("$$$")                 # CMD mode
        send_command("S~,6\r\n")            # HID
        send_command("SH,0200\r\n")         # Keyboard
        send_command("SM,6\r\n")            # Pairing mode
        send_command("SU,96\r\n")           # 9600bps
        send_command("SN,PRESENStick\r\n")  # Device name
        send_command("R,1\r\n")             # reboot

        @debug.println("SETUP done")
    end
end

Setup.new.run

