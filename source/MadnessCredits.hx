package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

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
        {name: 'grave',quote: 'this mod is a disease',role: 'director, artist',link: 'https://x.com/konn_artist'},
        {name: 'vamazotz',quote: 'i fuckingf love hank j wimbleton',role: 'co-director, artist',link: 'https://x.com/vamazotz'},
        {name: 'jads',quote: 'get a bunch of bikes, and ride em around with your friends',role: 'composer',link: 'https://x.com/Aw3somejds'},
        {name: 'cval',quote: 'well hello everyone',role: 'charter, composer',link: 'https://x.com/cval_brown'},
        {name: 'punkett',quote: 'made everything',role: 'composer',link: 'https://x.com/_punkett'},
        {name: 'marstarbro',quote: "They just threw me in a group chat and 3 hours later, here's a pause theme",role: 'composer',link: 'https://x.com/MarstarMain'},
        {name: 'river',quote: 'hold the crust',role: 'composer',link: 'https://x.com/rivermusic_'},
        {name: 'shayreyez',quote: 'i need to plap thick booba mmm futa porn',role: 'artist',link: 'https://x.com/ShayReyZed'},
        {name: 'yabo',quote: 'i really rwally like gruntfriend',role: 'charter, artist',link: 'https://x.com/yaboigp'},
        {name: 'data5',quote: 'well',role: 'coder',link: 'https://x.com/_data5'},
        {name: 'smokey5',quote: 'fuck data fuuuuuuuuuuuuuuuuuuuck help me think of a quote',role: 'coder',link: 'https://x.com/Smokey_5_'},
        {name: 'jayythunder',quote: 'NOTHING BUT BANGERS, AND I KNOW BANGERS',role: 'chromatic',link: 'https://x.com/ThunderJayy'},
        {name: 'laeko',quote: 'I love my ladies like I looove burgers! Ahaha i just lov burgre ahahahahahahaha Ok wait where are u guys going',role: 'artist',link: 'https://x.com/LaekoGah'},
        {name: 'infry',quote: 'my belly is so big and round, also credit to suitman he wanted credit for genuinely nothign',role: 'saved the god damned mod',link: 'https://x.com/Infry20'},
        {name: 'mr krinkles',quote: 'thank u for making amdness combat',role: 'made madness combat',link: 'https://x.com/MRKrinkels'},
    ];

    var displayedQuote:FlxText;
    var displayedRole:FlxText;

    var rim:FlxSprite;
    var arrow:FlxSprite;
    var glow:FlxSprite;

    var everyoneButInfry:FlxSprite;
    var character:FlxSprite;

    var holdTime:Float = 0;
    var scrollLerp:Float = 0;

    var lastTouchY:Float = 0;

    override function create() {
        persistentUpdate = true;
        super.create();

        FlxG.camera.scroll.set(0,0);

        glow = new FlxSprite('madnessmenu/credits/glows');
        glow.alpha = 0.7;
        glow.scrollFactor.set();
        add(glow);

        creditText = new FlxTypedGroup<FlxText>();
        add(creditText);

        arrow = new FlxSprite('madnessmenu/credits/arrow');
        arrow.scrollFactor.set();
        add(arrow);

        for (k in 0...credits.length) {
            var text = new FlxText(20, 0, 0, credits[k].name.toUpperCase(), 61);
            text.y = (text.height + 25) * k;
            text.font = Paths.font('impact.ttf');
            text.color = 0xFF0000; // vermelho
            creditText.add(text);
        }

        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1,1.1);
        rim.updateHitbox();
        rim.scrollFactor.set();
        add(rim);

        everyoneButInfry = new FlxSprite(Paths.image('madnessmenu/credits/creditChar'));
        everyoneButInfry.scrollFactor.set();
        add(everyoneButInfry);

        character = new FlxSprite();
        character.frames = Paths.getSparrowAtlas('madnessmenu/credits/infry');
        character.animation.addByPrefix('infry','infry',24,false);
        character.scrollFactor.set();
        add(character);

        var spotlight = new FlxSprite(FlxG.width - rim.width - 25, Paths.image('madnessmenu/credits/light'));
        spotlight.scale.copyFrom(rim.scale);
        spotlight.updateHitbox();
        spotlight.scrollFactor.set();
        add(spotlight);

        rim.y = spotlight.y + spotlight.height + 10;
        rim.x = spotlight.x + (spotlight.width - rim.width)/2;

        displayedRole = new FlxText(0,0,FlxG.width - 25,'',60);
        displayedRole.alignment = "right";
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.scale.y = 1.5;
        displayedRole.updateHitbox();
        displayedRole.scrollFactor.set();
        add(displayedRole);

        displayedQuote = new FlxText(0, Std.int(rim.y + rim.height), 0, '', 40);
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = 0xFF0000;
        displayedQuote.scrollFactor.set();
        add(displayedQuote);

        changeSel();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // 📌 Scroll por teclado ou mouse
        if (controls.UI_DOWN_P || controls.UI_UP_P || FlxG.mouse.wheel != 0) {
            holdTime = 0;
            changeSel(FlxG.mouse.wheel == 0 ? (controls.UI_DOWN_P ? 1 : -1) : -FlxG.mouse.wheel);
        }

        // 📌 Botão back do celular
        if (controls.BACK) MusicBeatState.switchState(new MadnessMenu());

        // 📌 Abrir link
        if (controls.ACCEPT || FlxG.mouse.justPressed) CoolUtil.browserLoad(credits[curSel].link);

        // 📌 Scroll por tecla segurada
        if(controls.UI_DOWN || controls.UI_UP) {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                changeSel((checkNewHold - checkLastHold) * (controls.UI_UP ? -1 : 1));
        }

        // 📌 Scroll por touch
        #if mobile
        if (FlxG.mouse.pressed) {
            if (lastTouchY != 0) {
                var diff = lastTouchY - FlxG.mouse.screenY;
                if (Math.abs(diff) > 5) changeSel(diff > 0 ? 1 : -1);
            }
            lastTouchY = FlxG.mouse.screenY;
        } else lastTouchY = 0;
        #end

        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, scrollLerp, 0.4 * 60 * elapsed);

        for (k in 0...creditText.length) {
            var i = creditText.members[k];
            if (i == null) continue;

            var pos = k == curSel ? 150 : 20;
            i.x = FlxMath.lerp(i.x,pos,0.4 * 60 * elapsed);

            var alpha = Math.abs(FlxMath.remapToRange(Math.abs(k - curSel),4,0,0,1));
            i.alpha = FlxMath.lerp(i.alpha, alpha,0.4 * 60 * elapsed);
        }
    }

    function changeSel(s:Int = 0) {
        if (s != 0) FlxG.sound.play(Paths.sound('madness/beep'));

        curSel = FlxMath.wrap(curSel + s,0,credits.length-1);

        var curText = creditText.members[curSel];

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        scrollLerp = (curText.y + (curText.height/2)) - (FlxG.height/2);

        displayedQuote.x = rim.x + (rim.width - displayedQuote.width)/2;

        arrow.x = curText.x + curText.width + 10;
        arrow.y = curText.y + (curText.height - arrow.height)/2;

        glow.x = curText.x + (curText.width - glow.width)/2;
        glow.y = curText.y + (curText.height - glow.height)/2;
        glow.setGraphicSize(curText.width + 25, curText.height);

        if (credits[curSel].name == 'infry') {
            character.visible = true;
            everyoneButInfry.visible = false;

            character.animation.play('infry',true);
            character.x = rim.x + (rim.width - character.width)/2 - 100;
            character.y = rim.y - character.height + rim.height/2 + 35;

        } else {
            character.visible = false;
            everyoneButInfry.visible = true;

            var danceNum = FlxG.random.int(1,4,[_prevAnim]);
            everyoneButInfry.frame = 0; // fallback visual
            _prevAnim = danceNum;
        }
    }

    var _prevAnim:Int = 0;
}