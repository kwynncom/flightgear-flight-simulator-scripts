var cruiseL = nil;

var apDialog = func {
	setprop("/sim/gui/dialogs/autopilot/dialog/x",442);	
	setprop("/sim/gui/dialogs/autopilot/dialog/y", 18);	
	fgcommand("dialog-show", props.Node.new({ "dialog-name" : "autopilot-dlg", x : 411, y : 19 }));
}



var doCruise = func(nodeIN) {
	
	apDialog();
	
	# setprop("/instrumentation/afds/inputs/AP-disengage",1);
	setprop("/instrumentation/afds/inputs/AP"   ,0); 
	setprop("/instrumentation/afds/inputs/lateral-index",2);
	setprop("/instrumentation/afds/inputs/vertical-index",0); 
	setprop("/autopilot/settings/target-speed-kt", 250);
	setprop("/instrumentation/afds/inputs/at-armed"   ,1); 
	setprop("/instrumentation/afds/inputs/at-armed[1]",1);
	setprop("/instrumentation/afds/inputs/autothrottle-index",5); # 5 = SPD # for version 2.12.1
	setprop("/controls/flight/flaps",0);
	setprop("/sim/flaps/current-setting",0);
	
	if (nodeIN.getValue() == 6) { 
		setprop("/controls/engines/engine/throttle"   , 0.9);
		setprop("/controls/engines/engine[1]/throttle", 0.9);
	}

}


if (cruiseL == nil) setlistener("/sim/kwynn/cruise-init", doCruise, 0, 0);