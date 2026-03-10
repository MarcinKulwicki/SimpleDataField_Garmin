import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class SobrietyFieldApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        // Jeśli data nie była ustawiona, ustaw dzisiejszą jako fallback
        var year = getNumProp("SobrietyYear");
        if (year == 0) {
            var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            Application.Properties.setValue("SobrietyYear",  today.year);
            Application.Properties.setValue("SobrietyMonth", today.month);
            Application.Properties.setValue("SobrietyDay",   today.day);
            Application.Properties.setValue("SobrietyHour",  today.hour);
        }
    }

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SobrietyFieldView() ];
    }

    // Pomocnicza — żeby nie duplikować w View
    static function getNumProp(id as String) as Number {
        try {
            var v = Application.Properties.getValue(id);
            if (v != null && v instanceof Number) { return v as Number; }
        } catch (e) {}
        return 0;
    }
}

function getApp() as SobrietyFieldApp {
    return Application.getApp() as SobrietyFieldApp;
}
