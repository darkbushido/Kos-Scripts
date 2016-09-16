LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/rt_network.ks", "1:/startup.ks").
set params to lex(
  "Vessel", vessel("CommSat Mk1-"),
  "Offset", 120 * 2
).
writejson(params, "params.json").
