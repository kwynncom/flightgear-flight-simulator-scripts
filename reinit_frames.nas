print("Kwynn.com - reinit_frames.nas - 2014/05/11 2");

# 2014/05/23 - no changes; reversed them

# moved init-frame-count to only agl > 1
# removed 35 and 50 frames
# then put back - landing gear doesn't seem to work without this?
# 6000 feet condition

# previous print("Kwynn.com - reinit_frames.nas - 2014/04/10 1");

# 04/10 - removing frame 50 signal
# 2014/04/06 - creating a frame 50 signal

# previous
# print("Kwynn.com - reinit_frames.nas - 2014/02/15 2:27am");

var verbose = 0;

var frameA = [1, 2, 3, 4, 5, 6, 20, 35, 50];
var maxFrameI = size(frameA);
var frameAI = 0;
var maxFrame = frameA[-1];

var reinitL = nil;
var frameL = nil;

var cancelDoFrame = func {
	if (frameL != nil) {
		removelistener(frameL);
		setprop("/sim/kwynn/init-frame-state",0);
	}
	frameL = nil;
}

var setprop_once = func(name, setTo) {
	var val = getprop(name);
	if ((val == nil) or (val <= 0)) setprop(name, setTo);
	

}

var frameCnt = 0;

var doFrame = func {
	frameCnt += 1;
	
	setprop("/instrumentation/afds/inputs/AP"   ,0); 
	
	if (frameAI >= maxFrameI) {
		cancelDoFrame();
		return;
	}
	
	if (frameA[frameAI] == frameCnt) {

		# ********* if (frameCnt >= 50)	setprop_once("/sim/kwynn/frame-50/", frameCnt);
		if (frameCnt >= 20)	{
			if (verbose) print("calling frame-20 from reinit-frames");
			setprop_once("/sim/kwynn/frame-20/", frameCnt);
		}
		if (frameCnt >=  6) {
			var agl = getprop("/position/gear-agl-ft");
			if ((agl > 1) and (agl < 6000)) {
				if (verbose) print("up-init set to 1");
				setprop("/sim/kwynn/init-frame-count/", frameCnt);	
				if (verbose) print("reinit_frames - agl = " ~ agl ~ " frameCnt = " ~ frameCnt);
				setprop_once("/sim/kwynn/up-init", 1);
			}
			if (agl >= 6000)  {
				setprop("/sim/kwynn/cruise-init", frameCnt);				
			}
			
		}
		
		frameAI += 1;
		if (frameAI >= maxFrameI) cancelDoFrame;
		return;
	}
	
	if (frameCnt > maxFrame) cancelDoFrame();
}



var doReinit = func { 
	frameCnt = frameAI = 0;
	setprop("/sim/kwynn/frame-20",0);
	setprop("/sim/kwynn/up-init",0);
	if (frameL == nil) frameL = setlistener("/sim/signals/frame", doFrame, 1, 1); 
}

if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", doReinit, 1, 0);
