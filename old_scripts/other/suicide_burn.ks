function suicide_burn {
  parameter mission.
  parameter params.

  SET Kp TO 0.3. SET Ki TO 0.05. SET Kd TO 0.4.
  SET PID TO PIDLOOP(Kp, Ki, Kd, 0, 1). SET PID:SETPOINT TO ta.

  SET srfspd TO VELOCTY:SURFACE.
  SET sideways TO srfspd * FACING:STARVECTOR. //velocity vector to the right of ship is positive
  SET upways TO srfspd * FACING:UPVECTOR. //velocity vector above ship is positive
  SET hsVec TO VXCL(UP:VECTOR,SRFRETROGRADE:VECTOR):NORMALIZED.
  //LOCK STEERING TO UP:VECTOR + hsVec * <horizontal speed pid>.
}
