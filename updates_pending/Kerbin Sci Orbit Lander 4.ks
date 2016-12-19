LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbin_land_on_target.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.375,
  "LandLatLng", latlng(-80,10)
).
writejson(params, "params.json").
