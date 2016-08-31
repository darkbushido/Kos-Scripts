// Generalized Boot Script v1.0.1
// Kevin Gisi
// http://youtube.com/gisikw

@LAZYGLOBAL off.
// The ship will use updateScript to check for new commands from KSC.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// Display a message
FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, false).
}

// Detect whether a file exists on the specified volume
FUNCTION HAS_FILE {
  PARAMETER name.
  PARAMETER vol.

  SWITCH TO vol.
  DECLARE LOCAL file_exists to exists(name).
  switch to 1.
  return file_exists.
}

// Get a file from KSC
FUNCTION DOWNLOAD {
  PARAMETER name.

  IF NOT HAS_FILE(name, 1) AND HAS_FILE(name, 0) { COPYPATH("0:/" + name, "1:/" + name ). }
}

// Format a Timestamp
FUNCTION TIMESTAMP {
  RETURN TIME:YEAR + "-" + TIME:DAY + "-" + TIME:HOUR + "-" + TIME:MINUTE + "-" + TIME:SECOND.
}

function download_updates {
  PRINT "Looking for /updates_pending/" + updateScript.
  IF HAS_FILE("/updates_pending/" + updateScript, 0) {
    DOWNLOAD("/updates_pending/" + updateScript).
    SWITCH TO 0.
    MOVEPATH("/updates_pending/" + updateScript, "/updates_applied/" + updateScript).
    SWITCH TO 1.
    IF HAS_FILE("update.ks", 1) {
      DELETEPATH("update.ks").
    }
    MOVEPATH("/updates_pending/" + updateScript, "update.ks").
    RUN update.ks.
    DELETEPATH("update.ks").
  }
}
// THE ACTUAL BOOTUP PROCESS
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

// If a startup.ks file exists on the disk, run that.
IF HAS_FILE("startup.ks", 1) {
  WAIT 5.
  RUN startup.ks.
} ELSE {
  PRINT "REBOOTING in 10 Seconds.".
  WAIT 10. // Avoid thrashing the CPU (when no startup.ks, but we have a
           // persistent connection, it will continually reboot).
  REBOOT.
}
