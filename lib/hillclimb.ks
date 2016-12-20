{
  local hillclimb is lex(
    "seek", seek@
  ).
  local fitness_lookup is lex().
  function seek {
    parameter d, f_fn, ss is 1.
    local nd is best_neighbor(d, f_fn, ss).
    until f_fn(nd) <= f_fn(d) {
      set d to nd.
      set nd to best_neighbor(d, f_fn, ss).
    }
    return d.
  }
  function best_neighbor {
    parameter d, f_fn, ss.
    local best_fitness is -2^64.
    local best is 0.
    for neighbor in neighbors(d, ss) {
      local neighbor_key to neighbor[0] + "-" + neighbor[1] + "-" + neighbor[2] + "-" + neighbor[3].
      local ch to false.
      if fitness_lookup:haskey(neighbor_key) {
        set ch to true.
        set fitness to fitness_lookup[neighbor_key].
      } else {
        set fitness to f_fn(neighbor).
        fitness_lookup:add(neighbor_key, fitness).
      }
      print_log(neighbor, fitness, ch).
      if fitness > best_fitness {
        set best to neighbor.
        set best_fitness to fitness.
    }}
    return best.
  }
  function print_log {
    parameter neighbor, fitness, ch.
    if neighbor:length = 4 {
      local logt to round(neighbor[0],1):tostring:padleft(8).
      local logr to round(neighbor[1],1):tostring:padleft(4).
      local logn to round(neighbor[2],1):tostring:padleft(4).
      local logp to round(neighbor[3],1):tostring:padleft(6).
      print "T: " + logt + " R: " + logr + " N: " + logn + " P: " + logp + " Fit: " + round(fitness,8):tostring:padright(6) + " CH: " + ch.
    }
  }

  function neighbors {
    parameter d, ss, r is list().
    for i in range(0, d:length) {
      local ic is d:copy.
      local dc is d:copy.
      set ic[i] to ic[i] + ss.
      set dc[i] to dc[i] - ss.
      r:add(ic).
      r:add(dc).
    }
    return r.
  }
  export(hillclimb).
}
