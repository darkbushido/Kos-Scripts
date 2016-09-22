@LAZYGLOBAL off.
clearscreen.
set ship:control:pilotmainthrottle to 0.
lock steering to lookdirup(v(0,1,0), sun:position).
function download_updates {
  local us to ship:name + ".ks".
  if not exists("1:/lib/knu.ks")
    copypath("0:/lib/knu.ks", "1:/lib/knu.ks").
  runpath("1:/lib/knu.ks").
  PRINT "Looking for /updates_pending/" + us.
  IF exists("0:/updates_pending/" + us) {
    IF exists("1:/update.ks")
      DELETEPATH("1:/update.ks").
    COPYPATH("0:/updates_pending/" + us, "1:/update.ks").
    MOVEPATH("0:/updates_pending/" + us, "0:/updates_applied/" + us).
    RUNPATH("1:/update.ks").
    DELETEPATH("1:/update.ks").
  }
}
wait until ship:unpacked.
if addons:rt:available {
  for a in SHIP:ModulesNamed("ModuleRTAntenna") {
    if a:GETFIELD("status") = "Off" and a:allevents:CONTAINS("(callable) activate, is KSPEvent")
      a:DOEVENT("activate").
  }
  if addons:rt:hasconnection(ship) { download_updates(). }
  else if exists("1:/lib/knu.ks") { runpath("1:/lib/knu.ks"). print "No Connection, running startup.ks".}
  else { print "No Connection, No knu.ks". }
} else {
  download_updates().
}
if exists("1:/startup.ks") {
  wait 5. import("startup.ks")().
} else {
  print "No startup.ks, rebooting in 10s".
  wait 10.
  print "Rebooting now".
  reboot.
}
