package;

import backend.Paths;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Highscore;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor; // 🔹 Import necessário para FlxColor

// Mobile Controls
#if mobile
import mobile.controls.MobileControls as Controls;
#else
import backend.Controls;
#end