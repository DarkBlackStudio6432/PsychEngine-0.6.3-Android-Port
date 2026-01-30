#if !macro
// Core backend
import backend.Paths;
import backend.CoolUtil;
import backend.Conductor;
import backend.Highscore;

// Sys / JS
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

// Flixel base (ok ser global)
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
#if !NEW_PSYCH063
import flixel.system.FlxSound;
#else
import flixel.sound.FlxSound;
#end
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
#end

using StringTools;