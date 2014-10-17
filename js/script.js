/* Author: 

*/

function getDuration(timeMillis){
    var units = [
        {label:"millis",    mod:1000,},
        {label:"seconds",   mod:60,},
        {label:"minutes",   mod:60,},
        {label:"hours",     mod:24,},
        {label:"days",      mod:7,},
        {label:"weeks",     mod:52,},
    ];
    var duration = new Object();
    var x = timeMillis;
    for (i = 0; i < units.length; i++){
        var tmp = x % units[i].mod;
        duration[units[i].label] = tmp;
        x = (x - tmp) / units[i].mod
    }
    return duration;
}
























