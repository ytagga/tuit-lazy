--- tap script - -*- mode:lua -*-
require "tuit.tap"
local t = loadstring [=====[
m = assert(require 'tuit.combine')
plan(49)
g1 = function (x) return x + 3 end
g2 = function (x) return x * 2 end
is(m.comp(g1, g2)(5), 5 * 2 + 3)
is(m.comp(g2, g1)(5), (5 + 3) * 2)
g = function (x, y) return x - y end
is(m.curry(g)(1)(2), 1 - 2)
is(m.curry(g)(2)(1), 2 - 1)
g = function (x, y) return x - y end
is(m.part(g, 2)(3), 2 - 3)
g = function (x, y) return x > y end
is(m.neg(g)(1, 2), not(g(1, 2)))
is(m.neg(g)(1, 1), not(g(1, 1)))
is(m.neg(g)(1, 0), not(g(1, 0)))
a = 0
g1 = function (x) a = a + 1; return a end
g2 = m.memoize(g1)
is(g2(1), 1)
is(g1(1), 2)
is(g2(1), 1)
g = function (x) return function (y) return 3 end end
is(m.fix(g)(4), 3)
g = function (x, y) return x - y end
is(m.flip(g)(1, 2), 2 - 1)
g = m.const(5)
is(g(2), 5)
is(g(0), 5)
is(m.null(nil), true)
is(m.null(false), false)
is(m.id(3), 3)
is(m.id(false), false)
is(m.add(2, 3), 2 + 3)
is(m.sub(2, 3), 2 - 3)
is(m.mul(2, 3), 2 * 3)
is(m.div(2, 3), 2 / 3)
is(m.mod(2, 3), 2 % 3)
is(m.pow(2, 3), 2 ^ 3)
is(m.unm(2), - 2)
is(m.concat("abc", "de"), "abc" .. "de")
is(m.len("abc"), #"abc")
is(m.len({1, 2}), #{1, 2})
is(m.eq(1, 2), 1 == 2)
is(m.eq(1, 1), 1 == 1)
is(m.eq(1, 0), 1 == 0)
is(m.lt(1, 2), 1 < 2)
is(m.lt(1, 1), 1 < 1)
is(m.lt(1, 0), 1 < 0)
is(m.le(1, 2), 1 <= 2)
is(m.le(1, 1), 1 <= 1)
is(m.le(1, 0), 1 <= 0)
is(m.gt(1, 2), 1 > 2)
is(m.gt(1, 1), 1 > 1)
is(m.gt(1, 0), 1 > 0)
is(m.ge(1, 2), 1 >= 2)
is(m.ge(1, 1), 1 >= 1)
is(m.ge(1, 0), 1 >= 0)
a = {1, 2, 3}
is(m.index(a, 0), a[0])
is(m.index(a, 1), a[1])
is(m.index(a, 3), a[3])
is(m.index(a, 4), a[4])
g = function (x, y) return x .. ":" .. y end
is(m.call(g, 'a', 'b'), g('a', 'b'))
]=====]
if t == nil then
  skip_all("broken test script")
end
local f, v = pcall(t)
if not(f) then
   bail_out(v)
end
os.exit(tuit.tap.not_ok)
