print("Kwynn.com - check - 2014/04/11 1");

var verbose = 0;

var mainCheck = func() {

	if (verbose) print("check check - bf getValue");

	if (size(arg) > 0) {
		if (!arg[0].getValue()) return;
		
	}

	if (getprop("/sim/kwynn/agl-5")) return;

	var agl   = getprop("/position/gear-agl-ft");
	
	if (agl <= 5) {
		setprop("/sim/kwynn/agl-5", 1);
		return;
	}
	
	var inverval = 0.1;
	
	if      (agl <  100) interval = 0.02  * agl;
	else if (agl <  500) interval = 0.005 * agl + 2;
	else if (agl < 1000) interval = 0.006 * agl + 2;
	else 				 interval = 8;
	
	settimer(mainCheck, interval);
}

var wowDo = func(nodeIN) {
	if (
				(nodeIN.getValue() == 0)
			and (getprop("/sim/kwynn/agl-5") == 0)
	) mainCheck();
}

var wowLL = nil;

var landDo = func(nodeIN) { 
	if (nodeIN.getValue() == 1) setprop("/sim/kwynn/agl-5", 0);
}

var frame20do = func(nodeIN) {
	if (nodeIN.getValue() == 0) return;
	if (getprop("/position/gear-agl-ft") > 1) mainCheck();
}

var kUpL = nil;
var aglL = nil;
var reinitL = nil;



var doReinit = func { 
	setprop("/sim/kwynn/landed",0);
	setprop("/sim/kwynn/agl-5",0);
	
	if (kUpL       == nil) kUpL       = setlistener("/sim/kwynn/frame-20", frame20do, 0, 0);
	if (aglL       == nil) aglL       = setlistener("/sim/kwynn/landed"  , landDo, 0, 0);
	if (wowLL == nil) wowLL = setlistener("/gear/gear[2]/wow", wowDo, 0, 0);
}
if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", doReinit, 1, 0);
