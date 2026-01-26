package;

import states.MusicBeatState;
import backend.ClientPrefs;
import Paths;
import options.OptionsState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import openfl.display.BitmapData;

import StorySubMenu;
import MadnessCredits;

#if desktop
import flixel.input.mouse.FlxMouseEvent;
#end

enum Hovering
{
	OPTIONS;
	ANYTHINGELSE;
}

class MadnessMenu extends MusicBeatState
{
	var hoverMode:Hovering = ANYTHINGELSE;

	#if desktop
	public static var mouseGraphic:BitmapData =
		BitmapData.fromFile('assets/shared/images/madnessmenu/mouse.png');
	#end

	var uniScale:Float = 1;
	var currentSel:Int = 0;

	var baseButtons:FlxTypedGroup<FlxSprite>;
	var optionsButton:FlxSprite;
	var circles:FlxSpriteGroup;
	var storyButton:FlxSprite;
	var storyDropDown:StorySubMenu;

	override function create()
	{
		#if desktop
		FlxG.mouse.visible = true;
		FlxG.mouse.load(mouseGraphic, 0.5);
		#end

		FlxG.camera.antialiasing = ClientPrefs.data.antialiasing;
		persistentUpdate = true;

		var back = new FlxSprite(Paths.image('madnessmenu/back'));
		back.setGraphicSize(FlxG.width);
		back.updateHitbox();
		back.screenCenter(Y);
		back.y += 100;
		add(back);

		uniScale = back.scale.x;

		var silh = new FlxBackdrop(Paths.image('madnessmenu/siloets'), X, 20);
		silh.setScale(uniScale);
		silh.y = 300;
		silh.velocity.x = -50;
		silh.alpha = 0.3;
		add(silh);

		storyDropDown = new StorySubMenu();
		add(storyDropDown);

		baseButtons = new FlxTypedGroup<FlxSprite>();
		add(baseButtons);

		storyButton = makeButton('storymode');
		storyButton.setPosition(1169 * uniScale, 405 * uniScale);
		baseButtons.add(storyButton);

		storyDropDown.setPosition(storyButton.x + 40, storyButton.y - 320);

		var freeplayButton = makeButton('freeplay');
		freeplayButton.setPosition(storyButton.x + storyButton.width + 10, storyButton.y);
		baseButtons.add(freeplayButton);

		optionsButton = makeButton('options');
		optionsButton.setPosition(storyButton.x + storyButton.width + 10, 760 * uniScale);
		add(optionsButton);

		circles = new FlxSpriteGroup();
		add(circles);

		super.create();

		#if mobile
		addVirtualPad(LEFT_RIGHT, A_B);
		#end

		changeSel();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && hoverMode != OPTIONS)
			changeSel(controls.UI_LEFT_P ? -1 : 1);

		if (controls.ACCEPT)
		{
			if (storyDropDown.open)
				storyDropDown.confirm();
			else
				confirmSel();
		}

		if (controls.BACK && storyDropDown.open)
			closeStoryDropdown();

		#if desktop
		for (i in baseButtons)
		{
			var id = baseButtons.members.indexOf(i);
			if (FlxG.mouse.overlaps(i))
			{
				if (currentSel != id && !storyDropDown.open)
					changeSel(id - currentSel);

				if (FlxG.mouse.justPressed)
					confirmSel();
			}
		}

		if (FlxG.mouse.overlaps(optionsButton) && !storyDropDown.open)
		{
			hoverMode = OPTIONS;
			changeSel(0, true);

			if (FlxG.mouse.justPressed)
				confirmSel();
		}
		#end
	}

	function confirmSel()
	{
		FlxG.sound.play(Paths.sound('madness/select'));

		var button = hoverMode == OPTIONS ? optionsButton : baseButtons.members[currentSel];
		button.animation.play('confirm');

		if (hoverMode == OPTIONS)
		{
			MusicBeatState.switchState(new OptionsState());
			OptionsState.onPlayState = false;
		}
		else
		{
			switch (currentSel)
			{
				case 0:
					openStoryDropdown();
				case 1:
					MusicBeatState.switchState(new MadnessCredits());
			}
		}
	}

	function openStoryDropdown()
	{
		storyButton.animation.play('confirm');
		storyDropDown.open = true;

		FlxTween.tween(
			storyDropDown,
			{ y: storyButton.y },
			0.4,
			{ ease: FlxEase.cubeOut }
		);
	}

	function closeStoryDropdown()
	{
		storyButton.animation.play('select');
		FlxTween.tween(
			storyDropDown,
			{ y: storyButton.y - 320 },
			0.4,
			{
				ease: FlxEase.cubeOut,
				onComplete: function(_) {
					storyDropDown.open = false;
				}
			}
		);
	}

	function changeSel(v:Int = 0, forceSound:Bool = false)
	{
		if (!forceSound)
			FlxG.sound.play(Paths.sound('madness/beep'));

		for (i in baseButtons.members.concat([optionsButton]))
			i.animation.play('i');

		currentSel = FlxMath.wrap(currentSel + v, 0, baseButtons.length - 1);

		var obj = hoverMode == OPTIONS ? optionsButton : baseButtons.members[currentSel];
		obj.animation.play('select');
	}

	function makeButton(path:String):FlxSprite
	{
		var spr = new FlxSprite();
		spr.frames = Paths.getSparrowAtlas('madnessmenu/' + path);
		spr.animation.addByPrefix('i', path + '0');
		spr.animation.addByPrefix('confirm', path + ' confirm');
		spr.animation.addByPrefix('select', path + ' select');
		spr.animation.play('i');
		spr.setScale(uniScale + 0.2);
		return spr;
	}
}