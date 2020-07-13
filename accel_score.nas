print("Kwynn.com - accel 2014/10/16 - 6:14pm - v0.10.2");

# only take max Z when WOW == true 2014/10/16

# print("accel 2014/06/11 - 1:13am");

# print("accel 2014/05/30 - 7:54am"); # see 2014/05/30 comment below

# print("accel 2014/04/11 - 11:27pm"); # previous

var verbose = 0;
var verboseT = 0;

var reinitL = nil;
var frameL = nil;
var maxZ = 0;
var frameCount = 0;
var maxZPr = 0;
var actFrame = 0;


var printScore = func(doPrint = 0) {
	if (verbose) print("acc - cancel per frame. doP = " ~ doPrint);

	if (frameL != nil) { removelistener(frameL); frameL = nil; }
	
	if (doPrint) {
		var accF = sprintf("%d",maxZ);
		gui.popupTip(accF, 1.8);
		if (getprop("/sim/replay/replay-state") == 0) {
			print(accF ~ " fps/s");
			if (verboseT) print(getprop("/sim/time/elapsed-sec"));
		}
		maxZPr = maxZ;
	}

	setprop("/sim/kwynn/landed",1);

	maxZ = maxZPr = frameCount = actFrame = 0;

}

var frame_listener_func = func() {

	frameCount += 1;
	
	if (frameCount == 1) {
		maxZ = maxZPr = 0;
		return;
	}
	
	var isMod = (math.mod(frameCount, 8) == 0);
	
	if ((verbose) and (isMod)) print("per mod frame maxZ = " ~ maxZ ~ " fc = " ~ frameCount);


	if ((wowLState) or (wowRState)) { 

		var Z = abs(getprop("/accelerations/pilot/z-accel-fps_sec"));
		if (Z > maxZ) maxZ = Z;
	}
	
	if (!isMod) return;
	
	if (verbose) print("acc - past mod");
	
	if (
			(wowLState == 1) and 
			(wowRState == 1) and
			(Z < 33)	 and
			(
				   (idleState == 1)
				or (getprop("/controls/engines/engine/reverser-act") == 1)
			)			 
	) {
		if (actFrame == 0) actFrame = frameCount;
	}
	else actFrame = 0;

	var frameRate = getprop("/sim/frame-rate");
	if (frameRate == 0) frameRate = 1;


	if (
	      (actFrame > 0) and 
	      ((frameCount - actFrame) / frameRate > 2)
	) {

		if (verbose) print("acc - landing");
		printScore(1);
		return;
	}


	
	var agl = getprop("/position/gear-agl-ft");
	if (agl > 10) { # 2014/05/30 - changed from 5 to 10
		if (verbose) print("canceling from agl > 5.");
		printScore(0);
	}
	
}

var checkPerFrame = func(nodeIN) { 

	if (!nodeIN.getValue()) return;	

	if (verbose) print("acc - per-frame started");
	if (frameL == nil) frameL = setlistener("/sim/signals/frame", frame_listener_func, 0, 1);
}

var initFrameL = nil;
var wowRL = nil;
var wowLL = nil;
var wowLState = 0;
var wowRState = 0;

var wowRLL = func(lval, rval) {
	if (verbose) print("wowRLL");
	if      (lval >= 0) wowLState = lval;
	else if (rval >= 0) wowRState = rval;
}


var doInitFrame = func {
	if (verbose) print("doInitFrame - accel");
	if (wowRL == nil) wowRL = setlistener("/gear/gear[1]/wow", func(nodeIN) { wowRLL(-1, nodeIN.getValue()    ); }, 1, 0);
	if (wowLL == nil) wowLL = setlistener("/gear/gear[2]/wow", func(nodeIN) { wowRLL(    nodeIN.getValue(), -1); }, 1, 0);
}

var crashL = nil;
var idleL  = nil;

var doCrash = func {
	printScore();
}

var idleState = 0;
var doIdle = func(nodeIN) {
	idleState = nodeIN.getValue();
}

var aglKL = nil;

var init = func {

	if (frameL != nil) { removelistener(frameL); frameL = nil; }

	if (initFrameL == nil) initFrameL = setlistener("/sim/kwynn/frame-20", doInitFrame, 0, 0); # Kwynn 2014/04 - several changes
	if (crashL     == nil) crashL     = setlistener("/sim/crashed", doCrash, 1, 0);
	if (idleL      == nil) idleL      = setlistener("autopilot/autobrake/throttles-at-idle", doIdle, 1, 0);
	if (aglKL      == nil) aglKL      = setlistener("/sim/kwynn/agl-5", checkPerFrame, 0, 0);
}

if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", init, 1,1);
