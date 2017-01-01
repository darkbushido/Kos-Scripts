@LAZYGLOBAL off.
clearscreen. wait until ship:unpacked. wait 0.
set ship:control:pilotmainthrottle to 0.
local ALL_PROCESSORS to list().
LIST PROCESSORS IN ALL_PROCESSORS.
if ALL_PROCESSORS:Length = 1 or core:tag="Main" { if not list("Landed","Splashed"):contains(status)
  lock steering to lookdirup(v(0,1,0), sun:position). }
function download_updates {
  if core:tag = "" local us to ship:name + ".ks".
  else local us to ship:name + "-" + core:tag + ".ks".
  PRINT "Looking for /updates_pending/" + us.
  IF exists("0:/updates_pending/" + us) {
    IF exists("1:/update.ks") DELETEPATH("1:/update.ks").
    COPYPATH("0:/updates_pending/" + us, "1:/update.ks").
    MOVEPATH("0:/updates_pending/" + us, "0:/updates_applied/" + us).
    RUNPATH("1:/update.ks"). DELETEPATH("1:/update.ks").
  }
}
function notfalse {
  parameter test to false.
  return not (test:typename = "Boolean" and test=false).
}
local s is stack(). local d is lex().
global import is{
  parameter n.
  s:push(n).
  if not exists("1:/"+n) copypath("0:/"+n,"1:/"+n).
  runpath("1:/"+n). return d[n].
}.
global export is{
  parameter v. set d[s:pop()] to v.
}.
if addons:rt:available {
  for a in SHIP:ModulesNamed("ModuleRTAntenna") { if a:GETFIELD("status") = "Off" and a:allevents:CONTAINS("(callable) activate, is KSPEvent") a:DOEVENT("activate"). }
  if addons:rt:hasconnection(ship) { download_updates(). }
  else { print "No Connection, Running startup.ks". }
} else {
  for antenna in SHIP:ModulesNamed("ModuleDeployableAntenna") { if antenna:GETFIELD("status") = "Retracted" antenna:DOEVENT("extend antenna"). }
  if CONTROLCONNECTION:ISCONNECTED { download_updates(). }
  else { print "No Connection, Running startup.ks". }
}
if exists("1:/startup.ks") { wait 5. import("startup.ks")().}
else {print "No startup.ks, rebooting in 10s".wait 10.print "Rebooting now".reboot.}
