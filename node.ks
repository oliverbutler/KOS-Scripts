@lazyglobal off.

run utils.

// test 123
function circularizeAtApoapsis {
  parameter targetApoapsis.
  parameter nodeETA.

  return makeNode(targetApoapsis, targetApoapsis, nodeETA).
}

function test {
  // set sVal to heading(90, 90).
  set tVal to 0.1.
}

// Make a new maneuever node
function makeNode {
  parameter nodeAltitude.
  parameter targetAltitude.
  parameter nodeETA.

  local r1 to nodeAltitude + body:radius.
  local a1 to orbit:semimajoraxis.
  local v1 to sqrt(body:mu * ((2 / r1) - (1 / a1))).

  local r2 to nodeAltitude + body:radius.
  local a2 to (nodeAltitude + targetAltitude + 2 * body:radius) / 2.
  local v2 to sqrt(body:mu * ((2 / r2) - (1 / a2))).

  return node(nodeETA, 0, 0, v2 - v1).
}

function executeTest {
  
  clearScreen.

  set sVal to heading(90, 0).

  set tVal to 0.1.

  wait 1.
  
  set tVal to 0.0.

}

// Executes the next node
function executeNode {
  
  clearScreen.

  local nd is nextNode.

  set sVal to nd:deltav.

  hudtext("Node: Moving towards dV direction", 3, 2, 30, green, false).

  wait until vang(sVal, ship:facing:vector) < 0.25.

  hudtext("Node: Direction Aligned", 3, 2, 30, green, false).

  // Uses DeltaVLib, I will make my own once I have a better grasp of the language.
  local burnStats is calcBurnMean(nd:deltav:mag).
  print burnStats.

  // Warp closer
  if(nd:eta - burnStats[1] > 30) {
    hudtext("Node: Warping closer", 3, 2, 30, green, false).
    kuniverse:timewarp:warpto(time:seconds + nd:eta - burnStats[1] - 60).
  }

  // Wait until burn
  until false {
    printVal("ETA Node", nd:eta, 0, 1).
    printVal("Burn In", nd:eta - burnStats[1] / 2.0, 1, 1).

    if nd:eta <= burnStats[1] / 2.0 {
      hudtext("Node: Beginning burn!", 3, 2, 30, green, false).
      clearScreen.
      break.
    }
  }

  // Actually do the burn
  local nodeDone is false.
  local dv0 is nd:deltav.

  until nodeDone {

    local maxAcc is ship:maxthrust/ship:mass.

    if maxAcc <> 0 {
      set tVal to min(nd:deltav:mag/maxAcc, 1.0).
    }

    // cut throttle if dot product of nd:deltav and initial deltav start facing opposite directions

    if vdot(dv0, nd:deltaV) < 0 {
      hudtext("Node: vdot getting too far, bailing", 3, 2, 30, red, false).
      set tVal to 0.0.
      break.
    }

    // We have very little left to burn, less than 0.1m/s
    if nd:deltav:mag < 0.1 {
      //we burn slowly until our node vector starts to drift significantly from initial vector
      //this usually means we are on point
      wait until vdot(dv0, nd:deltav) < 0.5.

      hudtext("Node: Successfully completed node execution", 3, 2, 30, green, false).

      set tVal to 0.0.
      set nodeDone to True.
    }

    printVal("Remaning dV", nd:deltav:mag, 0, 1).
    printVal("vdot", vdot(dv0, nd:deltav), 1, 1).
  }

}