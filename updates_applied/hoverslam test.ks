LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/hoverslam.ks", "1:/startup.ks").
set params to lex(
  "RadarOffset", 4.01,
  "LandHSMOD", 1
).
writejson(params, "params.json").
