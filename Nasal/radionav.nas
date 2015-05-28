######################### Processes Heading bug information #########################

var SetHdg = func{

#Sets heading bug to current heading

	setprop("autopilot/settings/heading-bug-deg", getprop("orientation/heading-magnetic-deg"));
}

var HeadingBug = func{

#Caluculate difference in actual and target headings, and write to bugoff.

	var hdg = getprop("orientation/heading-magnetic-deg");
	var HdgTgt = getprop("autopilot/settings/heading-bug-deg");
	var BugOff = (hdg - HdgTgt);
	setprop("autopilot/settings/bugoff-deg", BugOff);
	settimer(HeadingBug, 0.1);

}
#########################  Sorts out the RMI  #########################

#First, set all RMI pointers to VOR, as per most real F50s:
#We're going to use 0= VOR, 1=ADF, to make the animation easier.

var SetupRMIs = func {

	setprop("instrumentation/rmi/captswitch1", 0);
	setprop("instrumentation/rmi/captswitch2", 0);
	setprop("instrumentation/rmi/foswitch1", 0);
	setprop("instrumentation/rmi/foswitch2", 0);

#This next bit is important- we need to check that tboth VORs are tuned to valid freqs, and if not, correct them!
#If the VOR data is invalid, then the RMIs will break during flight.

	if (!getprop("instrumentation/nav/data-is-valid")){
		setprop("instrumentation/nav/frequencies/selected-mhz", 113.55);
		print("Caution - VOR 1 frequency not valid.  Default freq used.");	}
	if (!getprop("instrumentation/nav[1]/data-is-valid")){
		setprop("instrumentation/nav[1]/frequencies/selected-mhz", 113.55);
		print("Caution - VOR 2 frequency not valid.  Default freq used.");	}

	RMIPointers();
}

#Here's a recurring function to monitor whether VOR or ADF is selected, and to put the right value in the pointer.

var RMIPointers = func{

#Define switch positions as variables:
	var cs1 = getprop ("instrumentation/rmi/captswitch1");
	var cs2 = getprop ("instrumentation/rmi/captswitch2");
	var fs1 = getprop ("instrumentation/rmi/foswitch1");
	var fs2 = getprop ("instrumentation/rmi/foswitch2");
	
#Figure out pointer rotation directions for all possibilities:
	var a1 = getprop("instrumentation/adf/indicated-bearing-deg");
	var a2 = getprop("instrumentation/adf[1]/indicated-bearing-deg");

#We need to do check that VOR data is valid before using the figures.
	if (getprop("instrumentation/nav/data-is-valid")){
		var v1 = getprop("instrumentation/nav/heading-deg")-getprop("orientation/heading-magnetic-deg"); }
	else { var v1 = 90 }
	if (getprop("instrumentation/nav[1]/data-is-valid")){
		var v2 = getprop("instrumentation/nav[1]/heading-deg")-getprop("orientation/heading-magnetic-deg"); }
	else { var v2 = 90 }
#If VOR is out of range (but data-is-valid), or tuned to an ILS, point to the right.
	if (!getprop("instrumentation/nav/in-range") or getprop("instrumentation/nav/has-gs")) {v1 = 90}
	if (!getprop("instrumentation/nav[1]/in-range") or getprop("instrumentation/nav[1]/has-gs")) {v2 = 90}

#Now figure out which is the active value
	if (cs1 == 0) {cp1 = v1}
		else {cp1 = a1}
	if (cs2 == 0) {cp2 = v2}
		else {cp2 = a2}
	if (fs1 == 0) {fp1 = v1}
		else {fp1 = a1}
	if (fs2 == 0) {fp2 = v2}
		else {fp2 = a2}

	
#Now write everything to the FG properties:
	setprop("instrumentation/rmi/captpointer1", cp1);
	setprop("instrumentation/rmi/captpointer2", cp2);
	setprop("instrumentation/rmi/fopointer1", fp1);
	setprop("instrumentation/rmi/fopointer2", fp2);

	settimer(RMIPointers, 0.1);

}

var ToFrom = func {
#Here's a thingie to work out which way the to/from pointer on the ND points.
	var direction = getprop("orientation/heading-magnetic-deg") - getprop("instrumentation/nav/radials/selected-deg");
	if (getprop("instrumentation/nav/from-flag")) { direction = direction + 180 }
	if (direction > 360) {direction = direction - 360}
	setprop("instrumentation/nav/to-from/direction", direction);

#same again for VOR2
	direction = getprop("orientation/heading-magnetic-deg") - getprop("instrumentation/nav[1]/radials/selected-deg");
	if (getprop("instrumentation/nav[1]/from-flag")) { direction = direction + 180 }
	if (direction > 360) {direction = direction - 360}
	setprop("instrumentation/nav[1]/to-from/direction", direction);

	settimer(ToFrom, 0.1);
}

setlistener("sim/signals/fdm-initialized", SetHdg);
setlistener("sim/signals/fdm-initialized", HeadingBug);
setlistener("sim/signals/fdm-initialized", SetupRMIs);
setlistener("sim/signals/fdm-initialized", ToFrom);

#init();
