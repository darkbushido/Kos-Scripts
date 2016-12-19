LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbin_power_land_on_target.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.3,

  "CareAboutLan", false,
  "RadarOffset", 4.6,
  "LandLatLng", latlng(-17.5,50)
).
writejson(params, "params.json").
