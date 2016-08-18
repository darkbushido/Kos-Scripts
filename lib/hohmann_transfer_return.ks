function hohmann_transfer_return {
  parameter mission.
  parameter params.

  local target_periapsis is 37000.
  // we want a hohmann transfer down to kerbin.
  local r1 to (BODY:OBT:SEMIMAJORAXIS - 1.5*SHIP:OBT:SEMIMAJORAXIS).
  local r2 to (BODY:BODY:RADIUS + target_periapsis ).

  local dv_hx_kerbin is BODY:OBT:VELOCITY:ORBIT:MAG * (sqrt((2*r2)/(r1 + r2)) -1).
  local transfer_time to constant:pi * sqrt((((r1 + r2)^3)/(8*BODY:BODY:MU))).

  local r1 is SHIP:OBT:SEMIMAJORAXIS.
  local r2 is BODY:SOIRADIUS.
  local v2 is dv_hx_kerbin.
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

  // This are the directions relative to the reference
  // prograde direction
  local body_orbit_direction is BODY:ORBIT:VELOCITY:ORBIT:DIRECTION:YAW.
  local ship_orbit_direction is SHIP:ORBIT:VELOCITY:ORBIT:DIRECTION:YAW.

  // launch point:
  local launch_point_dir is (body_orbit_direction - 180 + launch_angle).
  local node_eta is mod((360+ ship_orbit_direction - launch_point_dir),360)/360 * SHIP:OBT:PERIOD.

  local my_node to NODE(time:seconds + node_eta, 0, 0, delta_v).
  ADD my_node.

  // Fine tuning of dV.
  local lock current_peri to ORBITAT(SHIP,time+transfer_time):PERIAPSIS.

  until abs (current_peri - target_periapsis) < 300 {
    if current_peri < target_periapsis {
      set my_node:PROGRADE to my_node:PROGRADE - 0.05.
    } else {
      set my_node:PROGRADE to my_node:PROGRADE + 0.05.
    }
  }

  mission["next"]().
}
