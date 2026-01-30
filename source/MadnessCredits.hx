package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.ui.FlxVirtualPad;

import MusicBeatState;
import CoolUtil;
import Character;
import AttachedSprite;

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

    var creditText:FlxGroup;  
    var credits:Array<Credit> = [
        {name:'grave',quote:'this mod is a disease',role:'director, artist',link:'https://x.com/konn_artist'},
        {name:'vamazotz',quote:'i fuckingf love hank j wimbleton',role:'co-director, artist',link:'https://x.com/vamazotz'},
        {name:'jads',quote:'get a bunch of bikes, and ride em around with your friends',role:'composer',link:'https://x.com/Aw3somejds'},
        {name:'cval',quote:'well hello everyone',role:'charter, composer',link:'https://x.com/cval_brown'},
        {name:'punkett',quote:'made everything',role:'composer',link:'https://x.com/_punkett'},
        {name:'marstarbro',quote:"They just threw me in a group chat and 3 hours later, here's a pause theme",role:'composer',link:'https://x.com/MarstarMain'},
        {name:'river',quote:'hold the crust',role:'composer',link:'https://x.com/rivermusic_'},
        {name:'shayreyez',quote:'i need to plap thick booba mmm futa porn',role:'artist',link:'https://x.com/ShayReyZed'},
        {name:'yabo',quote:'i really rwally like gruntfriend',role:'charter, artist',link:'https://x.com/yaboigp'},
        {name:'data5',quote:'well',role:'coder',link:'https://x.com/_data5'},
        {name:'smokey5',quote:'fuck data fuuuuuuuuuuuuuuuuuuuck help me think of a quote',role:'coder',link:'https://x.com/Smokey_5_'},
        {name:'jayythunder',quote:'NOTHING BUT BANGERS, AND I KNOW BANGERS',role:'chromatic',link:'https://x.com/ThunderJayy'},
        {name:'laeko',quote:'I love my ladies like I looove burgers!',role:'artist',link:'https://x.com/LaekoGah'},
        {name:'infry',quote:'my belly is so big and round',role:'saved the god damned mod',link:'https://x.com/Infry20'},
        {name:'mr krinkles',quote:'thank u for making amdness combat',role:'made madness combat',link:'https://x.com/MRKrinkels'}
    ];  

    var displayedQuote:FlxText;  
    var displayedRole:FlxText;  

    var rim:FlxSprite;  
    var arrow:AttachedSprite;  
    var glow:AttachedSprite;  

    var everyoneButInfry:Character;  
    var character:FlxSprite;  

    var holdTime:Float = 0;  
    var scrollLerp:Float = 0;  
    var _prevAnim:Int = 0;  

    #if mobile  
    var virtualPad:FlxVirtualPad;  
    #end  

    override function create()  
    {  
        persistentUpdate = true;  
        super.create();  

        glow = new AttachedSprite('madnessmenu/credits/glows');  
        glow.alpha = 0.7;  
        add(glow);  

        creditText = new FlxGroup();  
        add(creditText);  

        arrow = new AttachedSprite('madnessmenu/credits/arrow');  
        add(arrow);  

        for (i in 0...credits.length)  
        {  
            var t = new FlxText(20, 0, 0, credits[i].name.toUpperCase(), 61);  
            t.y = (t.height + 25) * i;  
            t.font = Paths.font('impact.ttf');  
            t.color = FlxColor.RED;  
            creditText.add(t);  
        }  

        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));  
        rim.scale.set(1.1, 1.1);  
        rim.updateHitbox();  
        rim.scrollFactor.set();  
        add(rim);  

        everyoneButInfry = new Character(650, 140, 'creditChar');  
        everyoneButInfry.scrollFactor.set();  
        add(everyoneButInfry);  

        character = new FlxSprite();  
        character.frames = Paths.getSparrowAtlas('madnessmenu/credits/infry');  
        character.animation.addByPrefix('infry', 'infry', 24, false);  
        character.scrollFactor.set();  
        add(character);  

        displayedRole = new FlxText(0, 0, FlxG.width - 25, '', 60);  
        displayedRole.alignment = RIGHT;  
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');  
        displayedRole.scale.y = 1.5;  
        displayedRole.scrollFactor.set();  
        add(displayedRole);  

        displayedQuote = new FlxText(0, 0, 0, '', 40);  
        displayedQuote.font = Paths.font('impact.ttf');  
        displayedQuote.color = FlxColor.RED;  
        displayedQuote.scrollFactor.set();  
        add(displayedQuote);  

        #if mobile  
        virtualPad = new FlxVirtualPad();  
        virtualPad.alpha = 0.9;  
        virtualPad.scrollFactor.set();  

        virtualPad.x = FlxG.width - virtualPad.width - 20;  
        virtualPad.y = FlxG.height - virtualPad.height - 20;  

        add(virtualPad);  

        // Escala todos os botões do virtualPad
        for (b in virtualPad.buttons) {
            b.scale.set(1.5, 1.5);
            b.updateHitbox();
        }
        #end  

        changeSel();  
    }  

    override function update(elapsed:Float)  
    {  
        super.update(elapsed);  

        var up:Bool = controls.UI_UP_P;  
        var down:Bool = controls.UI_DOWN_P;  

        #if mobile  
        if (virtualPad != null) {
            for (b in virtualPad.buttons) {
                switch (b.name) {
                    case "up": if (b.justPressed) up = true;
                    case "down": if (b.justPressed) down = true;
                    default: // ignorar
                }
            }
        }
        #end  

        if (up || down || FlxG.mouse.wheel != 0)  
        {  
            holdTime = 0;  
            changeSel(FlxG.mouse.wheel != 0 ? -FlxG.mouse.wheel : (down ? 1 : -1));  
        }  

        if (controls.BACK)  
            MusicBeatState.switchState(new MadnessMenu());  

        #if mobile  
        if (FlxG.mouse.justPressed)  
        {  
            var p = FlxG.mouse.getWorldPosition();  
            var curText:FlxText = cast creditText.members[curSel];  

            if (curText != null && curText.overlapsPoint(p))  
                CoolUtil.browserLoad(credits[curSel].link);  
        }  
        #else  
        if (controls.ACCEPT || FlxG.mouse.justPressed)  
        {  
            CoolUtil.browserLoad(credits[curSel].link);  
        }  
        #end  

        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, scrollLerp, 0.4 * 60 * elapsed);  

        for (i in 0...creditText.members.length)  
        {  
            var t:FlxText = cast creditText.members[i];  
            var targetX = (i == curSel) ? 150 : 20;  

            t.x = FlxMath.lerp(t.x, targetX, 0.4 * 60 * elapsed);  
            t.alpha = FlxMath.lerp(  
                t.alpha,  
                Math.abs(FlxMath.remapToRange(Math.abs(i - curSel), 4, 0, 0, 1)),  
                0.4 * 60 * elapsed  
            );  
        }  
    }  

    function changeSel(s:Int = 0)  
    {  
        if (s != 0)  
            FlxG.sound.play(Paths.sound('madness/beep'));  

        curSel = FlxMath.wrap(curSel + s, 0, credits.length - 1);  

        var curText:FlxText = cast creditText.members[curSel];  

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';  
        displayedRole.text = credits[curSel].role.toUpperCase();  
        scrollLerp = (curText.y + curText.height / 2) - (FlxG.height / 2);  

        displayedQuote.x = rim.x + (rim.width - displayedQuote.width) / 2;  

        arrow.sprTracker = curText;  
        arrow.yAdd = (curText.height - arrow.height) / 2;  
        arrow.xAdd = curText.width + 10;  

        glow.sprTracker = curText;  
        glow.setGraphicSize(Std.int(curText.width + 25), Std.int(curText.height));  
        glow.updateHitbox();  
        glow.yAdd = (curText.height - glow.height) / 2;  
        glow.xAdd = (curText.width - glow.width) / 2;  

        if (credits[curSel].name == 'infry')  
        {  
            character.visible = true;  
            everyoneButInfry.visible = false;  
            character.animation.play('infry', true);  
            character.x = rim.x + (rim.width - character.width) / 2 - 100;  
            character.y = rim.y - character.height + rim.height / 2 + 35;  
        }  
        else  
        {  
            character.visible = false;  
            everyoneButInfry.visible = true;  
            var dance:Int = FlxG.random.int(1, 4, [_prevAnim]);  
            everyoneButInfry.playAnim(credits[curSel].name + dance, true);  
            _prevAnim = dance;  
        }  
    }
}