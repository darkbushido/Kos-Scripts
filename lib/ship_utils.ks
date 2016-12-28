{
  local ship_utils is lex(
    "auto_stage", auto_stage@,
    "power", power@,
    "enable", enable@,
    "disable", disable@,
    "stageDV", stage_delta_v@
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
  function stage_delta_v {
    local LG to (ship:body:mu / ship:body:radius ^2).
    local fuels is LEX("LiquidFuel", 0.005,"Oxidizer", 0.005,"SolidFuel", 0.0075,"MonoPropellant", 0.004).
    LOCAL fuel_mass IS 0.
    FOR res IN STAGE:RESOURCES {if fuels:KEYS:CONTAINS(res:NAME)set fuel_mass to fuel_mass + fuels[res:NAME]*res:AMOUNT.}.
    LOCAL thrustTotal IS 0. LOCAL mDotTotal is 0. LOCAL avgIsp IS 0.
    LIST ENGINES IN engList.
    FOR eng in engList {
      IF eng:IGNITION {
        LOCAL t IS eng:availablethrust/100. SET thrustTotal TO thrustTotal + t.
        IF eng:ISP = 0 SET mDotTotal TO 1.
        ELSE SET mDotTotal TO mDotTotal + t / eng:ISP.
      }
    }
    IF mDotTotal > 0 set avgIsp to thrustTotal/mDotTotal.
    LOCAL deltaV IS avgIsp * LG * ln(SHIP:MASS / (SHIP:MASS-fuel_mass)).
    RETURN deltaV.
  }
  export(ship_utils).
}
