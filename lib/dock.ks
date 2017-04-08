{
  local dock is lex(
    "translate", translate@,
    "get_port", get_port@,
    "approach", approach@,
    "sideswipe", sideswipe@
  ).
  function translate {
    parameter vector.
    if vector:mag > 1 set vector to vector:normalized.
    set ship:control:starboard  to vector * ship:facing:starvector.
    set ship:control:fore       to vector * ship:facing:forevector.
    set ship:control:top        to vector * ship:facing:topvector.
  }

  function get_port {
    parameter trgtv.
    for port in trgtv:dockingports { if port:state = "Ready" return port.}
  }
  function approach {
    parameter tp, dp, distance, speed.
    lock dist_off to tp:portfacing:vector * distance.
    lock avec to tp:nodeposition - dp:nodeposition + dist_off.
    lock rv to ship:velocity:orbit - tp:ship:velocity:orbit.
    lock steering to lookdirup(-tp:portfacing:vector, tp:portfacing:upvector).
    until dp:state <> "Ready" {
      translate((avec:normalized * speed) - rv).
      local dvec is (tp:nodeposition - dp:nodeposition).
      if vang(dp:portfacing:vector, dvec) < 2 and abs(distance - dvec:mag) < 0.1
        break.
      wait 0.01.
    }
    translate(v(0,0,0)).
  }
  function sideswipe {
    parameter tp, dp, distance, speed.
    dp:controlfrom().
    lock sd to tp:ship:facing:starvector.
    if abs(sd * tp:portfacing:vector) = 1 {
      lock sd to tp:ship:facing:topvector.
    }
    lock dist_off to sd * distance.
    if (tp:nodeposition - dp:nodeposition + do):mag <
       (tp:nodeposition - dp:nodeposition - do):mag {
      lock do to (-sd) * distance.
    }
    lock avec to tp:nodeposition - dp:nodeposition + do.
    lock rv to ship:velocity:orbit - tp:ship:velocity:orbit.
    lock steering to -1 * tp:portfacing:vector.
    until avec:mag < 0.1  {
      translate((avec:normalized * speed) - rv).
      wait 0.01.
    }
    translate(v(0,0,0)).
  }

  export(dock).
}
