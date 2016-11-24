function set_inc_lan {
  node_set_inc_lan["create_node"](p["Body"]:obt:inclination, p["Body"]:obt:lan).
  node_exec["exec"](true).
  next().
}
