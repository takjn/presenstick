# PRESENStick
![PRESENStick](https://github.com/takjn/presenstick/raw/master/pictures/PRESENStick.jpg)

## Hardware
### Parts list
ほぼすべての部品が秋月電子で購入できます。回路図はschematic.pdfをご確認ください。

|記号 |パーツ	                                               　　　|補足	    |数量|
|:---|:----------------------------------------------------------|:----------------|:-------|
|U1  |0.96インチ 128x64 I2C接続 OLEDディスプレイ SSD1306               |Amazonで購入可能   |1       |
|U2  |[昇圧型DCDCコンバータ 3.3V](http://akizukidenshi.com/catalog/g/gM-05720/) |M-05720 |1       |
|U3  |[GR-CITRUS](http://akizukidenshi.com/catalog/g/gK-11217/)  |K-11217 |1       |
|U4  |[RN-42-I/RM](http://akizukidenshi.com/catalog/g/gM-07612/) |M-07612 |1       |
|M1  |[振動モーター](http://akizukidenshi.com/catalog/g/gP-00933/) |P-00933 |1       |
|B1  |[電子ブザー](http://akizukidenshi.com/catalog/g/gP-04497/)  |P-04497 |1       |
|Q1  |[Nch MOSFET 2SK4017](http://akizukidenshi.com/catalog/g/gI-07597/)  |I-07597 |1       |
|C1  |[電解コンデンサ 100μF](http://akizukidenshi.com/catalog/g/gP-03122/)  |P-03122 |1       |
|R1  |[抵抗 330Ω](http://akizukidenshi.com/catalog/g/gR-25331/)  |R-25331 |1       |
|SW1,SW2,SW3    |[タクトスイッチ 6mm](http://akizukidenshi.com/catalog/g/gP-09824/)  |P-09824 |3       |
|BT1 |[電池ボックス 単4×2本 リード線](http://akizukidenshi.com/catalog/g/gP-02245/)  |P-02245 |1       |
|-   |[片面ユニバーサル基板 140ｘ40mm](http://akizukidenshi.com/catalog/g/gP-03250/)  |P-03250 |1       |
|-   |[2.54mm ピンヘッダ](http://akizukidenshi.com/catalog/g/gC-00167/)  |C-00167 |1       |
|-   |[2.54mm ピンソケット](http://akizukidenshi.com/catalog/g/gC-05779/) |C-05779 |1       |
|-   |[1.27mm ピンヘッダ](http://akizukidenshi.com/catalog/g/gC-03865/)  |C-03865 |1       |
|-   |[1.27mm ジャンパーピン](http://akizukidenshi.com/catalog/g/gP-03912/)  |P-03912 |1       |
|-   |タミヤ プラバン 1.0mm    |外装で利用          |1       |
|-   |タミヤ プラ材 5mm L形棒  |外装で利用          |1       |
|-   |天然木シート  |外装で利用          |1       |



## Software
### RN42 setup
[RN42](http://www.microchip.com/wwwproducts/en/en558330)をシリアルでつなぎHIDモードへ設定します。
ターミナルから以下のコマンドを入力してください。（#文字以降は入力不要）

```
$$$               # CMD mode
S~,6              # HID
SH,0200           # Keyboard
SM,6              # Pairing mode
SU,96             # 9600bps
SN,PRESENStick    # Device name
R,1               # reboot
```
