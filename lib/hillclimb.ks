{
  local INFINITY is 2^64.
  local hillclimb is lex(
    "seek", seek@
  ).
  function seek {
    parameter data, fitness_fn, step_size is 1.
    local next_data is best_neighbor(data, fitness_fn, step_size).
    until fitness_fn(next_data) <= fitness_fn(data) {
      set data to next_data.
      set next_data to best_neighbor(data, fitness_fn, step_size).
    }
    return data.
  }
  function best_neighbor {
    parameter data, fitness_fn, step_size.
    local best_fitness is -INFINITY.
    local best is 0.
    for neighbor in neighbors(data, step_size) {
      local fitness is fitness_fn(neighbor).
      if fitness > best_fitness {
        set best to neighbor.
        set best_fitness to fitness.
    }}
    return best.
  }
  function neighbors {
    parameter data, step_size, results is list().
    for i in range(0, data:length) {
      local increment is data:copy.
      local decrement is data:copy.
      set increment[i] to increment[i] + step_size.
      set decrement[i] to decrement[i] - step_size.
      results:add(increment).
      results:add(decrement).
    }
    return results.
  }
  export(hillclimb).
}
