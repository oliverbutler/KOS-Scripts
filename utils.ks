@lazyglobal off.

local empty_line is "                                                  ".

function specificImpulse {
  local engineList is list().
  local totalThrust is 0.
  local totalFlow is 0.

  list engines in engineList.

  for engine in engineList {
    if engine:ignition AND NOT engine:flameout {
      set totalThrust to totalThrust + engine:availableThrust.
      set totalFlow to totalFlow + (engine:availableThrust / engine:isp).
    }
  }

  if totalThrust = 0 {
    return 1.
  }

  return totalThrust / totalFlow.

}


function printVal {
  parameter name.
  parameter value.
  parameter row is 0.
  parameter round is false.

  print name + ": " at (0, terminal:height - row).

  if(round = false) {
    print value at (terminal:width / 2, terminal:height - row).
  } else {
    print round(value, round) at (terminal:width / 2, terminal:height - row).
  }
}

function clear_line {
  parameter row is 0.

  print empty_line at (0, terminal:height - row).
}

function startCountdown {

  parameter duration is 5.

  local countdown is 5.

  hudtext("Starting Countdown..." + countdown, 3, 2, 30, green, false).

  from {local cd is duration.} until countdown = 0 step {set countdown to countdown - 1.} do {
    hudtext("T-" + countdown, 3, 2, 30, green, false).
    wait 1. // pauses the script here for 1 second.
  }
}