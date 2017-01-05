{
  local ship_utils is lex(
    "auto_stage", auto_stage@,
    "power", power@,
    "enable", enable@,
    "disable", disable@
  ).
  function auto_stage {
    if pT = 0 AND availablethrust > 0 set pT TO availablethrust.
    if availablethrust > pT { set pT TO availablethrust.}
    else if availablethrust = 0 { LOCK THROTTLE TO 0. WAIT 1. STAGE. WAIT 1. LOCK THROTTLE TO thrott. set pT TO availablethrust.}
    else if availablethrust < (pT - 5) {STAGE. WAIT 1.set pT TO availablethrust.}
  }
  function power {
    if SHIP:ELECTRICCHARGE > 200 enable().
    else disable().
  }
  function enable {
    if ADDONS:RT:AVAILABLE {
      for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {if antenna:GETFIELD("status") = "Off" antenna:DOEVENT("activate").}
    } else {
      for antenna in SHIP:ModulesNamed("ModuleDeployableAntenna") {
        if antenna:GETFIELD("status") = "Retracted" antenna:DOEVENT("extend antenna").}
  }}
  function disable {
    if ADDONS:RT:AVAILABLE {
      for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {
        if not list("Reflectron DP-10"):contains(antenna:part:title) {
          if not (antenna:getfield("status") = "Off") antenna:DOEVENT("deactivate").
          wait until antenna:getfield("status") = "Off".
    }}} else {
      for antenna in SHIP:ModulesNamed("ModuleDeployableAntenna") {
        if antenna:getfield("status") = "Extended" antenna:DOEVENT("retract antenna").
        wait until antenna:getfield("status") = "Retracted".
  }}}
  export(ship_utils).
}
