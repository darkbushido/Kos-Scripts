LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbin_power_land_on_target.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.3,
  "RadarOffset", 4.01,
  "LandLatLng", latlng(-0.097,-74.557)
).
writejson(params, "params.json").
