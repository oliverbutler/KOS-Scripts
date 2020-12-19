
//First, we'll clear the terminal screen to make it look nice
clearScreen.

// Variables
set targetApoapsis to 100000.
set gTurnStart to 1000.
set gTurnEnd to 70000.

set minSpeed to 250. // speed at the start
set maxSpeed to 1000.  // speed at the height max (normally atmosphere top)
set maxSpeedHeight to 30000. // Try to hit the maxspeed at this height


//This is our countdown loop, which cycles from 10 to 0
print "Counting down:".
from {local countdown is 5.} until countdown = 0 step {set countdown to countdown - 1.} do {
    print "..." + countdown.
    wait 1. // pauses the script here for 1 second.
}

lock steering to up.

// Staging logic
when maxThrust = 0 then {
  print "Thrust 0, Staging".
  stage.
  preserve.
}


// Bearing lock

set mySteer to heading(90, 90).
lock steering to mySteer.

//  Throttle lock

set myThrottle to 1.0.
lock throttle to myThrottle.

// pidloop

set Kp to 0.01.
set Ki to 0.006.
set Kd to 0.006.
set pid to pidLoop(Kp, Ki, Kd, 0, 1).

// Gravity Turn

until apoapsis > targetApoapsis + 1000 {

  set progress to (altitude - gTurnStart) / (gTurnEnd - gTurnStart).
  set mySteer to heading(90, min(90 - (-90 * progress * (progress -2 )), 90)).

  // Decides the max speed based on a customizable x^2 equation.
  set throttleParam to (maxSpeedHeight^2) * (maxSpeed - minSpeed)^(-1).
  set pid:setpoint to ((altitude ^ 2) / throttleParam) + 250.
  set myThrottle to pid:update(time:seconds, ship:velocity:surface:mag).

  print "Apoapsis" at (0, 16).
  print round(apoapsis, 4) at (18, 16).
  print "Velocity Surface" at (0, 17).
  print round(ship:velocity:surface:mag, 4) at (18, 17).
  print "Target Speed" at (0, 18).
  print round(pid:setpoint, 4) at (18, 18).
  

  wait 0.001.
}

print "100k apoapsis reached, coasting".

set myThrottle to 0.

// set circularizationNode to node(eta:apoapsis, )




set ship:control:pilotmainthrottle to 0.