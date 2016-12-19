LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbin_land_on_target.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.4,
  "LaunchInc", 90,
  "LandLatLng", latlng(90,0)
).
writejson(params, "params.json").
