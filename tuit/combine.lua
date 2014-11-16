--- tuit/combine.lua - functional programming

-------------------------------------------------------------------
-- Copyright (C) 2013-2014 TAGA Yoshitaka <tagga@tsuda.ac.jp>
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use, copy,
-- modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-------------------------------------------------------------------

tuit = tuit or {}
tuit.combine = tuit.combine or {}

--[[--

tuit.combine
============

NAME
----

tuit.combine - functions for functional programming

SYNOPSIS
--------

     m = require "tuit.combine"
     print(m.fix(function () return m.const(9) end)(3)) -- 9

DESCRIPTION
-----------

This module provides utility functions for functional programming.

--]]--
---tap
-- m = assert(require 'tuit.combine')
-- plan()

local M = tuit.combine

table.unpack = table.unpack or unpack

--[[--

### high-order functions ###

* `m.comp(f1, f2, ..., fn)` - composition  
  This function makes a composite function of `f1, f2, ..., fn`,
  which takes a single argument `x` and returns `f1(f2(...fn(x)))`.
--]]--
---tap
-- g1 = function (x) return x + 3 end
-- g2 = function (x) return x * 2 end
-- is(m.comp(g1, g2)(5), 5 * 2 + 3)
-- is(m.comp(g2, g1)(5), (5 + 3) * 2)
function M.comp(...)
   local funcs = {...}
   return function (x)
	     local r = x
	     for i = #funcs, 1, -1 do
		r = funcs[i](r)
	     end
	     return r
	  end
end

--[[--
* `m.curry(f, [n])` - Currying  
  Given function `f` of type (X&times;Y&rarr;Z), this function
  make a single argument function of type X&rarr;(Y&rarr;Z).
  `m.curry(f, n)` applies the Currying `n` times.
--]]--
---tap
-- g = function (x, y) return x - y end
-- is(m.curry(g)(1)(2), 1 - 2)
-- is(m.curry(g)(2)(1), 2 - 1)
function M.curry(f, n)
   n = n or 1
   if n <= 1 then
      return function (x)
		return function (...)
			  return f(x, table.unpack{...})
		       end
	     end
   else
      return function (x)
		return M.curry(M.curry(f)(x), n - 1)
	     end
   end
end

--[[--
* `m.part(f, ...)` -  partial application  
   This function fixes the first arguments and makes another function of
   smaller arity.
--]]--
---tap
-- g = function (x, y) return x - y end
-- is(m.part(g, 2)(3), 2 - 3)
function M.part(f, ...)
   local seeds = {...}
   return function (...)
	     local args = {...}
	     for i = #seeds, 1, -1 do
		table.insert(args, 1, seeds[i])
	     end
	     return f(table.unpack(args))
	  end
end

--[[--
* `m.neg(pred)` - complementation  
   This function makes a negated version of predicative function `pred`.
--]]--
---tap
-- g = function (x, y) return x > y end
-- is(m.neg(g)(1, 2), not(g(1, 2)))
-- is(m.neg(g)(1, 1), not(g(1, 1)))
-- is(m.neg(g)(1, 0), not(g(1, 0)))
function M.neg(pred)
   return function (...)
	     return not pred(...)
	  end
end
--[[--
* `m.memoize(f)` - memoization  
   This function makes a memoized version of function `f`.
--]]--
---tap
-- a = 0
-- g1 = function (x) a = a + 1; return a end
-- g2 = m.memoize(g1)
-- is(g2(1), 1)
-- is(g1(1), 2)
-- is(g2(1), 1)
function M.memoize(f)
   local d = {}
   setmetatable(d, {__mode = "kv"})
   return function (...)
	     local s = {...}
	     local k = table.concat(s, ';')
	     local r = d[k]
	     if r == nil then
		r = f(table.unpack(s))
		d[k] = r
	     end
	     return r
	  end
end

--[[--

### combinators ###

* `m.fix(f)` -- fix point combinator  
   This function return a function which computes a fix-point of `f`.
--]]--
---tap
-- g = function (x) return function (y) return 3 end end
-- is(m.fix(g)(4), 3)
function M.fix(f)
   return function (x)
	     return f(M.fix(f))(x)
	  end
end

--[[--
* `m.flip(f)` - C combinator  
   This function returns a function which takes two arguments in reverse
   order of `f`.
--]]--
---tap
-- g = function (x, y) return x - y end
-- is(m.flip(g)(1, 2), 2 - 1)
function M.flip(proc)
   return function (x, y)
	     return proc(y, x)
	  end
end
--[[--
* `m.const(x)` -  K combinator  
   This function returns a function which always returns `x`.
--]]--
---tap
-- g = m.const(5)
-- is(g(2), 5)
-- is(g(0), 5)
function M.const(x)
   return function (y)
	     return x
	  end
end

--[[--

### utility functions ###

* `m.null(x)` -  null?  
   This function checks if the argument is `nil`.
--]]--
---tap
-- is(m.null(nil), true)
-- is(m.null(false), false)
function M.null(x)
   return x == nil
end

--[[--
* `m.id(x)` - the identity function  
   This function returns the argument itself.
--]]--
---tap
-- is(m.id(3), 3)
-- is(m.id(false), false)
function M.id(x)
   return x
end

--[[--

### wrappers of Lua operators ###

* `m.add(x, y)` - `x + y`
--]]--
---tap
-- is(m.add(2, 3), 2 + 3)
function M.add(x, y) return x + y end

--[[--
* `m.sub(x, y)` - `x - y`
--]]--
---tap
-- is(m.sub(2, 3), 2 - 3)
function M.sub(x, y) return x - y end

--[[--
* `m.mul(x, y)` - `x * y`
--]]--
---tap
-- is(m.mul(2, 3), 2 * 3)
function M.mul(x, y) return x * y end

--[[--
* `m.div(x, y)` - `x / y`
--]]--
---tap
-- is(m.div(2, 3), 2 / 3)
function M.div(x, y) return x / y end

--[[--
* `m.mod(x, y)` - `x % y`
--]]--
---tap
-- is(m.mod(2, 3), 2 % 3)
function M.mod(x, y) return x % y end

--[[--
* `m.pow(x, y)` - `x ^ y`
--]]--
---tap
-- is(m.pow(2, 3), 2 ^ 3)
function M.pow(x, y) return x ^ y end

--[[--
* `m.unm(x)` - `- x`
--]]--
---tap
-- is(m.unm(2), - 2)
function M.unm(x) return - x end

--[[--
* `m.concat(x, y)` - `x .. y`
--]]--
---tap
-- is(m.concat("abc", "de"), "abc" .. "de")
--]]--
function M.concat(x, y) return x .. y end

--[[--
* `m.len(x)` - `#x`
--]]--
---tap
-- is(m.len("abc"), #"abc")
-- is(m.len({1, 2}), #{1, 2})
function M.len(x) return #(x) end

--[[--
* `m.eq(x, y)>`- `x == y`
--]]--
---tap
-- is(m.eq(1, 2), 1 == 2)
-- is(m.eq(1, 1), 1 == 1)
-- is(m.eq(1, 0), 1 == 0)
function M.eq(x, y) return x == y end

--[[--
* `m.lt(x, y)` - `x < y`
--]]--
---tap
-- is(m.lt(1, 2), 1 < 2)
-- is(m.lt(1, 1), 1 < 1)
-- is(m.lt(1, 0), 1 < 0)
function M.lt(x, y) return x < y end

--[[--
* `m.le(x, y)` - `x <= y`
--]]--
---tap
-- is(m.le(1, 2), 1 <= 2)
-- is(m.le(1, 1), 1 <= 1)
-- is(m.le(1, 0), 1 <= 0)
function M.le(x, y) return x <= y end

--[[--
* `m.gt(x, y)` - `x > y`
--]]--
---tap
-- is(m.gt(1, 2), 1 > 2)
-- is(m.gt(1, 1), 1 > 1)
-- is(m.gt(1, 0), 1 > 0)
function M.gt(x, y) return x > y end

--[[--
* `m.ge(x, y)` - `x >= y`
--]]--
---tap
-- is(m.ge(1, 2), 1 >= 2)
-- is(m.ge(1, 1), 1 >= 1)
-- is(m.ge(1, 0), 1 >= 0)
function M.ge(x, y) return x >= y end

--[[--
* `m.index(x, y)` - `x[y]`
--]]--
---tap
-- a = {1, 2, 3}
-- is(m.index(a, 0), a[0])
-- is(m.index(a, 1), a[1])
-- is(m.index(a, 3), a[3])
-- is(m.index(a, 4), a[4])
function M.index(x, y) return x[y] end

--[[--
* `m.call(f, ...)` - `f(...)`
--]]--
---tap
-- g = function (x, y) return x .. ":" .. y end
-- is(m.call(g, 'a', 'b'), g('a', 'b'))
function M.call(f, ...) return f(...) end

--[[--

AUTHOR
------

TAGA Yoshitaka

--]]--
return M
--- tuit/combine.lua ends here
