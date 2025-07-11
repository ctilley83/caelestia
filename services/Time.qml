pragma Singleton
import Quickshell
import QtQml

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    function formatHourOnly(): string {
        try {
            return clock.date.toLocaleTimeString(Qt.locale("en_US"), "h a")
        } catch (e) {
            console.warn("formatHourOnly failed:", e);
            return "";
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
