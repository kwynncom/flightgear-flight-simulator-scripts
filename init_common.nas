var verbose = 0;

print("Kwynn - init-common.nas - 2014/05/30"); # turn off 2 views
# print("Kwynn - init-common.nas - 2014/05/23"); # nav changes
# print("Kwynn - init-common.nas - 2014/05/11 -  - 10s"); # previous

var visibility = 300000; # meters

var kInitL = nil;

var keyL = nil;

var keyF = func(event) {

	if (verbose) print("keyF 1");
	if (!event.getNode("pressed").getValue()) return;
	if (verbose) print("keyF 2");
	var keyC = event.getNode("key");
	var key  = chr(keyC.getValue());
	if (key == 'n') swapNav();
}

var doInit = func {

	if (verbose) print("common init running");

	# setprop("/instrumentation/afds/inputs/AP-disengage",1);
	setprop("/instrumentation/afds/inputs/AP"   ,0); 
	
	setprop("/sim/weight/weight-lb",500); # crew; 500 = max
	setprop("/sim/weight[1]/weight-lb", 64000); # passengers and baggage; 131000 = max # changed 2014/07/06
	
	setprop("/environment/visibility-m", visibility);
	setprop("/environment/metar/max-visibility-m", visibility);
	setprop("/environment/metar/min-visibility-m", visibility - 1);	
	
	setprop("sim/gui/dialogs/metar/mode/manual-weather", 1);
	# "clear" ; /environment/clouds/layer0 .. 4/coverage
	for (var i=0; i <= 4; i += 1) {
		setprop("/environment/metar/clouds/layer["       ~ i ~ "]/coverage-type",5); # 5 = clear
		
		# setprop("/environment/clouds/layer["       ~ i ~ "]/coverage-type",5); # 5 = clear
		# setprop("/environment/clouds/layer["       ~ i ~ "]/coverage","clear");
		setprop("/environment/config/aloft/entry[" ~ i ~ "]/visibility-m", 300000);
	}

	if (keyL == nil) keyL = setlistener("/devices/status/keyboard/event", keyF, 0, 1);

	setprop("/sim/view[100]/enabled", 0); # co-pilot
	setprop("/sim/view[101]/enabled", 0); # .../radio/... panel
}

if (kInitL == nil) kInitL = setlistener("/sim/signals/reinit", doInit, 1, 0);

var swapNav = func {
	if (verbose) print("swapNav");

	var selS   = "/instrumentation/nav/frequencies/selected-mhz";
	var standS = "/instrumentation/nav/frequencies/standby-mhz";
	var workF  = num(getprop(selS))        ;
	var standF = num(getprop(standS))      ;
	setprop(selS, standF - 50);
	setprop(standS, workF + 50);
}


var frameInitL = nil;
if (frameInitL == nil) frameInitL = setlistener("/sim/kwynn/frame-20", swapNav, 1, 0);
