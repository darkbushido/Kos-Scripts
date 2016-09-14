LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/science_body_lander.ks", "1:/startup.ks").
set mission to lex(
  "PitchExp", 0.35,
  "Body", "Minmus",
  "Altitude", 15000,
  "Lat", 0,
  "Lng", 0
).
writejson(mission, "mission.json").
