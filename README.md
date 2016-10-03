# PRESENStick

## RN42 Setup
http://www.microchip.com/wwwproducts/en/en558330

RN42をシリアルでつなぎHIDモードへ設定します。

```
$$$     # CMD mode
S~,6    # HID
SH,0200 # Keyboard
SM,6    # Pairing Mode
SU,96   # 9600bps
SN,PRESENStick
R,1     # reboot
```
