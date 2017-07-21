LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/kerbin_land_on_target.ks", "1:/startup.ks").
set params to lex(
  "LaunchPitchExp", 0.4,
  "LaunchGTAlt", 1000,
  "LandRAlt", 30000,
  // Kerbin Badlands?
  "LandLat", -6.69991665842456,
  "LandLng", 46.2574576786025
).
writejson(params, "params.json").
