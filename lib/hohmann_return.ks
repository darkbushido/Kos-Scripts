{
  local hohmann_return to lex(
    "return", transfer_return@
  ).
  function transfer_return {
    parameter trgt_per is 30000.
    local r1 to (BODY:OBT:SEMIMAJORAXIS - 1.5*SHIP:OBT:SEMIMAJORAXIS).
    local r2 to (BODY:BODY:RADIUS + trgt_per ).
    local v2 is BODY:OBT:VELOCITY:ORBIT:MAG * (sqrt((2*r2)/(r1 + r2)) -1).
    local r1 is SHIP:OBT:SEMIMAJORAXIS. local r2 is BODY:SOIRADIUS. local mu to BODY:MU.
    local ev is sqrt((r1*(r2*v2^2 - 2 * mu) + 2*r2*mu ) / (r1*r2) ).
    local dv to  abs(SHIP:OBT:VELOCITY:ORBIT:MAG-ev).
    local vv is SHIP:VELOCITY:ORBIT:VEC.
    set vv:MAG to (vv:MAG + dv).
    local spov is SHIP:Position - BODY:Position.
    local amh is (vcrs(vv,spov)):MAG.
    local se is ((vv:MAG^2)/2) - (BODY:MU/SHIP:OBT:SEMIMAJORAXIS).
    local ecc is sqrt(1 + ((2*se*amh^2)/BODY:MU^2)).
    local la is arcsin(1/ecc).
    local bod is BODY:ORBIT:VELOCITY:ORBIT:DIRECTION:YAW.
    local sod is SHIP:ORBIT:VELOCITY:ORBIT:DIRECTION:YAW.
    local lpd is (bod - 180 + la).
    local node_eta is mod((360+ sod - lpd),360)/360 * SHIP:OBT:PERIOD.
    local n to node_exec["make"](time:seconds + node_eta, 0, 0, dv).
  }
  export(hohmann_return).
}
