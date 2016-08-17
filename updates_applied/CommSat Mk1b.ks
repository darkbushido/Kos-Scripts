LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
DOWNLOAD("mission/rt_network.ks").
MOVEPATH("mission/rt_network.ks", "startup.ks").
set mission to lex(
  "PitchExp", 0.35,
  "Vessal", "CommSat mk1",
  "Offset", 90 * 2
).
writejson(mission, "mission.json").
