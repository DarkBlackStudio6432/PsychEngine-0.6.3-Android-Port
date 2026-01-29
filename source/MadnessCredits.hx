package;

import MusicBeatState;
import CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

import Character;
import AttachedSprite;

#if mobile
import mobile.objects.MobileControls;
#end

@:structInit class Credit {
	public var name:String = '';
	public var quote:String = '';
	public var role:String = '';
	public var link:String = '';
}

class MadnessCredits extends MusicBeatState
{
	var curSel:Int = 0;

	var creditText:FlxTypedGroup<FlxText>;
	var credits:Array<Credit> = [
		{name:'grave',quote:'this mod is a disease',role:'director, artist',link:'https://x.com/konn_artist'},
		{name:'vamazotz',quote:'i fucking love hank j wimbleton',role:'co-director, artist',link:'https://x.com/vamazotz'},
		{name:'jads',quote:'get a bunch of bikes, and ride em around with your friends',role:'composer',link:'https://x.com/Aw3somejds'},
		{name:'cval',quote:'well hello everyone',role:'charter, composer',link:'https://x.com/cval_brown'},
		{name:'punkett',quote:'made everything',role:'composer',link:'https://x.com/_punkett'},
		{name:'marstarbro',quote:"They just threw me in a group chat and 3 hours later, here's a pause theme",role:'composer',link:'https://x.com/MarstarMain'},
		{name:'river',quote:'hold the crust',role:'composer',link:'https://x.com/rivermusic_'},
		{name:'shayreyez',quote:'i need to plap thick booba mmm futa porn',role:'artist',link:'https://x.com/ShayReyZed'},
		{name:'yabo',quote:'i really really like gruntfriend',role:'charter, artist',link:'https://x.com/yaboigp'},
		{name:'data5',quote:'well',role:'coder',link:'https://x.com/_data5'},
		{name:'smokey5',quote:'fuck data fuuuuuuuuuuuuuuuuuuuck help me think of a quote',role:'coder',link:'https://x.com/Smokey_5_'},
		{name:'jayythunder',quote:'NOTHING BUT BANGERS, AND I KNOW BANGERS',role:'chromatic',link:'https://x.com/ThunderJayy'},
		{name:'laeko',quote:'I love my ladies like I looove burgers!',role:'artist',link:'https://x.com/LaekoGah'},
		{name:'infry',quote:'my belly is so big and round',role:'saved the god damned mod',link:'https://x.com/Infry20'},
		{name:'mr krinkles',quote:'thank u for making madness combat',role:'made madness combat',link:'https://x.com/MRKrinkels'}
	];

	var displayedQuote:FlxText;
	var displayedRole:FlxText;

	var rim:FlxSprite;
	var arrow:AttachedSprite;
	var glow:AttachedSprite;

	var everyoneButInfry:Character;
	var character:FlxSprite;

	var scrollLerp:Float = 0;
	var holdTime:Float = 0;
	var _prevAnim:Int = 0;

	#if mobile
	var mobileControls:MobileControls;
	#end

	override function create()
	{
		persistentUpdate = true;
		super.create();

		// === PC SCALE ===
		FlxG.camera.zoom = FlxG.width / 1280;

		glow = new AttachedSprite('madnessmenu/credits/glows');
		glow.alpha = 0.7;
		add(glow);

		creditText = new FlxTypedGroup<FlxText>();
		add(creditText);

		arrow = new AttachedSprite('madnessmenu/credits/arrow');
		add(arrow);

		for (k in 0...credits.length)
		{
			var txt = new FlxText(20, 0, 0, credits[k].name.toUpperCase(), 61);
			txt.y = (txt.height + 25) * k;
			txt.font = Paths.font('impact.ttf');
			txt.color = FlxColor.RED;
			creditText.add(txt);
		}

		rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
		rim.scale.set(1.1, 1.1);
		rim.updateHitbox();
		add(rim);

		everyoneButInfry = new Character(650, 140, 'creditChar');
		add(everyoneButInfry);

		character = new FlxSprite();
		character.frames = Paths.getSparrowAtlas('madnessmenu/credits/infry');
		character.animation.addByPrefix('infry', 'infry', 24, false);
		add(character);

		displayedRole = new FlxText(
			0,
			0,
			Std.int(FlxG.width - 25),
			'',
			60
		);
		displayedRole.alignment = RIGHT;
		displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
		displayedRole.scrollFactor.set();
		displayedRole.y = 20;
		add(displayedRole);

		displayedQuote = new FlxText(0, 0, 0, '', 40);
		displayedQuote.font = Paths.font('impact.ttf');
		displayedQuote.color = FlxColor.RED;
		displayedQuote.scrollFactor.set();
		add(displayedQuote);

		#if mobile
		mobileControls = new MobileControls();
		add(mobileControls);
		#end

		changeSel();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// === PC INPUT ===
		if (controls.UI_UP_P) changeSel(-1);
		if (controls.UI_DOWN_P) changeSel(1);
		if (controls.ACCEPT) CoolUtil.browserLoad(credits[curSel].link);
		if (controls.BACK) MusicBeatState.switchState(new MadnessMenu());

		// === MOBILE INPUT ===
		#if mobile
		if (mobileControls.current.buttonUp.justPressed) changeSel(-1);
if (mobileControls.current.buttonDown.justPressed) changeSel(1);

if (mobileControls.current.buttonExtra1.justPressed)
    CoolUtil.browserLoad(credits[curSel].link);

if (mobileControls.current.buttonExtra2.justPressed)
    MusicBeatState.switchState(new MadnessMenu());
		#end

		FlxG.camera.scroll.y = FlxMath.lerp(
			FlxG.camera.scroll.y,
			scrollLerp,
			0.25 * 60 * elapsed
		);

		for (i in 0...creditText.length)
		{
			var txt = creditText.members[i];
			var targetX = (i == curSel) ? 150 : 20;
			txt.x = FlxMath.lerp(txt.x, targetX, 0.3 * 60 * elapsed);

			var a = Math.abs(
				FlxMath.remapToRange(Math.abs(i - curSel), 4, 0, 0, 1)
			);
			txt.alpha = FlxMath.lerp(txt.alpha, a, 0.3 * 60 * elapsed);
		}
	}

	function changeSel(v:Int = 0)
	{
		if (v != 0) FlxG.sound.play(Paths.sound('madness/beep'));

		curSel = FlxMath.wrap(curSel + v, 0, credits.length - 1);
		var curText = creditText.members[curSel];

		displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
		displayedRole.text = credits[curSel].role.toUpperCase();

		scrollLerp = (curText.y + curText.height / 2) - FlxG.height / 2;

		displayedQuote.x = rim.x + (rim.width - displayedQuote.width) / 2;
		displayedQuote.y = rim.y + rim.height + 10;

		arrow.sprTracker = curText;
		arrow.xAdd = curText.width + 10;

		glow.sprTracker = curText;
		glow.setGraphicSize(
			Std.int(curText.width + 25),
			Std.int(curText.height)
		);
		glow.updateHitbox();

		if (credits[curSel].name == 'infry')
		{
			character.visible = true;
			everyoneButInfry.visible = false;
			character.animation.play('infry', true);
		}
		else
		{
			character.visible = false;
			everyoneButInfry.visible = true;
			var dance = FlxG.random.int(1, 4, [_prevAnim]);
			everyoneButInfry.playAnim(credits[curSel].name + dance, true);
			_prevAnim = dance;
		}
	}
}