function free_return_correction {
  set ct to time:seconds + eta:periapsis.
  local data is list(0).
  set data to hillclimb["seek"](data, fitness["c_per_fit"](ct, kerbin, 30000), 10).
  set data to hillclimb["seek"](data, fitness["c_per_fit"](ct, kerbin, 30000), 1).
  set data to hillclimb["seek"](data, fitness["c_per_fit"](ct, kerbin, 30000), 0.1).
  local nn to nextnode.
  if nn:deltav:mag < 0.1 remove nn.
  else node_exec["exec"](true).
  next().
}
