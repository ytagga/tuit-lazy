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
   return {...}
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
   return {table.unpack(a)}
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
* `m.list_eq(eq, x, ...)` - determines list equality with `eq` predicate procedure.
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

* `m.take(lst, i)` - returns a list of the first `i` elements of list `lst`.
--]]--
---tap
-- is_deeply(m.take({1, 2, 3}, 2), {1, 2})
function M.take(lst, i)
   local r = {}
   for k = 1, i do
      table.insert(r, lst[k])
   end
   return r
end

--[[--
* `m.drop(lst, i)` - returns a list of all but the first `i` elements of list `lst`.
--]]--
---tap
-- is_deeply(m.drop({1, 2, 3}, 2), {3})
function M.drop(lst, i)
   local r = {}
   for k = i + 1, #lst do
      table.insert(r, lst[k])
   end
   return r
end
--[[--
* `m.take_right(lst, i)` - returns a list of the last `i` elements of list `lst`.
--]]--
---tap
-- is_deeply(m.take_right({1, 2, 3}, 2), {2, 3})
function M.take_right(lst, i)
   local r = {}
   for k = #lst - i + 1, #lst do
      table.insert(r, lst[k])
   end
   return r
end
--[[--
* `m.drop_right(lst, i)` - returns a list of all but the last `i` elements of list `lst`.
--]]--
--tap
-- is_deeply(m.drop_right({1, 2, 3}, 2), {1})
function M.drop_right(lst, i)
   local r = {}
   for k = 1, #lst - i do
      table.insert(r, lst[k])
   end
   return r
end
--[[--
* `m.take_q(lst, i)` - removes all but the first `i` elements from list `lst`.
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.take_q(x, 2)
-- is_deeply(y, {1, 2})
-- is(y, x)
function M.take_q(lst, i)
   for k = i + 1, #lst do
      lst[k] = nil
   end
   return lst
end
--[[--
* `m.take_right_q(lst, i)` - removes all but the last `i` elements from list `lst`.
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.take_right_q(x, 2)
-- is_deeply(y, {2, 3})
-- is(y, x)
function M.take_right_q(lst, i)
   for k = i + 1, #lst do
      table.remove(lst, 1)
   end
   return lst
end
--[[--
* `m.drop_q(lst, i)`  - removes the first `i` elements from list `lst`.
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.drop_q(x, 2)
-- is_deeply(y, {3})
-- is(y, x)
function M.drop_q(lst, i)
   for k = 1, i do
      table.remove(lst, 1)
   end
   return lst
end
--[[--
* `m.drop_right_q(lst, i)` - removes the last `i` elements from lst `lst`.
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.drop_right_q(x, 2)
-- is_deeply(y, {1})
-- is(y, x)
function M.drop_right_q(lst, i)
   for k = #lst - i + 1, #lst do
      lst[k] = nil
   end
   return lst
end

--[[--
* `m.split_at(lst, i)` - returns m.take(lst, i) and m.drop(lst, i)
--]]--
---tap
-- x, y = m.split_at({1, 2, 3}, 2)
-- is_deeply(x, {1, 2})
-- is_deeply(y, {3})
function M.split_at(lst, i)
   return M.take(lst, i), M.drop(lst, i)
end
--[[--
* `m.split_at_q(lst, i)` - returns m.take(lst, i) and m.drop_q(lst, i)
--]]--
---tap
-- z = {1, 2, 3}
-- x, y = m.split_at_q(z, 2)
-- is_deeply(x, {1, 2})
-- is_deeply(y, {3})
-- is(y, z)
function M.split_at_q(lst, i)
   return M.take(lst, i), M.drop_q(lst, i)
end
--[[--
* `m.last(lst)` - return the last element of list `lst`.
--]]--
---tap
-- is(m.last({1, 2, 3}), 3)
function M.last(lst)
   return lst[#lst]
end

--[[--
* m.first(lst)` - returns the first element of list `lst`.
--]]--
---tap
-- is(m.first({1, 2, 3}), 1)
function M.first(lst)
   return lst[1]
end
--[[--

miscellaneous
-------------

* `m.apply(proc, lst)` applies procedure `proc` to a list of arguments `lst`.
--]]--
---tap
-- g = function (x, y) return x - y end
-- is(m.apply(g, {1, 2}), -1)
function M.apply(proc, lst)
   return proc(table.unpack(lst))
end
--[[--
* `m.length(lst)` - return the length of list `lst`.
--]]--
---tap
-- is(m.length({0, 1, 2}), 3)
function M.length(lst)
   return #lst
end

--[[--
* `m.append(lst1, lst2, ...)` - returns a list consisting of the elements of lst1 followed by the elements of the other list parameters.
--]]--
---tap
-- is_deeply(m.append({1, 2, 3}, {4}, {5, 6}), {1, 2, 3, 4, 5, 6})
function M.append(lst, ...)
   return M.append_q({table.unpack(lst)}, ...)
end
--[[--
* `m.append_q(lst1, lst2, ...)` - adds the elements of the other list parameters  to list `lst1` .
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.append_q(x, {4}, {5, 6})
-- is_deeply(y, {1, 2, 3, 4, 5, 6})
-- is(y, x)
function M.append_q(lst, ...)
   for _, v in ipairs{...} do
      for _, w in ipairs(v) do
	 table.insert(lst, w)
      end
   end
   return lst
end
--[[--
* `m.concatinate(list_of_lists)` -- appends all element lists of `list_of_lists`.
--]]--
---tap
-- is_deeply(m.concatinate({{1, 2, 3}, {4}, {5, 6}}), {1, 2, 3, 4, 5, 6})
function M.concatinate(lst)
   return M.append(table.unpack(lst))
end
--[[--
* `m.concatinate_q(list_of_lists)` - appends all other element lists of `list_of_lists` to the first element list.
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.concatinate_q({x, {4}, {5, 6}})
-- is_deeply(y, {1, 2, 3, 4, 5, 6})
-- is(y, x)
function M.concatinate_q(lst)
   return M.append_q(table.unpack(lst))
end
--[[--
* `m.reverse(lst)` - returns a newly allocated list consisting of the elements of `lst` in reverse order.
--]]--
---tap
-- is_deeply(m.reverse({1, 2, 3}), {3, 2, 1})
-- is_deeply(m.reverse({1, 2, 3, 4}), {4, 3, 2, 1})
function M.reverse(lst)
   return M.reverse_q({table.unpack(lst)})
end
--[[--
* `m.reverse_q(lst)` - reverses the order of list `lst`.
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.reverse_q(x)
-- is_deeply(y, {3, 2, 1})
-- is(y, x)
function M.reverse_q(r)
   local k
   for i = 1, #r / 2 do
      k = #r - i + 1
      r[i], r[k] = r[k], r[i]
   end
   return r
end
--[[--
* `m.append_reverse(rev_head, tail)`
* `m.append_reverse_q(rev_head, tail)`
* `m.zip(lst1, lst2, ...)`
--]]--
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
--[[--
* `m.unzip1(lst)`
* `m.unzip2(lst)`
* `m.unzip3(lst)`
* `m.unzip4(lst)`
* `m.unzip5(lst)`

fold, unfold, & map
-----------------------

* `m.fold(kons, knil, lst1, lst2, ...)`
* `m.fold_right(kons, knil, lst1, lst2, ...)`
* `m.reduce(f, ridentity, lst)`
* `m.unfold(pred, kar, kdr, seed, [tail_gen])`
* `m.unfold_right(pred, kar, kdr, seed, [tail_gen])`
* `m.map(proc, lst1, lst2, ...)`

--]]--
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
