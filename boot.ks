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
  LOCAL allFiles to LIST().

  SWITCH TO vol.
  LIST FILES IN allFiles.
  FOR file IN allFiles {
    IF file:NAME = name {
      SWITCH TO 1.
      RETURN TRUE.
    }
  }

  SWITCH TO 1.
  RETURN FALSE.
}

// Get a file from KSC
FUNCTION DOWNLOAD {
  PARAMETER name.

  IF NOT HAS_FILE(name, 1) AND HAS_FILE(name, 0) { COPY name FROM 0. }
}

// Format a Timestamp
FUNCTION TIMESTAMP {
  RETURN TIME:YEAR + "-" + TIME:DAY + "-" + TIME:HOUR + "-" + TIME:MINUTE + "-" + TIME:SECOND.
}

// THE ACTUAL BOOTUP PROCESS
IF ADDONS:RT:HASCONNECTION(SHIP) {
  DECLARE LOCAL updateScript TO SHIP:NAME + ".update.ks".
  PRINT "Looking for " + updateScript.
  // If we have a connection, see if there are new instructions. If so, download
  // and run them.
  for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {
    if antenna:GETFIELD("status") = "Off" and
       antenna:allevents:CONTAINS("(callable) activate, is KSPEvent") {
      antenna:DOEVENT("activate").
    }
  }

  IF HAS_FILE(updateScript, 0) {

    DOWNLOAD(updateScript).
    SWITCH TO 0.
    RENAME updateScript TO SHIP:NAME + ".applied-" + TIMESTAMP() + ".ks".
    SWITCH TO 1.
    IF HAS_FILE("update.ks", 1) {
      DELETE update.ks.
    }
    RENAME updateScript TO "update.ks".
    RUN update.ks.
    DELETE update.ks.
  }
}

// If a startup.ks file exists on the disk, run that.
IF HAS_FILE("startup.ks", 1) {
  RUN startup.ks.
} ELSE {
  PRINT "REBOOTING in 10 Seconds.".
  WAIT 10. // Avoid thrashing the CPU (when no startup.ks, but we have a
           // persistent connection, it will continually reboot).
  REBOOT.
}
