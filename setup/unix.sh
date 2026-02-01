#!/bin/sh
set -e

cd ..

echo "💾 Configurando Haxelib..."
# Cria pasta de cache separada para evitar conflitos
mkdir -p ~/haxelib_cache
haxelib setup ~/haxelib_cache

echo "📦 Instalando dependências essenciais..."
haxelib git linc_luajit https://github.com/PsychExtendedThings/linc_luajit --quiet
haxelib install tjson --quiet
haxelib install flixel 5.2.2 --quiet
haxelib install flixel-addons 2.11.0 --quiet
haxelib install flixel-ui 2.4.0 --quiet
haxelib install hscript 2.4.0 --quiet
haxelib git hxCodec https://github.com/PsychExtendedThings/hxCodec-0.6.3 --quiet
haxelib git hxcpp https://github.com/PsychExtendedThings/hxcpp --quiet
haxelib install flxanimate --quiet
haxelib git lime https://github.com/PsychExtendedThings/lime-new --quiet
haxelib install openfl 9.2.2 --quiet

# Configura Android somente se for build Android
if [ "$1" = "Android" ]; then
  echo "📱 Configurando Android SDK/NDK..."
  yes | haxelib run lime setup android
fi

echo "✅ Dependências instaladas e ambiente pronto!"