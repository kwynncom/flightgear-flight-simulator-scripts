print("Kwynn.com script running - air - v0.9.2 - 2014/05/11");
# moving visibility to common

var verbose = 0; 

var visibility = 300000; # meters
var glide_slope_tunnel_on = 0;
var at_target_speed_kt = 140;


var reinitL = nil;

var setOnceOnReInit = func {
	
	if (verbose) print("agl init - set once");
	
	setprop("/controls/flight/flaps",1); # full flaps - 30 degrees
	setprop("/sim/flaps/current-setting",6);

	
	setprop("/consumables/fuel/tank/level-gal_us"   , 1600);
	setprop("/consumables/fuel/tank[1]/level-gal_us",    0);
	setprop("/consumables/fuel/tank[2]/level-gal_us", 1600);
	
	

	setprop("/sim/sound/enabled",0);
	# setprop("/environment/visibility-m", visibility);
	# setprop("/environment/metar/max-visibility-m", visibility);
	# setprop("/environment/metar/min-visibility-m", visibility - 1);	
	setprop("/sim/hud/visibility[1]",1);
    setprop("/controls/flight/speedbrake-lever",1); # auto
	setprop("/instrumentation/afds/inputs/AP-disengage",1);
	setprop("/instrumentation/afds/inputs/FD",0); # flight director
	setprop("/autopilot/autobrake/step",-1);  # -1 = off; 1 = step 1
	setprop("/instrumentation/efis/mfd/display-mode","MAP"); # APP / approach - yes you need both APP and 0
	setprop("/instrumentation/efis/mfd/mode-num",2); # APP / approach - yes, both # APP = 0; MAP = 2

}

var setPerFrame = func  { 
	
	if (verbose) print("setPerFrame");
	
	setprop("/instrumentation/afds/inputs/AP-disengage",1);
	setprop("/sim/rendering/glide-slope-tunnel", glide_slope_tunnel_on);
	setprop("/sim/fuel-fraction",0.065); # 19.7 X 1000 lbs - ready for landing
	setprop("/controls/gear/gear-down", 1);
	var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
	var vref = ias + getprop("/instrumentation/pfd/vref-diff");
	at_target_speed_kt = int(vref) + 6;
	setprop("/autopilot/settings/target-speed-kt", at_target_speed_kt);
	setprop("/instrumentation/afds/inputs/lateral-index",0);   # LOC (flight director indication only); 4 - LOC
	setprop("/instrumentation/afds/inputs/vertical-index",0);  # G/S (flight director ...); 6 - G/S
	setprop("/instrumentation/afds/inputs/at-armed"   ,1); 
	setprop("/instrumentation/afds/inputs/at-armed[1]",1);
	setprop("/instrumentation/afds/inputs/autothrottle-index",5); # 5 = SPD # for version 2.12.1
	setprop("/controls/gear/tiller-enabled", 0); # not sure whether once or per frame; this suddenly started turning on, for no apparent reason
}

var setAGL = 0;
var setOnce = 0;

var doK = func {

	if (verbose) print("agl - doK 1");
	if (setOnce) setPerFrame();
}

var doFinal = func(node) { 
	if (verbose) print("doFinal");

	if (node.getValue() == 0) setprop("/sim/sound/enabled",1);
}

var doUp = func(node) {
	if (node.getValue() != 1) return;
	
	setOnceOnReInit();
	setOnce = 1;
}

var kFrameL = nil;
var kUpL = nil;
var kFrameDoneL = nil;

var reinit_listener_func = func { 
	setAGL = 0;
	setOnce = 0;

	setprop("/controls/flight/flaps",1); # full flaps - 30 degrees
	setprop("/sim/flaps/current-setting",6);
	
	if (kFrameL     == nil) kFrameL     = setlistener("/sim/kwynn/init-frame-count", doK , 0, 0);
	if (kUpL        == nil) kUpL        = setlistener("/sim/kwynn/up-init"              , doUp, 0, 0);
	if (kFrameDoneL == nil) kFrameDoneL = setlistener("/sim/kwynn/init-frame-state", doFinal, 1, 1);
}

if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", reinit_listener_func, 1, 0);

# KSFO 28L
# -122.34608
#   37.60653
#        320 atl
#        298 head
#  		 143 airspeed
