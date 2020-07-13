print("brake - 2014/02/03 2:49am");

var verbose = 0;

var displayTime = 0.3;
var timerTime   = 0.23; # less than but high % of above - 90% does not work, 66% does

if (verbose) print("dT / tT " ~ displayTime ~ " " ~ timerTime);

var maxHeat   = 0;
var maxHeatPr = 0;

var dCnt = 0;
var ttNode = nil;

var hide = func(nodeIN) {
	fgcommand("update-hover", nodeIN);
}

var display = func {
	if (verbose) { dCnt += 1; print("brake - display " ~ dCnt);	}
	
	var heat = getprop("/gear/brake-thermal-energy");
	if (heat > maxHeat) maxHeat = heat;
	
	var heatF = sprintf("%0.2f%%",heat * 100);
	var maxD  = sprintf("%d",maxHeat * 100);
  # var maxF  = sprintf("%0.2f%%",maxHeat * 100);
	
	if ((heat < maxHeat) and  (abs(heat - maxHeat) > 0.005)) popS = heatF ~ " / " ~ maxD;
	else popS = heatF;
	
	var sema = getprop("/sim/gui/popupTip/semaphores/runway-clear");
	if ((sema == nil) or (sema == 0)) {
	
	    # me.setInt("y", getprop('/sim/startup/ysize') * 0.2);
		# var screenW = getprop('/sim/startup/xsize');
		# me.setInt("x", (screenW - me._width) * 0.5);
		
		var ttNode = props.Node.new({ "tooltip-id" : "kwynn1", "x": 500, "y": 500, "label" : popS, "measure-text" : "999", "reason" : "click", "delay" : 0.3 , });
		fgcommand("set-tooltip", ttNode);
		fgcommand("tooltip-timeout", ttNode );
		settimer(func { hide(ttNode) }, 0.3);
		
		
		# gui.popupTip(popS, displayTime);
	}
	
	if ((getprop("/velocities/groundspeed-kt") < 0.1) and (maxHeat > maxHeatPr)) 
	{
		print(maxD ~ "%");
		maxHeatPr = maxHeat;
	}
}

var pL = 0;
var pR = 0;
var pT = 0;
var pP = 0;
var dON = 0;

var goD = func {
	if (!dON) return;
	display();
	settimer(goD, timerTime);
}

var dOFF = func { dON = 0; }

var actD = func { 
	if (dON) return;
	dON = 1;
	goD();
}

var doBoth = func(LIN, RIN) {
	if      (LIN >= 0) pL = LIN;
	else if (RIN >= 0) pR = RIN;
	
	pT = pL + pR;
	if ((pT <= pP) and (pT < 1)) dOFF();
	else actD();
	pP = pT;
}

var reset = func { maxHeat = maxHeatPr = timerSet = 0; }

var gear_listener = func {
	if (verbose) print("brake - gear");
	if (getprop("/gear/gear/wow") == 0) reset();
}

var LL = nil;
var RL = nil;
var gearL = nil;

var reinit_listener_func = func {
	if (verbose) print("brake - reinit - 8:17");

	reset();
	
	if (RL    == nil) RL    = setlistener("/controls/gear/brake-right", func(nodeIN) { doBoth(-1, nodeIN.getValue()   ); });
	if (LL    == nil) LL    = setlistener("/controls/gear/brake-left" , func(nodeIN) { doBoth(    nodeIN.getValue(), -1); });
	if (gearL == nil) gearL = setlistener("/gear/gear/wow", gear_listener, 0, 0);
}

var reinitL = nil;
if (reinitL == nil) reinitL = setlistener("/sim/signals/reinit", reinit_listener_func, 1,1);
