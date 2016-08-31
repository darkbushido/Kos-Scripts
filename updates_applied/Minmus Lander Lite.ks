LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
DOWNLOAD("mission/lander.ks").
MOVEPATH("mission/lander.ks", "startup.ks").
set mission to lex(
  "PitchExp", 0.35,
  "Body", "Minmus",
  "Altitude", 25000,
  "Lat", 27.7,
  "Lng", -212.9
).
writejson(mission, "mission.json").
