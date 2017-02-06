LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/remote_tech_moon_network.ks", "1:/startup.ks").
set params to lex(
  "SwitchToShp", "CommSat Mun",
  "LaunchAlt", 1000000,
  "Vessel", "CommSat Mun-Sat-1",
  "Offset", 120 * 1
).
writejson(params, "params.json").
