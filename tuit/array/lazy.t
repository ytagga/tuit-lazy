--- tap script - -*- mode:lua -*-
require "tuit.tap"
local t = loadstring [=====[
m = assert(require 'tuit.array.lazy')
plan(11)
y = 0
x = m.bless(function (t, n) y = y + 1; return y end)
isa(x, 'table')
is(x[1], 1)
is(x[2], 2)
is(x[1], 1)
is_deeply(m.unfold(
            function (x) return false end,
            function (x) return x[#x] + x[#x-1] end,
            function (x) return x end,
            {1, 1}):take(5),
            {1, 1, 2, 3, 5})
is_deeply(m.unfold(string.gmatch("a b c", "(%S+)")), {'a', 'b', 'c'})
is_deeply(m.range(1, math.huge):take(5), {1, 2, 3, 4, 5})
is_deeply(m.range(1, math.huge):map(function (x) return x * 2 end):take(5), {2, 4, 6, 8, 10})
is_deeply(m.range(1, math.huge):filter(function (x) return x % 2 == 0 end):take(5), {2, 4, 6, 8, 10})
is_deeply(m.range(1, math.huge):drop(3):take(5), {4, 5, 6, 7, 8})
is_deeply(m.range(1, math.huge):drop_while(function (x) return x < 3 end):take(5), {3, 4, 5, 6, 7})
]=====]
if t == nil then
  skip_all("broken test script")
end
local f, v = pcall(t)
if not(f) then
   bail_out(v)
end
os.exit(tuit.tap.not_ok)
