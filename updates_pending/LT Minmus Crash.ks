LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_crash_at.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.31,
  "TransBody", "Minmus",
  "TransInc", 0,
  "LandLatLng", latlng(-31.5445,-148.2345)
).
writejson(params, "params.json").
