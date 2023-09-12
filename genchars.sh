#!/bin/bash

gen_chars(){
    echo -n "$2" | iconv -f utf-8 -t utf-16le | cat <(echo -ne "\xff\xfe") - > "$1"
}

# a.chars.txt: only "a"
gen_chars a.chars.txt "a"

# ascii.chars.txt: all ASCII
ASCIIs="$(seq 32 126 | xargs printf '\\\\x%x' | xargs printf %b)"
gen_chars ascii.chars.txt "$ASCIIs"

# es1.chars.txt: ASCII, hiragana and ES1 grade kanji
# https://www.mext.go.jp/a_menu/shotou/new-cs/youryou/syo/koku/001.htm
ES1=$(cat << EOS | tr -d '\n'
$ASCIIs
ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとど
なにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをん
一右雨円王音下火花貝学気九休玉金空月犬見五口校左三山子四糸字耳七車手十出女小上森
人水正生青夕石赤千川先早草足村大男竹中虫町天田土二日入年白八百文木本名目立力林六
EOS
)
gen_chars es1.chars.txt "$ES1"

echo checking required apps and files...
! which fc-query \
    && echo need fc-query, run: sudo apt install fontconfig \
    && exit 1

! which bsdtar \
    && echo need bsdtar, run: sudo apt install libarchive-tools \
    && exit 1

! which iconv \
    && echo need iconv, run: sudo apt install libc-bin \
    && exit 1

! test -e CreateDXFontData.exe \
    && echo CreateDXFontData.exe not found, download it from https://dxlib.xsrv.jp/dxdload.html \
    && exit 1

! test -e jfdotfont-20150527.7z \
    && echo jfdotfont-20150527.7z not found, download it from http://jikasei.me/font/jf-dotfont/ \
    && exit 1

echo extracting archive...
#bsdtar xvf jfdotfont-20150527.7z JF-Dot-Shinonome14.ttf
bsdtar xvf jfdotfont-20150527.7z JF-Dot-Shinonome*[^B].ttf


#for f in *.ttf ; do echo $f... ; fc-query $f -f "%{charset}\n" | tr ' ' '\n' \
#    | sed -r -e 's/(.*)-(.*)/{$((0x\1))..$((0x\2))}/' -e 's/^([0-9a-f]+)$/$((0x\1))/g' \
#    | eval echo $(cat) | eval echo $(cat) | tr ' ' '\n' \
#    | xargs -n1 printf '\\\\u%x\n' | tr -d '\n' | eval printf $(cat) \
#    | iconv -t utf16le | cat <(echo -en '\xff\xfe') - > ${f%%.ttf}.chars.txt
#done
#
## ...yes, all chars.txt will be same hash.
#for f in *.chars.txt ; do 
#    sha256sum -c <(echo 49497740c80abc61ac24a1c7147bfc915d2b98ee036e381048f668f8588c8fc5 $f)
#done


echo get ttf included characters...
fc-query JF-Dot-Shinonome14.ttf -f "%{charset}\n" | tr ' ' '\n' \
    | sed -r -e 's/(.*)-(.*)/{$((0x\1))..$((0x\2))}/' -e 's/^([0-9a-f]+)$/$((0x\1))/g' \
    | eval echo $(cat) | eval echo $(cat) | tr ' ' '\n' \
    | xargs -n1 printf '\\\\u%x\n' | tr -d '\n' | eval printf $(cat) \
    | iconv -t utf16le | cat <(echo -en '\xff\xfe') - > JF-Dot-Shinonome.chars.txt

echo generating sandbox required files...
mkdir dir
cp ./*.chars.txt ./*.ttf CreateDXFontData.exe dir
rm ./*.ttf

cat << 'EOF' > ./genchars_sandbox.wsb
<Configuration>
 <MappedFolders>
  <MappedFolder>
   <HostFolder>dir</HostFolder>
   <SandboxFolder>C:\dir</SandboxFolder>
   <ReadOnly>false</ReadOnly>
  </MappedFolder>
 </MappedFolders>
 <LogonCommand>
  <Command>C:\dir\guest_wrap.bat</Command>
 </LogonCommand>
</Configuration>
EOF

echo 'start "" C:\dir\guest.bat' > dir/guest_wrap.bat

cat << 'EOF' > dir/guest.bat 
cd C:\dir
copy *.ttf C:\Windows\Fonts
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "g12 (TrueType)" /t REG_SZ /d JF-Dot-Shinonome12.ttf /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "g14 (TrueType)" /t REG_SZ /d JF-Dot-Shinonome14.ttf /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "g16 (TrueType)" /t REG_SZ /d JF-Dot-Shinonome16.ttf /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "mar (TrueType)" /t REG_SZ /d JF-Dot-ShinonomeMaru12.ttf /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "m12 (TrueType)" /t REG_SZ /d JF-Dot-ShinonomeMin12.ttf /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "m14 (TrueType)" /t REG_SZ /d JF-Dot-ShinonomeMin14.ttf /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "m16 (TrueType)" /t REG_SZ /d JF-Dot-ShinonomeMin16.ttf /f
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 12" /S12 /OJF-Dot-Shinonome12.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /OJF-Dot-Shinonome14.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 16" /S16 /OJF-Dot-Shinonome16.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Marumoji 12" /S12 /OJF-Dot-ShinonomeMaru12.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Mincho 12" /S12 /OJF-Dot-ShinonomeMin12.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Mincho 14" /S14 /OJF-Dot-ShinonomeMin14.dft
CreateDXFontData.exe /AJF-Dot-Shinonome.chars.txt /B1 /T1 /F"JF Dot Shinonome Mincho 16" /S16 /OJF-Dot-ShinonomeMin16.dft
CreateDXFontData.exe /Aa.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /Oa.dft
CreateDXFontData.exe /Aascii.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /Oascii.dft
CreateDXFontData.exe /Aes1.chars.txt /B1 /T1 /F"JF Dot Shinonome Gothic 14" /S14 /Oes1.dft
shutdown -s -t 60
explorer.exe C:\dir
EOF

echo starting sandbox...
WindowsSandbox.exe "$(wslpath -m ./genchars_sandbox.wsb)"
rm genchars_sandbox.wsb

mv dir/*.dft .
rm -rf dir
