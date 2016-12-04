# PRESENStick
![PRESENStick](https://github.com/takjn/presenstick/raw/master/pictures/PRESENStick.jpg)

## Hardware
### Schematic
回路図はschematicフォルダ内のPDFファイルをご確認ください。

### Parts list
OLEDを除き、秋月電子通商で購入できます。

|記号 |パーツ	                                               　　　|通販コード |数量|
|:---|:----------------------------------------------------------|:----------------|:-------|
|U1  |0.96インチ 128x64 I2C接続 OLEDディスプレイ SSD1306               |Amazonやaitendoで購入可能   |1       |
|U2  |[昇圧型DCDCコンバータ 3.3V](http://akizukidenshi.com/catalog/g/gM-05720/) |M-05720 |1       |
|U3  |[GR-CITRUS](http://akizukidenshi.com/catalog/g/gK-11217/)  |K-11217 |1       |
|U4  |[RN-42-I/RM](http://akizukidenshi.com/catalog/g/gM-07612/) |M-07612 |1       |
|M1  |[振動モーター](http://akizukidenshi.com/catalog/g/gP-00933/) |P-00933 |1       |
|B1  |[電子ブザー](http://akizukidenshi.com/catalog/g/gP-09800/)  |P-09800 |1       |
|Q1  |[Nch MOSFET 2SK4017](http://akizukidenshi.com/catalog/g/gI-07597/)  |I-07597 |1       |
|C1  |[電解コンデンサ 100μF](http://akizukidenshi.com/catalog/g/gP-03122/)  |P-03122 |1       |
|R1  |[抵抗 330Ω](http://akizukidenshi.com/catalog/g/gR-25331/)  |R-25331 |1       |
|SW1,SW2,SW3    |[タクトスイッチ 6mm](http://akizukidenshi.com/catalog/g/gP-09824/)  |P-09824 |3       |
|BT1 |[電池ボックス 単4×2本 リード線](http://akizukidenshi.com/catalog/g/gP-02245/)  |P-02245 |1       |
|-   |[片面ユニバーサル基板 140ｘ40mm](http://akizukidenshi.com/catalog/g/gP-03250/)  |P-03250 |1       |
|-   |[2.54mm 細ピンヘッダ](http://akizukidenshi.com/catalog/g/gC-06631/) - GR-CITRUSに利用 |C-06631 |1 |
|-   |[2.54mm 細ピンソケット](http://akizukidenshi.com/catalog/g/gC-10073/) - GR-CITRUSに利用|C-10073 |2 |
|-   |[2.54mm ピンソケット](http://akizukidenshi.com/catalog/g/gC-05779/) - OLEDに利用|C-05779 |1 |
|-   |[1.27mm ピンヘッダ](http://akizukidenshi.com/catalog/g/gC-03865/) - GR-CITRUSのJP2に利用 |C-03865 |1       |
|-   |[1.27mm ジャンパーピン](http://akizukidenshi.com/catalog/g/gP-03912/) - GR-CITRUSのJP2に利用 |P-03912 |1       |

## Build instructions
### Prototyping
ブレッドボードを利用したプロトタイプの作り方は[こちら](https://github.com/takjn/presenstick/wiki/Prototyping)。  
実際の作品は同様の手順でユニバーサル基板に実装しています。

### GR-CITRUS mruby custom firmware
カスタマイズしたファームウェアを利用しています。  
firmwareフォルダにあるcitrus_sketch.binをGR-CITRUSに書き込んでください。

### Software
main.rbをGR-CITRUSに書き込んでください。
