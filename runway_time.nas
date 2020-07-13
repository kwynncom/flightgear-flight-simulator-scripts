# 201/04/06 - removed double "s" as in seconds
# 2014/04/05
# UTC and elapsed session time are close enough--removing UTC
# sometimes they are 2s off

print("runway time - 2014/04/06 8:06pm");

var verbose = 0;

var gearL = nil;

var reinitL = nil;
var lat1 = -1;
var lon1 = -1;
var lat2 = -1;
var lon2 = -1;

var startS = -1;

var degRR = -1;

var clockL = nil;
var wowL = nil;

var m = 0;
var b = 0;
var msq = 0;

var setLongLat2 = func {

	if (verbose) print("set2");

	lat2  = getprop("/position/latitude-deg" );
	lon2  = getprop("/position/longitude-deg");
	degRR = getprop("/instrumentation/magnetic-compass/indicated-heading-deg");
	
	lond = lon2 - lon1;
	if (lond == 0) lond = 0.0000001;
		
	m = (lat2 - lat1) / (lond); # slope of line
	b = (lat2 - m * lon2); # y-intercept
	msq = m * m;
}

var wowLF = func(wowIN) {
	if (
			(wowIN.getValue() != 1)
		or	(lat2 > -1)
		) return;
	
	if (verbose) print("set lat / lon 1");
	
	lat1 = getprop("/position/latitude-deg");
	lon1 = getprop("/position/longitude-deg");
	
	settimer(setLongLat2, 0.5);
}


var degdiff = func(deg1, deg2) {
	diff = deg1 - deg2;
	if ( diff < -180.0 )   { diff += 360.0; } 
	elsif ( diff > 180.0 ) { diff -= 180.0; }

	return abs(diff);
	
}

var haversine = func(lat1, lat2, lon1, lon2) {

	var torad = math.pi / 180;

	lat1 = lat1 * torad;
	lat2 = lat2 * torad;
	lon1 = lon1 * torad;
	lon2 = lon2 * torad;

	if (verbose >= 3) print("params haver = " ~ lat1 ~ " " ~ lon1 ~ " " ~ lat2 ~ " " ~ lon2);

	var ERAD = 6378138.12;        # Earth radius (m)

	var a = math.sin((lat1 - lat2) * 0.5);
	var o = math.sin((lon1 - lon2) * 0.5);
	return 2.0 * ERAD * math.asin(math.sqrt(a * a + math.cos(lat1)
			* math.cos(lat2) * o * o));
}

var clearSemaphore = func { setprop("/sim/gui/popupTip/semaphores/runway-clear", 0);	}

var rrTime = -1;

var checkClear = func {
	var latc = getprop("/position/latitude-deg"); # c = current
	var lonc = getprop("/position/longitude-deg");
	
	# now find closest point on runway
	
	# lon = x; lat = y
	var x0 = (m   * latc +     lonc -     m * b) / (msq + 1); # closest point on rr, x coordinate
	var y0 = (msq * latc + m * lonc         + b) / (msq + 1);
	
	var distm = haversine(latc, y0, lonc, x0);

	if (distm > 100) {
		
		var now = getprop("/sim/time/elapsed-sec");
		rrTime    = int(now - startS);
		var rrTimeS = rrTime ~ "s";
		
		if (getprop("/sim/replay/replay-state") == 0) print(rrTimeS); # Kwynn 2014/04/06
	
		var displayFor = 4;
		setprop("/sim/gui/popupTip/semaphores/runway-clear", 1);
		gui.popupTip("runway cleared in " ~ rrTimeS, displayFor);
		settimer(clearSemaphore,displayFor);
	}
}

# secsIN
var clock_tick = func {

	if (rrTime > 0) return;
	# if (getprop("/sim/replay/replay-state") == 1) return;

	vrefd = getprop("/instrumentation/pfd/vref-diff");
	
	if (verbose >= 1) print("tick.  vrefdiff = " ~ vrefd);

	if (vrefd < 5) lat1 = lon1 = startS = -1;
	else {
	
		if (startS < 0) {
			if (verbose) print("set startS");

			
			startS = getprop("/sim/time/elapsed-sec");
			if (verbose) print("startS = " ~ startS);
			
			if (wowL == nil) wowL = setlistener("/gear/gear/wow",wowLF,0,0);
		}
		
		if (
				(lat2 > -1) and 
				(degdiff(getprop("/instrumentation/magnetic-compass/indicated-heading-deg"), degRR) > 10)
			)
			checkClear();

	}
	
	if (clockL) settimer(clock_tick, 1);
}

var gear_listener_func = func(gear) {

	if (verbose >= 1) print("gear val = " ~ gear.getValue());
	

	if (gear.getValue() == 1) { 
		clockL = 1;
		settimer(clock_tick,1);
	}
	else {
		if (verbose) print("remove clockL");
		# if (clockL != nil) 	removelistener(clockL);
		clockL = nil;
		lat1 = lat2 = startS = rrTime = -1;
	}
}


var doInitFrame = func {
	lat1 = lat2 = startS = rrTime = -1;	
	if (gearL == nil) gearL = setlistener("/controls/gear/gear-down", gear_listener_func,1,0);
	
}

var f20L = nil;

var reinit_listener_func = func {
	initFrameCnt = 0;
	if (f20L == nil) f20L = setlistener("/sim/kwynn/frame-20", doInitFrame, 0, 1);
}

if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", reinit_listener_func, 0,0);
