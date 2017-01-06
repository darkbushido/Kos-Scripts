{
  local hillclimb is lex(
    "seek", seek@
  ).
  local fitness_lookup is lex().
  function seek {
    parameter d, f_fn, ss is 1.
    local nd is best_n(d, f_fn, ss).
    until f_fn(nd) <= f_fn(d) { set d to nd. set nd to best_n(d, f_fn, ss). }
    return d.
  }
  function best_n {
    parameter d, f_fn, ss.
    local best_fitness is -2^64.
    local best is 0. local ch to false.
    for n in ns(d, ss) {
      set ch to false.
      local n_key to hash_key(n).
      if fitness_lookup:haskey(n_key) { set fitness to fitness_lookup[n_key]. set ch to true. }
      else { set fitness to f_fn(n). fitness_lookup:add(n_key, fitness).}
      print_log(n, fitness, ch).
      if fitness > best_fitness { set best to n. set best_fitness to fitness.}
    }
    return best.
  }
  function ns {
    parameter d, ss, r is list().
    for i in range(0, d:length) { local ic is d:copy. local dc is d:copy. set ic[i] to ic[i] + ss. set dc[i] to dc[i] - ss. r:add(ic). r:add(dc). }
    return r.
  }
  function hash_key { parameter n, s is "-", str is "". for n in n { set str to str + n + s.} return str. }
  function rtsp { parameter n, r, p. return round(n,r):tostring:padleft(p). }
  function print_log {
    parameter n, fitness, ch is false.
    if n:length = 4 {
      local d to list(rtsp(n[0],1,8),rtsp(n[1],1,5),rtsp(n[2],1,5),rtsp(n[3],1,5)).
      print "T: " + d[0] + " R: " + d[1] + " N: " + d[2] + " P: " + d[3] + " Fit: " + round(fitness,14):tostring:padright(16) + " CH: " + ch.
    } else if n:length = 3 {
      local d to list(rtsp(n[0],1,5),rtsp(n[1],1,5),rtsp(n[2],1,5)).
      print "R: " + d[0] + " N: " + d[1] + " P: " + d[2] + " Fit: " + round(fitness,14):tostring:padright(16) + " CH: " + ch.
    } else {
      local str to "".
      for n in n { set str to str + (round(n, 8)):tostring:padright(10). }
      print str + " Fit: " + fitness + " CH: " + ch.
    }
  }
  export(hillclimb).
}
