print("Kwynn.com script - v0.9.1 - AT - 2014/02/15 2:20am");

var verbose = 0;

var at_disarm_below = 400;  

var reinitL = nil;
var atL 	= nil;

var at_listener_func = func {

	if (verbose) print("AT - at_listener_func");

	var ati = getprop("/instrumentation/afds/inputs/autothrottle-index");
	var agl = getprop("/position/gear-agl-ft");

	if (
			(ati == 0) and 
			(agl < at_disarm_below)         # to be consistent with the intent of this before my change to the at files discussed on my site
	)
	{
		if (verbose) print("disarming A/T L/R switches");
	
		setprop("/instrumentation/afds/inputs/at-armed"   ,0); 
		setprop("/instrumentation/afds/inputs/at-armed[1]",0);
		if (atL != nil) removelistener(atL);
		atL = nil;
	}
	else if (ati == 2) # sometimes THR REF "magically" comes on.  If so, set back to SPD
		setprop("/instrumentation/afds/inputs/autothrottle-index",5);
}

var reinit_listener_func = func(from) { 

	if (verbose) print("AT - reinit_listener_func");

	frameCount = 0;
	
	if (atL         == nil) atL       = setlistener("/instrumentation/afds/inputs/autothrottle-index", at_listener_func   , 1, 1);
}

if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", reinit_listener_func, 1,1);
