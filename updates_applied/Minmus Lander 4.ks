LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
DOWNLOAD("mission/science_body_lander.ks").
MOVEPATH("mission/science_body_lander.ks", "startup.ks").
set mission to lex(
  "PitchExp", 0.35,
  "Body", "Minmus",
  "Altitude", 15000,
  "Lat", 0,
  "Lng", 0
).
writejson(mission, "mission.json").
