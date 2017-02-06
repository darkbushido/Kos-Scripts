{
  local science is lex( "collect", collect_science@, "transfer", transfer_science@ ).
  function highlight_part {
    parameter SP, SM.
    if not SM:HASDATA and not SM:INOPERABLE { HIGHLIGHT(SP, BLUE). return true. }
    else if SM:HASDATA { HIGHLIGHT(SP, GREEN). }
    else { HIGHLIGHT(SP, YELLOW). return false. }
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
      print "Collecting Science From: "+SM_name.
      if  SM_name = "dmUSPresTemp" {for SM in SMS[SM_name] { do_science(SM). }}
      else { SET SM to SMS[SM_name][0]. do_science(SM).}
    }
    wait 5.
    transfer_science().
    wait 5.
  }
  function do_science {
    parameter SM.
    if not SM:HASDATA and not SM:INOPERABLE {
      local t to time:seconds.
      HIGHLIGHT(SM:PART, RED). SM:DEPLOY.
      until (SM:HASDATA or (time:seconds > t+10)) {
        print ".". wait 1.
      }
  }}
  function transfer_science {
    for sc in ship:modulesnamed("ModuleScienceContainer") {
      print "Transfering Science".
      sc:doaction("collect all", true).
      wait 0.
    }
  }
  export(science).
}
