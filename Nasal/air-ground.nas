# Controls systems that depend on the air-ground sensor
# (also called "squat-switch") position.  This assumes
# the airplane always starts on the ground (just like the
# real airplane).
#
# For the purposes of this model the 737's flight spoilers are called
# "speedbrakes" and the ground spoilers are called "spoilers".

aircraft.light.new("sim/model/A-6E/lighting/warn-medium-lights-switch", [0.6, 1.0]);
setprop("sim/model/A-6E/lighting/warn-medium-lights-switch/enabled", 1);

var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.025, 1.5], "/controls/lighting/beacon" );
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0.015, 1.2], "/controls/lighting/strobe" );

setprop("/sim/sound/Ovolume", 0.5);
setprop("/sim/sound/Pvolume", 0.3);
setprop("/sim/sound/Evolume", 0.1);
setprop("/sim/sound/Ivolume", 0.25);

gear_dwn = getprop("controls/gear/gear-down");

var flapsDown = func(step) {
    if(step == 0) return;
    if(props.globals.getNode("/sim/flaps") != nil) {
        stepProps("/controls/flight/flaps", "/sim/flaps", step);
        return;
    }
    # Hard-coded flaps movement in 3 equal steps:
    var val = 0.3333334 * step + getprop("/controls/flight/flaps");
    setprop("/controls/flight/flaps", val > 1 ? 1 : val < 0 ? 0 : val);
}

INAIR = "false";
REJECT = "false";
LANDED = "false";

call_airground = func {
   WOW = getprop("/gear/gear[1]/wow");
   GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593;  
 
   if (WOW == 1) {
      # left main gear strut is compressed

     if (INAIR == "false") {
             
        if ((getprop("/controls/gear/autobrakes") == 5) and (REJECT=="false")) {
          if (getprop("/controls/engines/engine[0]/throttle") < 0.1) { 
            if (GROUNDSPEED > 60.0) {
              REJECT = "true";
              print ("Rejecting Takeoff at ", GROUNDSPEED, " kts ground speed.");
            }
          }
        }

        if (REJECT == "true") {
          if (GROUNDSPEED < 10.0) {
            REJECT = "false";
            setprop("/controls/gear/autobrakes", 0);
            setprop("/controls/gear/brake-left", 0.0);
            setprop("/controls/gear/brake-right", 0.0);
          } else {
            setprop("/controls/gear/brake-left", 1.0);
            setprop("/controls/gear/brake-right", 1.0);
            setprop("/controls/flight/speedbrake", 1.0);
            setprop("/controls/flight/spoilers", 1.0);
          } 
        }

        if (LANDED == "true") {
          if (getprop("/controls/engines/engine[0]/throttle") > 0.3) { 
             LANDED = "false";
             setprop("/controls/flight/speedbrake", 0.0);
             setprop("/controls/flight/spoilers", 0.0);
             setprop("/controls/gear/autobrakes", 0);
             setprop("/controls/gear/brake-left", 0.0);
             setprop("/controls/gear/brake-right", 0.0);
          }
          if (GROUNDSPEED < 10.0) {
            LANDED = "false";
            setprop("/controls/gear/autobrakes", 0);
            setprop("/controls/gear/brake-left", 0.0);
            setprop("/controls/gear/brake-right", 0.0);
          }
        }


     } else {
       # we have touched down
       INAIR = "false";
       LANDED = "true";

        var SETTING = getprop("/controls/gear/autobrakes");

        if (SETTING == 0) {
          # autobrakes are off, so do nothing here
        }
        elsif (SETTING == 1) {
          # autobrakes set to level 1
          setprop("/controls/gear/brake-left", 0.2);
          setprop("/controls/gear/brake-right", 0.2);
        }
        elsif (SETTING == 2) {
          # autobrakes set to level 2
          setprop("/controls/gear/brake-left", 0.4);
          setprop("/controls/gear/brake-right", 0.4);
        }
        elsif (SETTING == 3) {
          # autobrakes set to level 3
          setprop("/controls/gear/brake-left", 0.8);
          setprop("/controls/gear/brake-right", 0.8);
        }
        elsif (SETTING == 4) {
          # autobrakes set to level MAX
          setprop("/controls/gear/brake-left", 1.0);
          setprop("/controls/gear/brake-right", 1.0);
        }
        else {
          # autobrakes mistakenly set to wrong value
          setprop("/controls/gear/autobrakes", 0);
        }

        # raise speedbrakes and spoilers if they are armed
        if (getprop("/controls/flight/autospeedbrakes-armed") == "true") {
            setprop("/controls/flight/speedbrake", 1.0);
            setprop("/controls/flight/spoilers", 1.0);
            setprop("/controls/flight/autospeedbrakes-armed", "false");         
        } 
     }

   } else {
      # left main gear is not compressed
      INAIR = "true";
      LANDED = "false";
   }

   # schedule the next call
   settimer(call_airground, 0.2);   
}
 
init = func {
   settimer(call_airground, 0.0);
}

init();
  