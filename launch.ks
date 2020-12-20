@lazyglobal off.

run node.
run utils.
run DeltaVLib.

//First, we'll clear the terminal screen to make it look nice
clearScreen.

// Variables
local targetApoapsis to 100000.
local gTurnStart to 1000.
local gTurnEnd to 80000.

local minSpeed to 250. // speed at the start
local maxSpeed to 1000.  // speed at the height max (normally atmosphere top)
local maxSpeedHeight to 30000. // Try to hit the maxspeed at this height


//This is our countdown loop, which cycles from 10 to 0
print "Counting down:".
from {local countdown is 5.} until countdown = 0 step {set countdown to countdown - 1.} do {
    print "..." + countdown.
    wait 1. // pauses the script here for 1 second.
}

lock steering to up.

// Staging logic
when maxThrust = 0 then {
  print "Staging".
  stage.
  preserve.
  wait 1.
}


// Bearing lock

declare global sVal is heading(90, 90).
lock steering to sVal.

//  Throttle lock

declare global tVal is 1.0.
lock throttle to tVal.

// pidloop

local Kp is 0.01.
local Ki is 0.006.
local Kd is 0.006.
local pid is pidLoop(Kp, Ki, Kd, 0, 1).

// Gravity Turn

until apoapsis > targetApoapsis + 100 {

  local progress is (altitude - gTurnStart) / (gTurnEnd - gTurnStart).
  set sVal to heading(90, min(90 - (-90 * progress * (progress -2 )), 90)).

  // Decides the max speed based on a customizable x^2 equation.
  local throttleParam is (maxSpeedHeight^2) * (maxSpeed - minSpeed)^(-1).
  set pid:setpoint to ((altitude ^ 2) / throttleParam) + 250.
  set tVal to pid:update(time:seconds, ship:velocity:surface:mag).

  print "Apoapsis" at (0, 16).
  print round(apoapsis, 4) at (18, 16).
  print "Velocity Surface" at (0, 17).
  print round(ship:velocity:surface:mag, 4) at (18, 17).
  print "Target Speed" at (0, 18).
  print round(pid:setpoint, 4) at (18, 18).
  

  wait 0.001.
}

print apoapsis + " apoapsis reached, coasting to " + body:atm:height.

set tVal to 0.0.



// At very top of the atmosphere deploy fairings, then open solar + antennas
wait until ship:altitude > 0.95 * body:atm:height.

for module in ship:modulesnamed("ModuleProceduralFairing") {
  module:doevent("deploy").
  hudtext("Fairing Utility: Aproaching edge of atmosphere; Deploying Fairings", 3, 2, 30, green, false).
  print "Deploying Fairings".
}

for module in ship:modulesnamed("ProceduralFairingDecoupler") {
  module:doevent("deploy").
  hudtext("Fairing Utility: Aproaching edge of atmosphere; Jettisoning Fairings", 3, 2, 30, green, false).
  print "Jettisoning Fairings".
}

wait 2.0.

set ag1 to true.

hudtext("Aproaching edge of atmosphere; Activating AG1", 3, 2, 30, green, false).
print "Activating AG1".



wait until ship:altitude > body:atm:height.

// Create circularization node
print "Creating circularization node".
local circularizationNode to circularizeAtApoapsis(apoapsis, time:seconds + eta:apoapsis).
add circularizationNode.

executeNode().

remove circularizationNode.

print "Node executed, orbit achieved!".


// Execute Node


set ship:control:pilotmainthrottle to 0.