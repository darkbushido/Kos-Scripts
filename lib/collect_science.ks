function collect_science {
  parameter mission.
  parameter params.

  local P TO SHIP:PARTSNAMED("SensorThermometer")[0].
  local M TO P:GETMODULE("ModuleScienceExperiment").
  M:DEPLOY.
  print "Thermometer Complete".
  wait 1.

  local P TO SHIP:PARTSNAMED("science.module")[0].
  local M TO P:GETMODULE("ModuleScienceExperiment").
  M:DEPLOY.
  print "Science Container Complete".
  wait 1.

  local P TO SHIP:PARTSNAMED("GooExperiment")[0].
  local M TO P:GETMODULE("ModuleScienceExperiment").
  M:DEPLOY.
  print "Goo Container Complete".
  wait 1.

  mission["next"]().
}
