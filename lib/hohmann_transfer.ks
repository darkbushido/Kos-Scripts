{
  local hohmann_transfer to lex(
    "transfer", transfer@,
    "return", transfer_return@,
    "time", transfer_time@
  ).
  function transfer {
    parameter r1, r2, d_time is eta:apoapsis.
    local my_dV to sqrt (ship:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).
    local nn TO NODE(time:seconds+d_time, 0, 0, my_dV).
    ADD nn.
    local dv to nn:deltav.
    lock steering to dv.
  }
  function transfer_return {
    parameter trgt_per is 30000.
    local r1 to (BODY:OBT:SEMIMAJORAXIS - 1.5*SHIP:OBT:SEMIMAJORAXIS).
    local r2 to (BODY:BODY:RADIUS + target_periapsis ).
    local v2 is BODY:OBT:VELOCITY:ORBIT:MAG * (sqrt((2*r2)/(r1 + r2)) -1).
    local r1 is SHIP:OBT:SEMIMAJORAXIS.
    local r2 is BODY:SOIRADIUS.
    local mu to BODY:MU.
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
    local nn to NODE(time:seconds + node_eta, 0, 0, dv).
    ADD nn. wait 0.1.
    local dv to nn:deltav.
    lock steering to dv.
  }
  function transfer_time {
    parameter r1, r2, trgt, offset is 0.
    local tt to constant():pi * sqrt((((r1 + r2)^3)/(8*ship:BODY:MU))).
    local pa to (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))).
    local aa to mod(360 + (trgt:LONGITUDE + offset) - SHIP:LONGITUDE,360) .
    local da to (mod(360 + aa - pa,360)).
    local sa to  360/SHIP:OBT:PERIOD.
    local ta to  360/trgt:OBT:PERIOD.
    local d_ang to sa - ta.
    return da/d_ang.
  }
  export(hohmann_transfer).
}
