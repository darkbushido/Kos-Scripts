{
  local math_gaussian is lex(
    "gaussian",gaussian@,
    "gaussian2",gaussian2@
  ).
  // Value, Target, Width
  function gaussian { parameter v, t, w. return constant:e^(-1 * (v-t)^2 / (2*w^2)). }
  function gaussian2 {
    parameter v1, t1, w1, v2, t2, w2.
    return round(constant:e^(-1 * ((v1-t1)^2 / (2*w1^2) + (v2-t2)^2 / (2*w2^2))), 10).
  }
  export(math_gaussian).
}
