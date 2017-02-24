LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/moon_land_at.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.2475,
  "TransTarget", Mun,
  "LandLatLng", latlng(0,0),
  "RadarOffset", 7.83,
  "Altitude", 15000
).
writejson(params, "params.json").
