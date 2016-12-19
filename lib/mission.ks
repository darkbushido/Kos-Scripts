{
  local f is "1:/runmode.ks".
  export({
    parameter d.
    local r is 0.
    if exists(f)
      set r to import("runmode.ks").
    local s is list().
    local e is lex().
    local n is{
      parameter m is r+1.
      if not exists(f)
        create(f).
      local h is open(f).
      h:clear().
      h:write("export("+m+").").
      set r to m.
      print "Runmode: " +r.
    }.
    d(s,e,n).
    return{
      until r>=s:length{s[r]().
        for k in e:keys e[k]().
        wait 0.
      }
    }.
  }).
}
