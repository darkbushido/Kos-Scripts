{
  local s is stack().
  local d is lex().
  global import is{
    parameter n.
    s:push(n).
    if not exists("1:/"+n)
      copypath("0:/"+n,"1:/"+n).
    runpath("1:/"+n).
    return d[n].
  }.
  global export is{
    parameter v.
    set d[s:pop()] to v.
  }.
}
