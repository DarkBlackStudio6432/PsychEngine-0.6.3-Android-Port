#if android
import cpp.Lib;

class AndroidToast {
    public static function show(message:String):Void {
        #if android
        Lib.load("android", "showToast", message);
        #end
    }
}
#end