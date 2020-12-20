@lazyglobal off.

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
  parameter row.
  parameter round is false.

  print name + ": " at (0, 25 + row).

  if(round = false) {
    print value at (15, 25 + row).
  } else {
    print round(value, round) at (15, 25 + row).
  }
}