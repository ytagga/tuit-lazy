-- tuit/combin.t -*- mode:lua -*-

plan(49)

f = eval[[require 'tuit.combine']] or skip_all()

-- wrapper functions of Lua operators
is(f.add(2, 3), 2 + 3)
is(f.sub(2, 3), 2 - 3)
is(f.mul(2, 3), 2 * 3)
is(f.div(2, 3), 2 / 3)
is(f.mod(2, 3), 2 % 3)
is(f.pow(2, 3), 2 ^ 3)
is(f.unm(2), - 2)
is(f.concat("abc", "de"), "abc" .. "de")

is(f.len("abc"), #"abc")
is(f.len({1, 2}), #{1, 2})
is(f.eq(1, 2), 1 == 2)
is(f.eq(1, 1), 1 == 1)
is(f.eq(1, 0), 1 == 0)
is(f.lt(1, 2), 1 < 2)
is(f.lt(1, 1), 1 < 1)
is(f.lt(1, 0), 1 < 0)
is(f.le(1, 2), 1 <= 2)
is(f.le(1, 1), 1 <= 1)
is(f.le(1, 0), 1 <= 0)
is(f.gt(1, 2), 1 > 2)
is(f.gt(1, 1), 1 > 1)
is(f.gt(1, 0), 1 > 0)
is(f.ge(1, 2), 1 >= 2)
is(f.ge(1, 1), 1 >= 1)
is(f.ge(1, 0), 1 >= 0)

a = {1, 2, 3}
is(f.index(a, 0), a[0])
is(f.index(a, 1), a[1])
is(f.index(a, 3), a[3])
is(f.index(a, 4), a[4])

f1 = function (x, y) return x .. ":" .. y end
is(f.call(f1, 'a', 'b'), f1('a', 'b'))

-- memoize
a = 0
f2 = function (x) a = a + 1; return a end
f3 = f2
f2 = f.memoize(f2)
is(f2(1), 1)
is(f2(1), 1)
is(f3(1), 2)


-- partial application
is(f.part(f.add, 2)(3), 2 + 3)

-- complement
is(f.neg(f.gt)(1, 2), not(f.gt(1, 2)))
is(f.neg(f.gt)(1, 1), not(f.gt(1, 1)))
is(f.neg(f.gt)(1, 0), not(f.gt(1, 0)))

-- null?
is(f.null(nil), true)
is(f.null(false), false)

-- identity
is(f.id(3), 3)
is(f.id(false), false)

-- K combinator
f4 = f.const(5)
is(f4(2), 5)
is(f4(0), 5)

-- C combinator
is(f.flip(f.sub)(1, 2), 2 - 1)

-- composition
f5 = f.part(f.add, 3)
f6 = f.part(f.mul, 2)
is(f.comp(f5, f6)(5), 5 * 2 + 3)
is(f.comp(f6, f5)(5), (5 + 3) * 2)

-- Currying
is(f.curry(f.sub)(1)(2), 1 - 2)
is(f.curry(f.sub)(2)(1), 2 - 1)

-- fix-point
is(f.fix(function () return f.const(3) end)(4), 3)

--
summary()
--- tuit/combine.t ends here
