{
  local science is lex( "collect", collect_science@, "transfer", transfer_science@ ).
  function highlight_part {
    parameter SP, SM.
    if not SM:HASDATA and not SM:INOPERABLE { HIGHLIGHT(SP, BLUE). return true. }
    else { HIGHLIGHT(SP, MAGENTA). return false. }
  }
  function collect_science {
    local SL to lex(). local SMS to lex().
    local DMMS to list("ModuleScienceExperiment", "DMModuleScienceAnimate", "DMBathymetry").
    for module_name in DMMS {
      for SM in SHIP:ModulesNamed(module_name) {
        local SP to SM:PART.
        if NOT SMS:HASKEY(SP:NAME) {
          if highlight_part(SP, SM) SMS:ADD(SP:NAME, LIST(SM)).
        } else if SMS:HASKEY(SP:NAME) AND NOT SMS[SP:NAME]:CONTAINS(SP) {
          if highlight_part(SP, SM) SMS[SP:NAME]:ADD(SM).
        }
    }}
    for SM_name in SMS:KEYS {
      SET SM to SMS[SM_name][0].
      if not SM:HASDATA and not SM:INOPERABLE {
        HIGHLIGHT(SM:PART, RED). SM:DEPLOY.
        if SMS[SM:PART:NAME]:LENGTH > 1 SMS[SM:PART:NAME]:REMOVE(0).
        else SMS:REMOVE(SM:part:name).
      }
    }
    transfer_science().
  }
  function transfer_science {
    for sc in ship:modulesnamed("ModuleScienceContainer") {
      sc:doaction("collect all", true).
    }
  }
  export(science).
}
