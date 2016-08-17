SET LG to (ship:body:mu / ship:body:radius ^2).
SET prevThrust TO AVAILABLETHRUST.

function auto_stage {
  parameter mission.
  if prevThrust = 0 AND AVAILABLETHRUST > 0 {
    set prevThrust TO AVAILABLETHRUST.
  }
  if NOT STAGE:READY {
  } else if AVAILABLETHRUST = 0 {
    set currentThrottle TO st.
    LOCK THROTTLE TO 0.
    WAIT 1. STAGE. WAIT 1.
    LOCK THROTTLE TO st.
    set prevThrust TO AVAILABLETHRUST.
  } else if AVAILABLETHRUST < (prevThrust - 10) {
    STAGE. WAIT 1.
    set prevThrust TO AVAILABLETHRUST.
  }
}

function ensure_power {
  parameter mission.

  if SHIP:ELECTRICCHARGE < 30 disable_antennas().
  if SHIP:ELECTRICCHARGE > 50 enable_antennas().
}

function enable_antennas {
  for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {
    if antenna:GETFIELD("status") = "Off"
      antenna:DOEVENT("activate").
  }
}

function disable_antennas {
  for antenna in SHIP:ModulesNamed("ModuleRTAntenna") {
    if not list("Reflectron DP-10", "Reflectron KR-7"):contains(antenna:part:title) {
      if not (antenna:getfield("status") = "Off")
        antenna:DOEVENT("deactivate").
      print "Waiting to retract antenna " + antenna:part:title.
      wait until antenna:getfield("status") = "Off".
    }
  }
}

function finished {
  parameter mission.
  parameter params.
  deletepath("startup.ks").
  mission["terminate"]().
}

function stage_delta_v {
  local fuels is LEX(
    "LiquidFuel", 0.005,
    "Oxidizer", 0.005,
    "SolidFuel", 0.0075,
    "MonoPropellant", 0.004
    ).
  LOCAL fuel_mass IS 0.
  FOR res IN STAGE:RESOURCES {
    if fuels:KEYS:CONTAINS(res:NAME)
      set fuel_mass to fuel_mass + fuels[res:NAME]*res:AMOUNT.
  }.
  LOCAL thrustTotal IS 0.
  LOCAL mDotTotal IS 0.
  LIST ENGINES IN engList.
  FOR eng in engList
  {
    IF eng:IGNITION
    {
      LOCAL t IS eng:AVAILABLETHRUST/100.
      SET thrustTotal TO thrustTotal + t.
      IF eng:ISP = 0 SET mDotTotal TO 1.
      ELSE SET mDotTotal TO mDotTotal + t / eng:ISP.
    }.
  }.
  IF mDotTotal = 0 LOCAL avgIsp IS 0.
  ELSE LOCAL avgIsp IS thrustTotal/mDotTotal.
  LOCAL deltaV IS avgIsp * LG * ln(SHIP:MASS / (SHIP:MASS-fuel_mass)).
  RETURN deltaV.
}

function mnv_time {
  parameter dv.
  set ens to list().
  ens:clear.
  set ens_thrust to 0.
  set ens_isp to 0.
  list engines in myengines.
  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }
  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
  }
  if ens_thrust = 0 or ens_isp = 0 {
    notify("No engines available!").
    return 0.
  }
  else {
    local f is ens_thrust * 1000.
    local m is ship:mass * 1000.
    local e is constant():e.
    local p is ens_isp/ens:length.
    local g is ship:orbit:body:mu/ship:obt:body:radius^2.
    return g * m * p * (1 - e^(-dv/(g*p))) / f.
  }
}
