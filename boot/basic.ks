@LAZYGLOBAL off.
clearscreen.
set ship:control:pilotmainthrottle to 0.
lock steering to sun:position.
function download_updates {
  parameter us.
  PRINT "Looking for /updates_pending/" + us.
  if not exists("1:/knu.ks")
    copypath("0:/lib/knu.ks", "1:/lib/knu.ks").
  runpath("1:/lib/knu.ks").
  IF exists("0:/updates_pending/" + us) {
    IF exists("1:/update.ks")
      DELETEPATH("1:/update.ks").
    COPYPATH("0:/updates_pending/" + us, "1:/update.ks").
    MOVEPATH("0:/updates_pending/" + us, "0:/updates_applied/" + us).
    RUNPATH("update.ks").
    DELETEPATH("update.ks").
  }
}

local us to ship:name + ".ks".
if addons:rt:available {
  for a in SHIP:ModulesNamed("ModuleRTAntenna") {
    if a:GETFIELD("status") = "Off" and a:allevents:CONTAINS("(callable) activate, is KSPEvent")
      a:DOEVENT("activate").
  }
  if addons:rt:hasconnection(ship)
    download_updates(us).
} else {
  download_updates(us).
}
if exists("1:/startup.ks") {
  wait 5. import("startup.ks")().
} else {
  wait 10. reboot.
}
