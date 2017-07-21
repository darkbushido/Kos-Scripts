{
  local f is "1:/runmode.ks".
  export({
    parameter d.
    local r is 0.
    local s is list().
    local sn is list().
    local e is lex().
    if exists(f) {
      set r to import("runmode.ks").
      print "Runmode: " + r.
    }
    local n is{
      parameter m is r+1.
      if not exists(f) create(f).
      local h is open(f).
      h:clear().
      h:write("export("+m+").").
      set r to m.
      print "Runmode: " + r + " - " + sn[r].
    }.
    d(s,sn,e,n).
    return{
      until r>=s:length{s[r]().
        for k in e:keys e[k]().
        wait 0.
      }
    }.
  }).
}
