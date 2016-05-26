// Mission Runner v0.1.0
// Kevin Gisi
// http://youtube.com/gisikw
// mission["add_event"](name, delegate@) -> add an event to the loop
// mission["remove_event"](name) -> remove the event from the loop
// mission["next"]() -> complete the current runmode
// mission["switch_to"](name) -> switch to a named runmode
// mission["runmode"]() -> get the current runmode name
// mission["terminate"]() -> end the event loop
{
  function mission_runner {
    parameter sequence, events is lex().
    local runmode is 0. local mission_done is 0.
    local mission is lex(
      "add_event", add_event@,
      "remove_event", remove_event@,
      "next", next@,
      "switch_to", switch_to@,
      "runmode", report_runmode@,
      "terminate", terminate@
    ).
    if core:volume:exists("current_runmode.ks") {
      run current_runmode.
      update_runmode(n).
    }

    display_runmodes_and_events.

    until mission_done {
      if sequence[runmode]:HASKEY("Params") {
        sequence[runmode]["Function"](mission, sequence[runmode]["Params"]).
      } else {
        sequence[runmode]["Function"](mission, lex()).
      }

      for event in events:values event(mission).
      wait 0.01.
    }
    if core:volume:exists("current_runmode.ks")
      core:volume:delete("current_runmode.ks").

    function update_runmode {
      parameter n.
      if not core:volume:exists("current_runmode.ks")
        core:volume:create("current_runmode.ks").
      local file is core:volume:open("current_runmode.ks").
      file:clear().
      file:write("set n to " + n + ".").

      display_runmodes_and_events.
      set runmode to n.
    }

    function indexof {
      parameter _list, item. local i is 0.
      for el in _list {
        if el["Title"] = item return i.
        set i to i + 1.
      }
      return -1.
    }

    function add_event {
      parameter name, delegate.
      set events[name] to delegate.
      display_runmodes_and_events.
    }
    function remove_event {
      parameter name.
      events:remove(name).
      display_runmodes_and_events.
    }
    function next {

      update_runmode(runmode + 1).
    }
    function switch_to {
      parameter name.
      update_runmode(indexof(sequence, name)).
    }

    function report_runmode {
      return sequence[runmode].
    }

    function display_runmodes_and_events {
      set i to 0.
      clearscreen.
      print "Mission Runmodes " + runmode.
      until i >= sequence:LENGTH {
        if i = runmode {
          print "=>" + sequence[i]["Title"].
        } else {
          print "  " + sequence[i]["Title"].
        }
        set i to i + 1.
      }
      print "Mission Events".
      for e in events:KEYS {
        print "  " + e.
      }
      print "===== ===== ===== ===== ===== =====".
    }

    // Allow explicit termination of the event loop
    function terminate {
      display_runmodes_and_events.
      set mission_done to 1.
    }
  }

  global run_mission is mission_runner@.
}
