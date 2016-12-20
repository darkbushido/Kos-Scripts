LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbin_power_land_on_target.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.3,
  "RadarOffset", 4.14,
  "LandLatLng", latlng(-0.0972127658787422, -74.5576065845002)
).
writejson(params, "params.json").
