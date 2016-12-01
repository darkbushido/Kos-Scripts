LIST FILES IN fileList.
for file in fileList {
  if NOT LIST("boot", "update.ks"):CONTAINS(file:name) {
    DELETEPATH(file).
  }
}
COPYPATH("0:/mission/launch_and_return.ks", "1:/startup.ks").
set params to lex(
  "OrbitPE", 30000
).
writejson(params, "params.json").
