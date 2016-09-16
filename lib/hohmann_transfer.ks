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
    lock steering to nn:DELTAV.
  }
  function transfer_return {
    parameter trgt_per is 30000.
    local r1 to (BODY:OBT:SEMIMAJORAXIS - 1.5*SHIP:OBT:SEMIMAJORAXIS).
    local r2 to (BODY:BODY:RADIUS + target_periapsis ).
    local v2 is BODY:OBT:VELOCITY:ORBIT:MAG * (sqrt((2*r2)/(r1 + r2)) -1).
    local r1 is SHIP:OBT:SEMIMAJORAXIS.
    local r2 is BODY:SOIRADIUS.
    local mu to BODY:MU.
    local ejection_vel is sqrt((r1*(r2*v2^2 - 2 * mu) + 2*r2*mu ) / (r1*r2) ).
    local delta_v to  abs(SHIP:OBT:VELOCITY:ORBIT:MAG-ejection_vel).
    local vel_vector is SHIP:VELOCITY:ORBIT:VEC.
    set vel_vector:MAG to (vel_vector:MAG + delta_v).
    local ship_pos_orbit_vector is SHIP:Position - BODY:Position.
    local angular_momentum_h is (vcrs(vel_vector,ship_pos_orbit_vector)):MAG.
    local spec_energy is ((vel_vector:MAG^2)/2) - (BODY:MU/SHIP:OBT:SEMIMAJORAXIS).
    local ecc is sqrt(1 + ((2*spec_energy*angular_momentum_h^2)/BODY:MU^2)).
    local launch_angle is arcsin(1/ecc).
    local body_orbit_direction is BODY:ORBIT:VELOCITY:ORBIT:DIRECTION:YAW.
    local ship_orbit_direction is SHIP:ORBIT:VELOCITY:ORBIT:DIRECTION:YAW.
    local launch_point_dir is (body_orbit_direction - 180 + launch_angle).
    local node_eta is mod((360+ ship_orbit_direction - launch_point_dir),360)/360 * SHIP:OBT:PERIOD.
    local my_node to NODE(time:seconds + node_eta, 0, 0, delta_v).
    ADD my_node.
    lock steering to nn:DELTAV.
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
