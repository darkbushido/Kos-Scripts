{
  local ship_utils is lex(
    "auto_stage", auto_stage@,
    "power", power@,
    "enable", enable@,
    "disable", disable@
  ).
  function auto_stage {
    if prevThrust = 0 AND AVAILABLETHRUST > 0
      set prevThrust TO AVAILABLETHRUST.
    if NOT STAGE:READY {}
    else if AVAILABLETHRUST = 0 {
      set currentThrottle TO st.
      LOCK THROTTLE TO 0.
      WAIT 1. STAGE. WAIT 1.
      LOCK THROTTLE TO st.
      set prevThrust TO AVAILABLETHRUST.
    } else if AVAILABLETHRUST < (prevThrust - 10) {
      STAGE. WAIT 1.
      set prevThrust TO AVAILABLETHRUST.
  }}
  function power {
    if SHIP:ELECTRICCHARGE < 30 disable().
    else if SHIP:ELECTRICCHARGE >= 50 enable().
  }
  function enable {
    if ADDONS:RT:AVAILABLE {
      for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {
        if antenna:GETFIELD("status") = "Off" antenna:DOEVENT("activate").
  }}}
  function disable {
    if ADDONS:RT:AVAILABLE {
      for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {
        if not list("Reflectron DP-10", "Reflectron KR-7"):contains(antenna:part:title) {
          if not (antenna:getfield("status") = "Off") antenna:DOEVENT("deactivate").
            wait until antenna:getfield("status") = "Off".
  }}}}

  export(ship_utils).
}
