@LAZYGLOBAL off.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// Format a Timestamp
FUNCTION TIMESTAMP {
  RETURN TIME:YEAR + "-" + TIME:DAY + "-" + TIME:HOUR + "-" + TIME:MINUTE + "-" + TIME:SECOND.
}

function download_updates {
  PRINT "Looking for /updates_pending/" + updateScript.
  IF exists("0:/updates_pending/" + updateScript) {
    IF exists("1:/update.ks")
      DELETEPATH("1:/update.ks").
    COPYPATH("0:/updates_pending/" + updateScript, "1:/update.ks").
    MOVEPATH("0:/updates_pending/" + updateScript, "0:/updates_applied/" + updateScript).
    RUN update.ks.
    DELETEPATH("update.ks").
  }
}
DECLARE LOCAL updateScript TO SHIP:NAME + ".ks".
IF ADDONS:RT:AVAILABLE {
  for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {
    if antenna:GETFIELD("status") = "Off" and
       antenna:allevents:CONTAINS("(callable) activate, is KSPEvent") {
      antenna:DOEVENT("activate").
    }
  }
  if ADDONS:RT:HASCONNECTION(SHIP)
    download_updates.
} else {
  download_updates.
}

IF exists("1:/startup.ks") {
  WAIT 5.
  RUN startup.ks.
} ELSE {
  PRINT "REBOOTING in 10 Seconds.".
  WAIT 10.
  REBOOT.
}
