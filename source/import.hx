import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

import backend.Paths;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Highscore;

#if mobile
import mobile.objects.MobilePad;
import mobile.backend.StorageUtil;
import mobile.backend.PsychJNI;
#end