--- tuit/list.lua - list library
----------------------------------------------------------
-- Copyright (C) 2013-2014 TAGA Yoshitaka <tagga@tsuda.ac.jp>

-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use, copy,
-- modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
----------------------------------------------------------
tuit = tuit or {}
tuit.list = tuit.list or {}

local M = tuit.list
table.unpack = table.unpack or unpack

--[[--

NAME
====

tuit.list - list library

SYNOPSIS
========

     m = require "tuit.list"
     r = m.equal({1, 2, {3}}, {1, 2, {3}}) -- true


DESCRIPTION
===========

This module provides Scheme-like list functions.
Some functions have functions of the same name
in `tuit.array` and `tuit.array.lazy` modules,
but the order of the arguments may be different.

--]]--
---tap
-- m = eval[[require 'tuit.list']] or skip_all()
--[[--
constructors
------------

* `m.list(obj1, obj2, ...)` - returns a newly allocated list of its arguments.
--]]--
---tap
-- is_deeply(m.list(), {})
-- is_deeply(m.list(1, 2, 3), {1, 2, 3})
function M.list(...)
   local r = {...}
   return r
end

--[[--
* `m.make_list(n, [fill])` - returns an `n`-element list,
whose elements are all the value `fill`.
If the `fill` argument is not given,
the elements of the list may be arbitrary values, but may not be `nil`.
--]]--
---tap
-- is_deeply(m.make_list(3, 'a'), {'a', 'a', 'a'})
function M.make_list(n, fill)
   fill = fill or true
   local r = {}
   for i = 1, n do
      table.insert(r, fill)
   end
   return r
end
--[[--
* `m.list_tabulate(n, proc)` - returns an `n`-element list.
Element `i` of the list, where `1 < i <= n`, is produced by `proc(i)`.
--]]--
---tap
-- g = function (i) return 2 * i end
-- is_deeply(m.list_tabulate(3, g), {2, 4, 6})
function M.list_tabulate(n, proc)
   local r = {}
   for i = 1, n do
      table.insert(r, proc(i))
   end
   return r
end
--[[--
* `m.list_copy(list)` - copies the spine of the argument.
--]]--
---tap
-- a = {1, 2, 3}
-- is_deeply(m.list_copy(a), {1, 2, 3})
-- isnt(m.list_copy(a), a)
function M.list_copy(a)
   local r = {}
   for i, v in ipairs(a) do
      r[i] = v
   end
   return r
end
--[[--
* `m.iota(n, [init, step])` - returns a list of
`{init, init + step, ..., init + (n - 1) * step}`.
--]]--
---tap
-- is_deeply(m.iota(3), {0, 1, 2})
-- is_deeply(m.iota(3, 1), {1, 2, 3})
-- is_deeply(m.iota(3, 1, 2), {1, 3, 5})
function M.iota(n, init, step)
   init = init or 0
   step = step or 1
   local k = init
   local r = {}
   for i = 1, n do
      r[i] = k
      k = k + step
   end
   return r
end

--[[--

predicates
----------

* `m.equal(x, y)` - returns `true` if and only if `a` and `b` are recursively
equivalent.
--]]--
---tap
-- ok(m.equal(1, 1))
-- ok(m.equal({{1, 2}, {3}}, {{1, 2}, {3}}))
-- ok(m.equal({0, {1, 2}}, {0, {1, 2}}))
function M.equal(a, b)
   if type(a) ~= 'table' or type(b) ~= 'table' then
      return a == b
   elseif #a ~= #b then
      return false
   else
      for i = 1, #a do
	 if not M.equal(a[i], b[i]) then
	    return false
	 end
      end
      return true
   end
end
--[[--
* `m.list_eq(eq, x, ...)` - 
--]]--
---tap
-- g = function (a, b) return a == b end
-- ok(m.list_eq(g))
-- ok(m.list_eq(g, {1}))
-- ok(m.list_eq(g, {1, 2}, {1, 2}, {1, 2}))

local function list_eq2(eq, a, b)
   if #a ~= #b then
      return false
   end
   for i = 1, #a do
      if not(eq(a[i], b[i])) then
	 return false
      end
   end
   return true
end
function M.list_eq(eq, ...)
   local x = {...}
   for i = 2, #x do
      if not list_eq2(eq, x[i-1], x[i]) then
	 return false
      end
   end
   return true
end

--[[--

selectors
---------

function M.append(...)
   local r = {}
   for _, v in ipairs{...} do
      for _, w in ipairs(v) do
	 table.insert(r, w)
      end
   end
   return r
end

function M.zip(...)
   local all = {...}
   local r = {}
   local n = math.huge
   local x
   for j, v in ipairs(all) do
      x = #v
      if x < n then
	 n = x
      end
   end
   for i = 1, n do
      r[i] = {}
      for j, v in ipairs(all) do
	 r[i][j] = v[i]
      end
   end
   return r
end


local function flat(x, r)
   if type(x) == 'table' then
      for i, v in ipairs(x) do
	 flat(v, r)
      end
   else
      table.insert(r, x)
   end
end

function M.flatten(x)
   local r = {}
   flat(x, r)
   return r
end

--[[--

AUTHOR
======

TAGA Yoshitaka

--]]--
return M
--- tuit/list.lua ends here
