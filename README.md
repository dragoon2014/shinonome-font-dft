# 東雲フォントdft

## 概要
東雲フォント(をttf変換したJFドット東雲フォント群)をDXライブラリで使用可能な
dftフォントファイルに変換したものです。
ライセンスはdft・txtともすべてパブリックドメインです。

shinonome font family
http://openlab.ring.gr.jp/efont/shinonome/

自家製ドットフォントシリーズ | 自家製フォント工房
http://jikasei.me/font/jf-dotfont/

## 内容物

- JF-Dot-Shinonome12.dft
- JF-Dot-Shinonome14.dft
- JF-Dot-Shinonome16.dft
- JF-Dot-ShinonomeMaru12.dft
- JF-Dot-ShinonomeMin12.dft
- JF-Dot-ShinonomeMin14.dft
- JF-Dot-ShinonomeMin16.dft

各東雲フォントの変換生成物です。

- JF-Dot-Shinonome.chars.txt

東雲フォントが持っている全文字ファイルです。
以下の感じで出せます。
7フォントとも同じ出力だったので束ねています。
Windowsで良しなに出す方法がわからなかったのでLinuxで（WSLで行けるかも？）

```
for f in *.ttf ; do fc-query $f -f "%{charset}\n" | tr ' ' '\n' \
    | sed -r -e 's/(.*)-(.*)/{$((0x\1))..$((0x\2))}/' -e 's/^([0-9a-f]+)$/$((0x\1))/g' \
    | eval echo $(cat) | eval echo $(cat) | tr ' ' '\n' \
    | xargs -n1 printf '\\\\u%x\n' | tr -d '\n' | eval printf $(cat) \
    | iconv -t utf16le | cat <(echo -en '\xff\xfe') - > ${f%%.ttf}.chars.txt ; done
```

文字ファイルとttfをWindowsに持っていき、ttfをWindowsにインストールしたうえで
DXライブラリ付属のCreateDXFontData.exeを以下のように実行すると各dtfが生成できます。

```
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 12" /S12 /OJF-Dot-Shinonome12.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /OJF-Dot-Shinonome14.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 16" /S16 /OJF-Dot-Shinonome16.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Marumoji 12" /S12 /OJF-Dot-ShinonomeMaru12.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Mincho 12" /S12 /OJF-Dot-ShinonomeMin12.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Mincho 14" /S14 /OJF-Dot-ShinonomeMin14.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Mincho 16" /S16 /OJF-Dot-ShinonomeMin16.dft
```

他、おまけとして実験用のサブセット（すべてJF Dot Shinonome Gothic 14）を含んでいます。

- a.dft|txt

文字「a」のみ

- ascii.dft|txt

ASCIIのみ

- es1.dft|txt

ASCII、ひらがな、小学一年生で習う漢字のみ

```
CreateDXFontData.exe /Aa.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /Oa.dft
CreateDXFontData.exe /Aascii.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /Oascii.dft
CreateDXFontData.exe /Aes1.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /Oes1.dft
```
