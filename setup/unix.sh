#!/bin/sh
set -e

cd ..

echo "📦 Instalando dependências essenciais..."

# LuaJIT
haxelib git linc_luajit https://github.com/PsychExtendedThings/linc_luajit --quiet

# JSON
haxelib install tjson --quiet

# Flixel
haxelib install flixel 5.2.2 --quiet
haxelib install flixel-addons 2.11.0 --quiet
haxelib install flixel-ui 2.4.0 --quiet
haxelib install hscript 2.4.0 --quiet

# HXCodec e HXCPP
haxelib git hxCodec https://github.com/PsychExtendedThings/hxCodec-0.6.3 --quiet
haxelib git hxcpp https://github.com/PsychExtendedThings/hxcpp --quiet

# FlxAnimate
haxelib install flxanimate --quiet

# Lime + OpenFL compatíveis com Psych 0.6.3
haxelib git lime https://github.com/PsychExtendedThings/lime-new --quiet
haxelib install openfl 9.2.2 --quiet

# Configuração Android apenas se necessário
if [ "$1" = "Android" ]; then
  echo "📱 Configurando ambiente Android..."
  yes | haxelib run lime setup android
fi

echo "✅ Tudo pronto! Dependências instaladas e ambiente configurado."