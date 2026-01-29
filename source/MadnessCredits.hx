package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

import MusicBeatState;
import CoolUtil;

import Character;
import AttachedSprite;
import mobile.objects.MobileControls;

@:structInit
class Credit {
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
		{name:'yabo',quote:'i really rwally like gruntfriend',role:'charter, artist',link:'https://x.com/yaboigp'},
		{name:'data5',quote:'well',role:'coder',link:'https://x.com/_data5'},
		{name:'smokey5',quote:'fuck data fuuuuuck help me think of a quote',role:'coder',link:'https://x.com/Smokey_5_'},
		{name:'jayythunder',quote:'NOTHING BUT BANGERS, AND I KNOW BANGERS',role:'chromatic',link:'https://x.com/ThunderJayy'},
		{name:'laeko',quote:'I love my ladies like burgers',role:'artist',link:'https://x.com/LaekoGah'},
		{name:'infry',quote:'my belly is so big and round',role:'saved the god damned mod',link:'https://x.com/Infry20'},
		{name:'mr krinkles',quote:'thank u for making madness combat',role:'made madness combat',link:'https://x.com/MRKrinkels'}
	];

	var displayedQuote:FlxText;
	var displayedRole:FlxText;

	var arrow:AttachedSprite;
	var glow:AttachedSprite;

	var everyoneButInfry:Character;
	var character:FlxSprite;

	var mobileControls:MobileControls;

	override function create()
	{
		super.create();

		// 📱 escala automática
		var scale:Float = FlxG.width / 1280;

		creditText = new FlxTypedGroup<FlxText>();
		add(creditText);

		for (i in 0...credits.length)
		{
			var t = new FlxText(20, i * Std.int(80 * scale), 0, credits[i].name.toUpperCase(), Std.int(60 * scale));
			t.font = Paths.font('impact.ttf');
			t.color = FlxColor.RED;
			creditText.add(t);
		}

		displayedRole = new FlxText(0, FlxG.height - Std.int(180 * scale), FlxG.width, '', Std.int(50 * scale));
		displayedRole.alignment = CENTER;
		displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
		add(displayedRole);

		displayedQuote = new FlxText(0, FlxG.height - Std.int(120 * scale), FlxG.width, '', Std.int(32 * scale));
		displayedQuote.alignment = CENTER;
		displayedQuote.font = Paths.font('impact.ttf');
		displayedQuote.color = FlxColor.RED;
		add(displayedQuote);

		everyoneButInfry = new Character(Std.int(750 * scale), Std.int(180 * scale), 'creditChar');
		add(everyoneButInfry);

		character = new FlxSprite();
		character.frames = Paths.getSparrowAtlas('madnessmenu/credits/infry');
		character.animation.addByPrefix('infry', 'infry', 24, true);
		add(character);
		character.visible = false;

		// 🎮 VirtualPad
		mobileControls = new MobileControls();
		add(mobileControls);

		changeSel();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mobileControls.justPressed.UP)
			changeSel(-1);

		if (mobileControls.justPressed.DOWN)
			changeSel(1);

		if (mobileControls.justPressed.BACK)
			MusicBeatState.switchState(new MadnessMenu());

		if (mobileControls.justPressed.ACCEPT)
			CoolUtil.browserLoad(credits[curSel].link);
	}

	function changeSel(add:Int = 0)
	{
		curSel = FlxMath.wrap(curSel + add, 0, credits.length - 1);

		displayedRole.text = credits[curSel].role.toUpperCase();
		displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';

		for (i in 0...creditText.length)
		{
			var t = creditText.members[i];
			t.alpha = (i == curSel) ? 1 : 0.4;
		}

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
			everyoneButInfry.playAnim(credits[curSel].name + FlxG.random.int(1, 4), true);
		}
	}
}