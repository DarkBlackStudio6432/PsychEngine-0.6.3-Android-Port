package;

#if desktop
import Discord.DiscordClient;
#end

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.scrollFactor.set(0, optionShit.length < 6 ? 0 : (optionShit.length - 4) * 0.135);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0,
			"Psych Engine v" + psychEngineVersion, 12);
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT,
			FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);

		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0,
			"Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT,
			FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		changeItem();

		#if TOUCH_CONTROLS
		addMobilePad("UP_DOWN", "A_B_E");
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(
			FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal),
			FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal)
		);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P) changeItem(-1);
			if (controls.UI_DOWN_P) changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (ClientPrefs.data.flashing)
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (spr.ID != curSelected)
						FlxTween.tween(spr, {alpha: 0}, 0.4);
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(_)
						{
							switch (optionShit[curSelected])
							{
								case 'story_mode': MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay': MusicBeatState.switchState(new FreeplayState());
								case 'mods': MusicBeatState.switchState(new ModsMenuState());
								case 'awards': MusicBeatState.switchState(new AchievementsMenuState());
								case 'credits': MusicBeatState.switchState(new CreditsState());
								case 'options': MusicBeatState.switchState(new options.OptionsState());
							}
						});
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr) spr.screenCenter(X));
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;
		if (curSelected >= menuItems.length) curSelected = 0;
		if (curSelected < 0) curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr)
		{
			spr.animation.play(spr.ID == curSelected ? 'selected' : 'idle');
			if (spr.ID == curSelected)
			{
				var add = menuItems.length > 4 ? menuItems.length * 8 : 0;
				camFollow.setPosition(
					spr.getGraphicMidpoint().x,
					spr.getGraphicMidpoint().y - add
				);
				spr.centerOffsets();
			}
		});
	}
}