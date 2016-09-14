LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/science_body_flyby.ks", "1:/startup.ks").
set mission to lex(
  "PitchExp", 0.35,
  "Body", "Mun",
  "Altitude", 15000
).
writejson(mission, "mission.json").
