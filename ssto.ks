@lazyglobal off.

run utils.
run node.
run DeltaVLib.

clearScreen.

PRINT " ".
PRINT "**************************************************".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**            SSTO Launch-script v0.1           **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**            (c) Oliver Butler 2020            **".
PRINT "**                 License: MIT                 **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**************************************************".
PRINT " ".
PRINT " ".

// ******************************************************************** //
// ********************** VARIABLE-DECLARATIONS *********************** //
// ******************************************************************** //

// Enable engine preheating
local engine_preheating is true.

// Takeoff speed
local takeoff_speed is 130.

// Initial ascent (0m - target_altitude)
local initial_pitch is 15.

// crusing altitude (where we gain most of our speed)
local crusing_altitude is 12000.

// crusing speed for the target_altitude
local crusing_speed is 1300.

// Final ascent pitch
local final_pitch is 25.

// Target apoapsis
local target_apoapsis is 80000.

// ******************************************************************** //
// **************************** SSTO Launch *************************** //
// *******************************************************************

//  Throttle lock

declare global tVal is 0.0.
lock throttle to tVal.

// Pre Flight Checks

brakes on.
gear on.

print "Pre Flight: Starting Coutdown".

startCountdown(5).

set tVal to 1.0.

stage.

if engine_preheating {
  print "Pre Flight: Engine Preheating".
  wait 10.
}

brakes off.

print "Runway: Releasing Brakes".

// Im doing this after as I feel while breaks are on it confuses the cooked steering.

declare global sVal is heading(90, 0).
lock steering to sVal.
set steeringManager:rollts to steeringManager:rollts / 2.
set steeringManager:yawts to steeringManager:yawts / 2.
set steeringManager:pitchts to steeringManager:pitchts / 2.


until ship:velocity:surface:mag > takeoff_speed {
  wait 0.1.
}

print "Flight: Takeoff".

set sVal to heading(90, initial_pitch).

until ship:altitude > 100 {
  wait 0.1.
}

print "Flight: Gear Up".

gear off.

print "Flight: Climbing to crusing altitude of " + crusing_altitude + "m at " + initial_pitch + " deg".
until ship:altitude > crusing_altitude {
  set sVal to heading(90, initial_pitch). // I need to keep doing this, as we're on a sphere
  wait 0.1.
}

// ******************************************************************** //
// *********************** Crusing Altitude *************************** //
// ******************************************************************** //

print "Flight: Reached crusing altitude, pitching down to gain speed".

// Lets use a handy dandy PID loop to keep the altitude at the crusing altitude

local Kp is 0.005.
local Ki is 0.006.
local Kd is 0.006.
local pid is pidLoop(Kp, Ki, Kd, -1, 2).

set pid:setpoint to crusing_altitude.

until ship:velocity:surface:mag > crusing_speed {
  local pitch is pid:update(time:seconds, ship:altitude).
  set sVal to heading(90, pitch).

  printVal("PID Target Pitch", pitch, 0).
  wait 0.001.
}

clear_line(0).


print "Flight: Reached crusing speed of " + crusing_speed + "m/s reached, pitching up for final ascent".

until ship:velocity:surface:mag 

set sVal to heading(90, (final_pitch / 5) * 1).

wait 5.

set sVal to heading(90, (final_pitch / 5) * 2).

wait 5.

set sVal to heading(90, (final_pitch / 5) * 3).

wait 5.

set sVal to heading(90, (final_pitch / 5) * 4).

wait 5.

set sVal to heading(90, (final_pitch / 5) * 5).

local closed_cycle is false.
until apoapsis > target_apoapsis {

  if ship:velocity:surface:mag < crusing_speed * 0.95 AND closed_cycle = false {

    print "Flight: Speed dropped to 95% of crusing speed, entering closed cycle mode".
    ag3 on.

    wait 1.

    print "Flight: Disabling Air Intakes to improve drag".
    intakes off.

    set closed_cycle to true.
  }

  set sVal to heading(90, final_pitch).

  wait 0.1.
}

print "Flight: Reached target apoapsis of " + target_apoapsis + "m".

set tVal to 0.0.

print "Flight: Waiting to leave atmosphere".

wait until altitude > body:atm:height.

print "Orbit: Creating node at apoapsis".

local node is circularizeAtApoapsis().
add node.

print "Orbit: Executing Node".

executeNode().

print "Orbit: Node Execution Complete".

wait 2.

clearScreen.

PRINT "**************************************************".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**           Transferring control back          **".
PRINT "**                                              **".
PRINT "**        Enjoy the rest of your journey!       **".
PRINT "**                     :D                       **".
PRINT "**                      _                       **".
PRINT "**                     / \                      **".
PRINT "**                    |.-.|                     **".
PRINT "**                    |   |                     **".
PRINT "**                    | O |                     **".
PRINT "**                    |   |                     **".
PRINT "**                  _ | O | _                   **".
PRINT "**                 / \|   |/ \                  **".
PRINT "**                |   | O |   |                 **".
PRINT "**                |   |   |   |                 **".
PRINT "**               ,'   | O |   '.                **".
PRINT "**             ,' |   |   |   | `.              **".
PRINT "**           .'___|___|_ _|___|___'.            **".
PRINT "**                 /_\ /_\ /_\                  **".
PRINT "**           SSTO Launch-script v0.1            **".
PRINT "**                                              **".
PRINT "**                                              **".
PRINT "**************************************************".
PRINT " ".

sas on.
set ship:control:pilotmainthrottle to 0.
