#!/bin/sh
set -e

cd ..

echo Making the main haxelib and setuping folder..
haxelib setup ~/haxelib

echo Installing dependencies...
echo This might take a few moments depending on your internet speed.

haxelib git linc_luajit https://github.com/PsychExtendedThings/linc_luajit --quiet
haxelib install tjson --quiet

haxelib install flixel 5.2.2 --quiet
haxelib install flixel-addons 2.11.0 --quiet
haxelib install flixel-ui 2.4.0 --quiet
haxelib install hscript 2.4.0 --quiet

haxelib git hxCodec https://github.com/PsychExtendedThings/hxCodec-0.6.3 --quiet
haxelib git hxcpp https://github.com/PsychExtendedThings/hxcpp --quiet

haxelib install flxanimate --quiet

haxelib install lime 7.9.0 --quiet
haxelib install openfl 9.2.2 --quiet

# 🔥 ESSENCIAL PARA ANDROID
haxelib git extension-androidtools https://github.com/MAJigsaw77/extension-androidtools --quiet

yes | haxelib run lime setup android

echo Finished!