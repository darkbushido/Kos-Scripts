{
  local dock is lex(
    "translate", translate@,
    "get_port", get_port@,
    "approach", approach@
  ).
  function init_pids {
    parameter s is 1.
    set pid_fore to pidloop(5,0.5,5,-s,s).
    set pid_top  to pidloop(5,0.5,5,-s,s).
    set pid_star to pidloop(5,0.5,5,-s,s).

    set pid_speed_fore to pidloop(1,5,0,-1,1).
    set pid_speed_top  to pidloop(1,5,0,-1,1).
    set pid_speed_star to pidloop(1,5,0,-1,1).
  }
  function translate {
    parameter vector.
    if vector:mag > 1 set vector to vector:normalized.
    set ship:control:starboard  to vector * ship:facing:starvector.
    set ship:control:fore       to vector * ship:facing:forevector.
    set ship:control:top        to vector * ship:facing:topvector.
  }
  function get_port {
    parameter trgtv, type is "any".
    local dports to list().
    for port in trgtv:dockingports {
      if port:state = "ready" and ( type = "any" or port:name = type ) dports:add(port).
    }
    local closestp to dports[0].
    for port in dports { if port:nodeposition:mag < closestp:nodeposition:mag set closestp to port. }
    return closestp.
  }
  function approach {
    parameter tp, dp, distance is 150, speed is 1.
    init_pids(speed).
    rcs off. sas off.
    dp:controlfrom().
    lock steering to lookdirup(-tp:portfacing:vector, tp:portfacing:upvector).
    wait until vang(dp:facing:vector, -tp:portfacing:vector) < 1.

    lock dist_off to tp:portfacing:vector * distance.
    lock app_v to tp:nodeposition - dp:nodeposition + dist_off.
    lock rel_v to ship:velocity:orbit - tp:ship:velocity:orbit.

    lock star_error to  -1*vdot(dp:facing:starvector,app_v).
    lock top_error to   -1*vdot(dp:facing:topvector,app_v).
    lock fore_error to  -1*vdot(dp:facing:vector,app_v).

    rcs on.
    until false {
      lock steering to lookdirup(-tp:portfacing:vector, tp:portfacing:upvector).
      set vd_trgt_p_facing to vecdraw(tp:position,(tp:portfacing:vector)*20,white,"target port",1,true,0.2).
      set vd_app_vec to vecdraw(dp:nodeposition,app_v,magenta,"target spot",1,true,0.2).
      set vd_fore to vecdraw(dp:position,dp:facing:vector*10,red,"fore",1.0,true,0.2).
      set vd_top to vecdraw(dp:position,dp:facing:topvector*10,blue,"top",1.0,true,0.2).
      set vd_star to vecdraw(dp:position,dp:facing:starvector*10,green,"star",1.0,true,0.2).

      set pid_speed_fore:setpoint to pid_fore:update(time:seconds,fore_error).
      set pid_speed_top:setpoint  to pid_top:update(time:seconds,top_error).
      set pid_speed_star:setpoint to pid_star:update(time:seconds,star_error).
      set ship:control:fore       to pid_speed_fore:update(time:seconds, rel_v * ship:facing:forevector).
      set ship:control:top        to pid_speed_top:update(time:seconds, rel_v * ship:facing:topvector).
      set ship:control:starboard  to pid_speed_star:update(time:seconds, rel_v * ship:facing:starvector).

       print "sf: " + rp(pid_speed_fore:setpoint) + " st: " + rp(pid_speed_top:setpoint) + " ss: " + rp(pid_speed_star:setpoint) +
       " cf: " + rp(ship:control:fore) + " ct: " + rp(ship:control:top) + " cs: "+ rp(ship:control:starboard).
      if app_v:mag < 0.1 break.
      wait 0.1.
    }
    until rel_v:mag < 0.1 {
      translate(-1 * rel_v).
    }
    translate(v(0,0,0)).
    rcs off.
    clearvecdraws().
  }
  function rp { parameter i, rnd is 3, pr is 6. return round(i,rnd):tostring:padright(pr). }
  export(dock).
}
