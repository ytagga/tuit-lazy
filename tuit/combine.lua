--- tuit/combine.lua - functional programming

-------------------------------------------------------------------
-- Copyright (C) 2013 TAGA Yoshitaka <tagga@tsuda.ac.jp>
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

---## SYNOPSIS
--     m = require "tuit.combine"
--     print(m.fix(function () return m.const(9) end)(3)) -- 9


---## DESCRIPTION
-- This module provides utility functions for functional programming.

local M = tuit.combine

table.unpack = table.unpack or unpack

---
---### high-order functions
---
---* `m.comp(f1, f2, ..., fn)` - composition<br/>
-- This function makes a composite function of `f1`, `f2`, ..., `fn`,
-- which takes a single argument `x` and returns `f1(f2(...fn(x)))`.
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
---* `m.curry(f, [n])` - Currying<br/>
-- Given function `f` of type (X&times;Y&rarr;Z), this function
-- make a single argument function of type X&rarr;(Y&rarr;Z).
-- `m.curry(f, n)` applies the Currying `n` times.
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
---* `m.part(f, ...)` -  partial application<br/>
-- This function fixes the first arguments and makes another function of
-- smaller arity.
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
---* `m.neg(pred)` - complementation<br/>
-- This function makes a negated version of predicative function `pred`.
function M.neg(pred)
   return function (...)
	     return not pred(...)
	  end
end
---* `m.memozie(f)` - memoization<br/>
-- This function makes a memoized version of function `f`.
function M.memoize(f)
   local d = {}
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

---
---### combinators
---
---* `m.fix(f)` -- fix point combinator<br/>
-- This function return a function which computes a fix-point of `f`.
function M.fix(f)
   return function (x)
	     return f(M.fix(f))(x)
	  end
end

---* `m.flip(f)` - C combinator<br/>
-- This function returns a function which takes two arguments in reverse
-- order of `f`.
function M.flip(proc)
   return function (x, y)
	     return proc(y, x)
	  end
end
---* `m.const(x)` -  K combinator<br/>
-- This function returns a function which always returns `x`.
function M.const(x)
   return function (y)
	     return x
	  end
end

---
---### utility functions
---
---* `m.null(x)` -  null?<br/>
-- This function checks if the argument is `nil`.
function M.null(x)
   return x == nil
end
---* `m.id(x)` - the identity function<br/>
-- This function returns the argument itself.
function M.id(x)
   return x
end
---
---### wrappers of Lua operators
---
---* `m.add(x, y)` - `x + y`
function M.add(x, y) return x + y end
---* `m.sub(x, y)` - `x - y`
function M.sub(x, y) return x - y end
---* `m.mul(x, y)` - `x * y`
function M.mul(x, y) return x * y end
---* `m.div(x, y)` - `x / y`
function M.div(x, y) return x / y end
---* `m.mod(x, y)` - `x % y`
function M.mod(x, y) return x % y end
---* `m.pow(x, y)` - `x ^ y`
function M.pow(x, y) return x ^ y end
---* `m.unm(x)` - `- x`
function M.unm(x) return - x end
---* `m.concat(x, y)` - `x .. y`
function M.concat(x, y) return x .. y end
---* `m.len(x)` - `#x`
function M.len(x) return #(x) end
---* `m.eq(x, y)` - `x == y`
function M.eq(x, y) return x == y end
---* `m.lt(x, y)` - `x < y`
function M.lt(x, y) return x < y end
---* `m.le(x, y)` - `x <= y`
function M.le(x, y) return x <= y end
---* `m.gt(x, y)` - `x > y`
function M.gt(x, y) return x > y end
---* `m.ge(x, y)` - `x >= y`
function M.ge(x, y) return x >= y end
---* `m.index(x, y)` - `x[y]`
function M.index(x, y) return x[y] end
---* `m.calld(f, ...)` - `f(...)`
function M.call(f, ...) return f(...) end


return M
--- tuit/combine.lua ends here
