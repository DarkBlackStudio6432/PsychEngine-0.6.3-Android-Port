package;

import MusicBeatState;
import StoryMenuState;
import CreditsState;
import OptionsState;
import ClientPrefs;
import Paths;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

class MadnessMenu extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;

	var options:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	override public function create()
	{
		super.create();

		// Background
		var bg:FlxBackdrop = new FlxBackdrop(
			Paths.image('madnessmenu/bg'),
			FlxAxes.X,
			20
		);
		bg.antialiasing = ClientPrefs.antialiasing;
		add(bg);

		// Menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...options.length)
		{
			var item:FlxSprite = new FlxSprite(0, 200 + (i * 120));
			item.loadGraphic(Paths.image('madnessmenu/' + options[i]));
			item.antialiasing = ClientPrefs.antialiasing;
			item.scale.set(0.9, 0.9);
			item.updateHitbox();
			item.screenCenter(X);

			menuItems.add(item);
		}

		changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);

		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT)
			selectItem();
	}

	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (i in 0...menuItems.length)
		{
			var item = menuItems.members[i];
			if (item == null) continue;

			if (i == curSelected)
			{
				FlxTween.tween(item.scale, { x: 1.1, y: 1.1 }, 0.15, {
					ease: FlxEase.quadOut
				});
			}
			else
			{
				FlxTween.tween(item.scale, { x: 0.9, y: 0.9 }, 0.15, {
					ease: FlxEase.quadOut
				});
			}

			item.updateHitbox();
			item.screenCenter(X);
		}
	}

	function selectItem()
	{
		switch (options[curSelected])
		{
			case 'story_mode':
				FlxG.switchState(new StoryMenuState());

			case 'freeplay':
				FlxG.switchState(new FreeplayState());

			case 'credits':
				FlxG.switchState(new CreditsState());

			case 'options':
				FlxG.switchState(new OptionsState());
		}
	}
}