print("Kwynn.com script running - ground - v0.9.7+ - 2014/05/11");

# moving visibility to common

# 2014/04/05 - if agl shows we're not on the ground, don't do these settings
# search "Kwynn" for changes

# previous version:
# print("Kwynn.com script running - ground - v0.9.5 - 2014/03/12 7:23pm");
# removing some of the previous comments

var verbose = 0;

var visibility = 300000; # meters

var reinitL = nil;

var round = func(inputF) { 
	inputI = int(inputF);
	inputD = inputF - inputI;
	if (inputD >= 0.5) return inputI + 1;
	else return inputI;
}

var setHeadingBug = func {
	var heading = getprop("/orientation/heading-magnetic-deg"); # 2014/03/12
	if (verbose) print("heading " ~ heading);
	setprop("/autopilot/settings/heading-bug-deg",round(heading));
}

var setAfterDelay2 = func {

	if (verbose) print("ground - delay2");
	
	setprop("/controls/flight/flaps",0.666);
	setprop("/sim/flaps/current-setting",4);
}

var apDialog = func {
	setprop("/sim/gui/dialogs/autopilot/dialog/x",430); # originally 442, changed 2014/07/06
	setprop("/sim/gui/dialogs/autopilot/dialog/y", 18);	
	fgcommand("dialog-show", props.Node.new({ "dialog-name" : "autopilot-dlg", x : 411, y : 19 }));
}

var setOnceUponReInit = func {

	if (verbose) print("ground - set once upon reinit");
	
	apDialog();
	
	setprop("/sim/gui/dialogs/autopilot/dialog/x",411);	
	setprop("/sim/gui/dialogs/autopilot/dialog/y", 19);	
	setprop("/consumables/fuel/tank/level-gal_us"   , 9538.689); # 9538.689 = full
	setprop("/consumables/fuel/tank[1]/level-gal_us",19433.300); # 2014/07/06
	setprop("/consumables/fuel/tank[2]/level-gal_us", 9538.689);
	setprop("/instrumentation/afds/inputs/bank-limit-switch",1);
	setprop("/controls/electric/battery-switch",1);
	setprop("/controls/engines/engine/cutoff",0);
	setprop("/controls/engines/engine[1]/cutoff",0);
	setprop("/engines/engine/run",1);
	setprop("/engines/engine[1]/run",1);
	setprop("/controls/flight/flaps",0.666);
	setprop("/controls/gear/brake-parking",0);
	setprop("/autopilot/settings/counter-set-altitude-ft",34000);
	setprop("/autopilot/settings/vertical-speed-fpm",2300); # 2014/07/06
	setprop("/instrumentation/afds/inputs/lateral-index",2);
	setprop("/instrumentation/afds/inputs/vertical-index",0); 
	setprop("/autopilot/settings/target-speed-kt", 195);  # 2014/07/06
	setprop("/instrumentation/afds/inputs/at-armed"   ,1); 
	setprop("/instrumentation/afds/inputs/at-armed[1]",1);
	# setprop("/environment/visibility-m", visibility);
	# setprop("/environment/metar/max-visibility-m", visibility);
	# setprop("/environment/metar/min-visibility-m", visibility - 1);	
	setHeadingBug(); # 2014/03/12
	setprop("/controls/engines/engine/throttle"   , 0);
	setprop("/controls/engines/engine[1]/throttle", 0);
	setprop("/sim/hud/visibility[1]",1); # added 2014/07/06
	
	settimer(setAfterDelay2, 2);
}

var checkStatus = func(nodeIN) {

	if (nodeIN.getValue() == 0) return;
	
	var agl = getprop("/position/gear-agl-ft");

	if (verbose) print("ground - check status.  agl = " ~ agl);

	if (agl < 1) setOnceUponReInit();
}

var initFrameL = nil;

var reinit_listener_func = func() { 

	if (getprop("/position/gear-agl-ft") > 20) return; # 2014/04/05 Kwynn

	if (verbose) print("ground - reinit_listener_func");

	if (initFrameL == nil) initFrameL = setlistener("/sim/kwynn/frame-20", checkStatus, 0, 0);
	
	# 2014/04/05 Kwynn -commenting out 2 lines
	# setprop("/controls/flight/flaps",1);
	# setprop("/sim/flaps/current-setting",6);
	
	
#	settimer(checkStatus, 2);
}

if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", reinit_listener_func, 1,1);

# KSFO 28L - ready for takeoff
# -122.358845
#   37.611917
#   298
#   -1.56 ft
#   0 airspeed
