run bootstrap.
run node.
run DeltaVLib.

clearScreen.

local newNode is circularizeAtApoapsis(apoapsis, time:seconds +  eta:apoapsis).

add newNode.

executeNode().
remove nextNode.