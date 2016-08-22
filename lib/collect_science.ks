SET SL to lexicon().
SET SMS to lexicon().
set last_runtime to 0.
set DMMS to list("ModuleScienceExperiment", "DMModuleScienceAnimate", "DMBathymetry").
for module_name in DMMS {
  for SM in SHIP:ModulesNamed(module_name) {
    SET P to SM:PART.
    if NOT SMS:HASKEY(P:NAME)
      SMS:ADD(P:NAME, LIST(SM)).
    else if SMS:HASKEY(P:NAME) AND NOT SMS[P:NAME]:CONTAINS(P)
      SMS[P:NAME]:ADD(SM).
    HIGHLIGHT(P, BLUE).
  }
}

function collect_science {
  parameter mission.
  // parameter params.
  if warp = 0 {
    set round_time to FLOOR(TIME:SECOND).
    if (MOD(round_time, 5) = 0) AND NOT (last_runtime = round_time)  {
      set last_runtime to round_time.
      for SM_name in SMS:KEYS {
        SET SM to SMS[SM_name][0].
        HIGHLIGHT(SM:PART, GREEN).
        if SM:HASDATA
          science_value(SM).
        else if NOT SM:INOPERABLE
          SM:DEPLOY.
      }
    }
  }
}

function science_value {
  parameter SM.
  local title to SM:data[0]:title.
  local uid to SM:PART:UID.
  if  SM:DATA[0]:SCIENCEVALUE > 0 {
    if SL:HASVALUE(title) AND NOT SL:HASKEY(uid) {
      reset_science().
    } else if NOT SL:HASVALUE(title) AND NOT SL:HASKEY(uid) {
      print SM:data[0]:title.
      HIGHLIGHT(SM:PART, RED).
      PRINT "Saving Science: " + uid + " " + title.
      SL:ADD(uid, title).
      if ADDONS:RT:HASKSCCONNECTION(SHIP) and SM:RERUNNABLE and NOT DMMS:CONTAINS(SM:NAME)
        SM:transmit.
      else if SMS[SM:PART:NAME]:LENGTH > 1
        SMS[SM:PART:NAME]:REMOVE(0).
      else if (not SM:RERUNNABLE) OR  SM:INOPERABLE
        SMS:REMOVE(SM:part:name).
      else
        PRINT "OH SHIT WHATS GOING ON? " + title.
    }
  } else {
    reset_science().
  }
}

function reset_science {
  if list("DMModuleScienceAnimate"):CONTAINS(SM:NAME)
    reset_dmagic_science(SM).
  else
    SM:RESET.
}

function reset_dmagic_science {
  parameter SM.
  set a to SM:ALLACTIONS:ITERATOR.
  a:next.
  UNTIL a:value:contains("reset") { a:next. }
  set ss to a:value:find("reset").
  set es to (a:value:findat(", is", ss) - ss).
  set action to a:value:substring(ss, es).
  SM:doaction(action, true).
}
