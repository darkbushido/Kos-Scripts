LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
DOWNLOAD("mission/science_body_flyby.ks").
MOVEPATH("mission/science_body_flyby.ks", "startup.ks").
set mission to lex(
  "PitchExp", 0.35,
  "Target", minmus,
  "Body", "Minmus",
  "Altitude", 15000
).
writejson(mission, "mission.json").
