pragma Singleton

import "root:/config"
import "root:/utils"
import Quickshell
import QtQuick

Singleton {
    id: root

    property string loc
    property string icon
    property string city
    property string description
    property real temperature

    function reload(): void {
        if (Config.dashboard.weatherLocation)
            loc = Config.dashboard.weatherLocation;
        else if (!loc || timer.elapsed() > 900)
            Requests.get("https://ipinfo.io/json", text => {
                loc = JSON.parse(text).loc ?? "";
                timer.restart();
            });
    }

    onLocChanged: Requests.get(`https://wttr.in/${loc}?format=j1`, text => {
        const jsonWeatherData = JSON.parse(text).current_condition[0];
        const jsonNearestArea = JSON.parse(text).nearest_area[0];
        icon = Icons.getWeatherIcon(jsonWeatherData.weatherCode);
        description = jsonWeatherData.weatherDesc[0].value;
        temperature = parseFloat(jsonWeatherData.temp_F);
        city = jsonNearestArea.areaName[0].value;
        console.log(city)
    })

    Component.onCompleted: reload()

    ElapsedTimer {
        id: timer
    }
}
