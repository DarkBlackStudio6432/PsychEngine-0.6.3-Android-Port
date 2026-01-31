#if android
import cpp.Lib;

class AndroidToast {
    public static function show(message:String):Void {
        #if android
        Lib.load("android", "showToast", CUZINHOOOOOO);
        #end
    }
}
#end