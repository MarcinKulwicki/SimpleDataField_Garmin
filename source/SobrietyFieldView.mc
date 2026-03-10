import Toybox.Activity;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class SobrietyFieldView extends WatchUi.SimpleDataField {

    function initialize() {
        SimpleDataField.initialize();
        label = WatchUi.loadResource(Rez.Strings.AppName) as String;
    }

    // compute() jest wywoływany co sekundę podczas aktywności
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        var days = getDaysSober();

        if (days < 0) {
            // Data ustawiona w przyszłości lub niezainicjowana
            return WatchUi.loadResource(Rez.Strings.LabelNotSet) as String;
        }

        var fmt = SobrietyFieldApp.getNumProp("DisplayFormat");
        if (fmt == 1) {
            return days.toString();             // np. "365"
        }
        var label = WatchUi.loadResource(Rez.Strings.LabelDays) as String;
        return days.toString() + " " + label;   // np. "365 days"
    }

    // ----------------------------------------------------------------
    // Oblicza liczbę pełnych dni od daty startu
    // ----------------------------------------------------------------
    private function getDaysSober() as Number {
        var year  = SobrietyFieldApp.getNumProp("SobrietyYear");
        var month = SobrietyFieldApp.getNumProp("SobrietyMonth");
        var day   = SobrietyFieldApp.getNumProp("SobrietyDay");
        var hour  = SobrietyFieldApp.getNumProp("SobrietyHour");

        // Brak daty — niezainicjowane
        if (year == 0 || month == 0 || day == 0) { return -1; }

        // Walidacja
        if (!isValidDate(year, month, day)) { return -1; }

        var startMoment;
        try {
            startMoment = Gregorian.moment({
                :year   => year,
                :month  => month,
                :day    => day,
                :hour   => hour,
                :minute => 0,
                :second => 0
            });
        } catch (e) {
            return -1;
        }

        var now = Time.now();

        // Data w przyszłości
        if (startMoment.greaterThan(now)) { return -1; }

        var diffSeconds = now.subtract(startMoment).value();
        return (diffSeconds / 86400).toNumber();   // 86400 s = 1 dzień
    }

    // ----------------------------------------------------------------
    // Walidacja daty (miesiąc, dzień, rok przestępny)
    // ----------------------------------------------------------------
    private function isValidDate(year as Number, month as Number, day as Number) as Boolean {
        if (month < 1 || month > 12) { return false; }
        if (day   < 1 || day   > 31) { return false; }

        var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        if (month == 2 && isLeapYear(year)) { daysInMonth[1] = 29; }

        return day <= daysInMonth[month - 1];
    }

    private function isLeapYear(year as Number) as Boolean {
        if (year % 4   != 0) { return false; }
        if (year % 100 != 0) { return true;  }
        if (year % 400 != 0) { return false; }
        return true;
    }
}