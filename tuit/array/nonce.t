--- tap script - -*- mode:lua -*-
require "tuit.tap"
local t = loadstring [=====[
m = assert(require 'tuit.array.nonce')
plan(4)
y = 0
x = m.bless(m, function (t, n) y = y + 1; return y end)
isa(x, 'table')
is(x[1], 1)
is(x[2], 2)
is(x[1], 3)
]=====]
if t == nil then
  skip_all("broken test script")
end
local f, v = pcall(t)
if not(f) then
   bail_out(v)
end
os.exit(tuit.tap.not_ok)
