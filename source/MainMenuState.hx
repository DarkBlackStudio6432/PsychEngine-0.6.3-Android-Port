package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var selected:Bool = false;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	override function create()
	{
		super.create();

		// Fundo
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var item:FlxSprite = new FlxSprite(0, 200 + i * 140);
			item.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			item.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			item.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			item.animation.play('idle');
			item.antialiasing = ClientPrefs.data.antialiasing;
			item.screenCenter(X);
			menuItems.add(item);
		}

		changeItem();

		FlxG.camera.follow(camFollow, null, 9);

		// 🔽 ÚNICA COISA DE MOBILE (como você pediu)
		#if mobile
		if (mobilePad != null)
			mobilePad.visible = true;
		#end
	}

	override function update(elapsed:Float)
	{
		if (!selected)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.ACCEPT)
				selectItem();

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		menuItems.members[curSelected].animation.play('idle');

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var item = menuItems.members[curSelected];
		item.animation.play('selected');
		item.centerOffsets();
		item.screenCenter(X);

		camFollow.setPosition(
			item.getGraphicMidpoint().x,
			item.getGraphicMidpoint().y
		);
	}

	function selectItem()
	{
		selected = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		var item = menuItems.members[curSelected];

		FlxTween.flicker(item, 1, 0.06, false, false, function(_)
		{
			switch (optionShit[curSelected])
			{
				case 'story_mode':
					MusicBeatState.switchState(new StoryMenuState());

				case 'freeplay':
					MusicBeatState.switchState(new FreeplayState());

				case 'credits':
					MusicBeatState.switchState(new CreditsState());

				case 'options':
					MusicBeatState.switchState(new OptionsState());
			}
		});
	}
}