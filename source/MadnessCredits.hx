package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

import MusicBeatState;
import CoolUtil;
import Character;
import AttachedSprite;

#if mobile
import mobile.objects.MobileControls;
#end

class MadnessCredits extends MusicBeatState
{
    var creditNames:Array<String> = [
        "Tricky Team",
        "Animator",
        "Coder",
        "Composer"
    ];

    var creditRoles:Array<String> = [
        "Original Creators",
        "Animations",
        "Programming",
        "Music"
    ];

    var creditQuotes:Array<String> = [
        "WELCOME TO MADNESS",
        "PURE CHAOS",
        "HARD AS HELL",
        "TURN UP THE VOLUME"
    ];

    var curSelected:Int = 0;

    var creditTexts:FlxGroup;
    var displayedRole:FlxText;
    var displayedQuote:FlxText;

    var rim:FlxSprite;
    var character:Character;

    #if mobile
    var controls:MobileControls;
    #end

    override function create()
    {
        super.create();

        // Fundo
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(bg);

        // Rim (moldura central)
        rim = new FlxSprite(FlxG.width / 2 - 350, 80);
        rim.makeGraphic(700, 350, FlxColor.TRANSPARENT);
        rim.scrollFactor.set();
        add(rim);

        // Personagem
        character = new Character(0, 0, 'tricky');
        add(character);

        character.x = rim.x + (rim.width / 2) - (character.width / 2) - 100;
        character.y = rim.y + rim.height - character.height + 35;

        // Lista de créditos
        creditTexts = new FlxGroup();
        add(creditTexts);

        for (i in 0...creditNames.length)
        {
            var txt = new FlxText(0, 0, 0, creditNames[i], 32);
            txt.font = Paths.font("impact.ttf");
            txt.color = FlxColor.WHITE;
            txt.y = 200 + (txt.height + 25) * i;
            txt.x = 20;
            txt.scrollFactor.set();
            txt.updateHitbox();
            creditTexts.add(txt);
        }

        // Cargo (topo direito)
        displayedRole = new FlxText(0, 0, FlxG.width - 25, "", 60);
        displayedRole.font = Paths.font("BebasNeue-Regular.ttf");
        displayedRole.alignment = RIGHT;
        displayedRole.scale.y = 1.5;
        displayedRole.scrollFactor.set();
        displayedRole.updateHitbox();
        add(displayedRole);

        displayedRole.y = rim.y - displayedRole.height - 5;

        // Frase (abaixo do rim)
        displayedQuote = new FlxText(0, 0, FlxG.width, "", 40);
        displayedQuote.font = Paths.font("impact.ttf");
        displayedQuote.alignment = CENTER;
        displayedQuote.color = FlxColor.RED;
        displayedQuote.scrollFactor.set();
        displayedQuote.updateHitbox();
        add(displayedQuote);

        displayedQuote.y = rim.y + rim.height + 5;

        #if mobile
        controls = new MobileControls();
        add(controls);
        #end

        changeSelection(0);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var up = FlxG.keys.justPressed.UP;
        var down = FlxG.keys.justPressed.DOWN;
        var accept = FlxG.keys.justPressed.ENTER;

        #if mobile
        up = up || controls.UP;
        down = down || controls.DOWN;
        accept = accept || controls.ACCEPT;
        #end

        if (up) changeSelection(-1);
        if (down) changeSelection(1);

        if (accept)
            FlxG.switchState(new MainMenuState());
    }

    function changeSelection(change:Int)
    {
        curSelected += change;

        if (curSelected < 0)
            curSelected = creditNames.length - 1;
        if (curSelected >= creditNames.length)
            curSelected = 0;

        var i = 0;
        for (text in creditTexts.members)
        {
            if (text == null) continue;

            var targetX = (i == curSelected) ? 150 : 20;
            text.x = FlxMath.lerp(text.x, targetX, 0.4);
            text.alpha = (i == curSelected) ? 1 : 0.6;

            i++;
        }

        displayedRole.text = creditRoles[curSelected];
        displayedQuote.text = creditQuotes[curSelected];
    }
}