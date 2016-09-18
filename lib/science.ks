{
  local science is lex(
    "science", collect_science@
  ).
  function highlight_part {
    parameter SM.
    if not SM:HASDATA and not SM:INOPERABLE {
      HIGHLIGHT(P, BLUE).
      return true.
    } else {
      HIGHLIGHT(P, MAGENTA).
      return false.
    }
  }
  function collect_science {
    SET SL to lex(). SET SMS to lex().
    set DMMS to list("ModuleScienceExperiment", "DMModuleScienceAnimate", "DMBathymetry").
    for module_name in DMMS {
      for SM in SHIP:ModulesNamed(module_name) {
        SET P to SM:PART.
        if NOT SMS:HASKEY(P:NAME) {
          if highlight_part(SM) SMS:ADD(P:NAME, LIST(SM)).
        } else if SMS:HASKEY(P:NAME) AND NOT SMS[P:NAME]:CONTAINS(P) {
          if highlight_part(SM) SMS[P:NAME]:ADD(SM).
        }
    }}
    for SM_name in SMS:KEYS {
      SET SM to SMS[SM_name][0].
      if not SM:HASDATA and not SM:INOPERABLE {
        HIGHLIGHT(SM:PART, RED).
        SM:DEPLOY.
        if SMS[SM:PART:NAME]:LENGTH > 1 SMS[SM:PART:NAME]:REMOVE(0).
        else SMS:REMOVE(SM:part:name).
      }
    }
  }
  export(science).
}
