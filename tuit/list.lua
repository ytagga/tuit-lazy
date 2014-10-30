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

This module provides linear list functions.
Some have a similar one in tuit.array' module,
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
* `m.unfold(null, kar, kdr, seed, [head])` - is a generic recursive
constructor.  If `kar` never returns `nil`, this is equivalent to
the following funtion:

       function m.unfold(null, kar, kdr, seed, head)
         if null(seed) then
           return head
         else
           table.insert(head, kar(seed))
           return m.unfold(null, kar, kdr, kdr(seed), head)
         end
       end

The actual implementation ends the list if `null(seed)` is true
or if `kar(seed)` returns `nil`. If `head` is omitted, `{}` is used
instead.
--]]--
---tap
-- y = {1, 1}
-- is_deeply(m.unfold(function (x) return #x >= 5 end,
--                    function (x) return x[#x-1] + x[#x] end,
--                    function (x) return x end,
--                    y, y), {1, 1, 2, 3, 5})
function M.unfold(null, kar, kdr, seed, head)
   head = head or {}
   local v
   while not(null(seed)) do
      v = kar(seed)
      if v == nil then
	 break
      end
      table.insert(head, v)
      seed = kdr(seed)
   end
   return head
end

--[[--

`fold` and other acumulator functions
-------------------------------------

* `m.fold_left(proc, init. lst1, ...)` - iterates function `proc` over an acumulator value and the elements of lists `lst1`, ... from left to right, starting with an acumulator value `init`. If `lst` is empty, it returns `init`.
--]]--
---tap
-- is(m.fold_left(function (x, y) return x + y end, 0, {1, 2, 3}), 6)
-- is(m.fold_left(function (x, y) return x .. y end, "A", {}), "A")
-- is(m.fold_left(function (x, y, z) return x + y - z end, 0, {1, 2, 3}, {4, 5, 6}), -9)
function M.fold_left(proc, init, ...)
   local r = init
   for _, v in ipairs(M.zip(...)) do
      r = proc(r, table.unpack(v))
   end
   return r
end

--[[--
* `m.fold_right(proc, init. lst1, ...)` - iterates function `proc` over an acumulator value and the elements of list `lst1`, ... from right to left, starting with an acumulator value `init`. If `lst` is empty, it returns `init`.
--]]--
---tap
-- is(m.fold_right(function (x, y) return x + y end, 0, {1, 2, 3}), 6)
-- is(m.fold_right(function (x, y) return x .. y end, "A", {}), "A")
-- is(m.fold_right(function (x, y, z) return x + y - z end, 0, {1, 2, 3}, {4, 5, 6}), 7)
function M.fold_right(proc, init, ...)
   local r = init
   local lst = M.zip(...)
   for i = #lst, 1, -1 do
      table.insert(lst[i], r)
      r = proc(table.unpack(lst[i]))
   end
   return r
end
--[[--
* `m.reduce_left(proc, lst)`  - iterates function `proc` over an acumulator value and the elements of list `lst` from left to right, starting with the first element of `lst`.
--]]--
---tap
-- is(m.reduce(function (x, y) return x + y end, {1, 2, 3}), 6)
-- is(m.reduce(function (x, y) return x .. y end, {}), nil)
-- is(m.reduce(function (x, y) return x .. y end, {'A', 'B'}), 'AB')
function M.reduce(proc, lst)
   local r = lst[1]
   for i = 2, #lst do
      r = proc(r, lst[i])
   end
   return r
end
--[[--
* `m.reduce_right(proc, lst)` - iterates function `proc` over an acumulator value and the elements of list `lst` from right to left, starting with the last element of `lst`.
--]]--
---tap
-- is(m.reduce_right(function (x, y) return x + y end, {1, 2, 3}), 6)
-- is(m.reduce_right(function (x, y) return x .. y end, {}), nil)
-- is(m.reduce_right(function (x, y) return x .. y end, {'A', 'B'}), 'AB')
function M.reduce_right(proc, lst)
   local r = lst[#lst]
   for i = #lst - 1, 1, -1 do
      r = proc(lst[i], r)
   end
   return r
end

--[[--

map, filter, and selectors
--------------------------

* `m.map(proc, lst1, lst2, ...)` - applies `proc` element-wise to the elements of the lists and returns a list of the results, in order.
--]]--
---tap
-- is_deeply(m.map(function (x, y, z) return x + y - z end, {1, 2}, {3, 4}, {5, 6}), {-1, 0})
function M.map(proc, ...)
   local r = {}
   for _, v in ipairs(M.zip(...)) do
      table.insert(r, proc(table.unpack(v)))
   end
   return r
end

--[[--
* `m.filter(pred, lst)` - returns a list of the elements of `lst` that satisfy predicate `pred`.
--]]--
---tap
-- is_deeply(m.filter(function (x) return x % 2 == 0 end, {1, 2, 3, 4}), {2, 4})
function M.filter(pred, lst)
   local r = {}
   for _, v in ipairs(lst) do
      if pred(v) then
	 table.insert(r, v)
      end
   end
   return r
end

--[[--
* `m.find(pred_or_elt, lst)` - returns the index and the value of the first element of list `lst` that is equivalent to or satisfies the first argument.
--]]--
---tap
-- function g(x) return x == 3 end
-- x, y = m.find(g, {1, 3, 5})
-- is(x, 2)
-- is(y, 3)
-- x, y = m.find(g, {1, 7, 5})
-- is(x, false)
-- is(y, nil)
--]]--
function M.find(x, lst)
   local pred
   if type(x) == 'function' then
      pred = x
   else
      pred = function (y) return x == y end
   end

   for i, v in ipairs(lst) do
      if pred(v) then
	 return i, v
      end
   end
   return false
end
--[[--

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
* `m.drop(lst, i)`  - removes the first `i` elements from list `lst`.
--]]--
---tap
-- x = {1, 2, 3}
-- y = m.drop(x, 2)
-- is_deeply(y, {3})
-- is(y, x)
function M.drop(lst, i)
   for k = 1, i do
      table.remove(lst, 1)
   end
   return lst
end

--[[--

* `m.erase(pred_or_elt, lst)` - deletes all the elements in list `lst` that are equivalent to or satisfy the first argument.

--]]--
function M.erase(x, lst)
   local pred
   if type(x) == 'function' then
      pred = x
   else
      pred = function (y) return y == x end
   end
   local i = 1
   while i <= #lst do
      if pred(lst[i]) then
	 table.remove(lst, i)
      else
	 i = i + 1
      end
   end
   return lst
end

--[[--
* `m.take_while(pred, lst)` - returns the longest initial sequence of list `lst` whose elements all satisfy the predicate `pred`.
--]]--
---tap
-- is_deeply(m.take_while(function (x) return x < 3 end, {1, 3, 5}), {1})
function M.take_while(pred, lst)
   local r = {}
   for _, v in ipairs(lst) do
      if not(pred(v)) then
	 break
      end
      table.insert(r, v)
   end
   return r
end

--[[--
* `m.drop_while(pred, lst)` - removes the longest initial sequence of list `lst` whose elements all satisfy the predicate `pred`.
--]]--
---tap
-- is_deeply(m.drop_while(function (x) return x <= 3 end, {1, 3, 5}), {5})
function M.drop_while(pred, lst)
   while #lst > 0 and pred(lst[1]) do
      table.remove(lst, 1)
   end
   return lst
end
--[[--
* `m.any(pred, lst1, ...)` - 
--]]--
---tap
-- is(m.any(function (x) return x == 2 end, {1, 2, 3}), true)
-- is(m.any(function (x) return x == 2 end, {1, 3, 5}), false)
function M.any(pred, ...)
   for _, v in ipairs(M.zip(...)) do
      if M.apply(pred, v) then
	 return true
      end
   end
   return false
end
--[[--
* `m.every(pred, lst1, ...)`
--]]--
---tap
-- is(m.every(function (x) return x == 2 end, {2, 2, 2}), true)
-- is(m.every(function (x) return x == 2 end, {2, 1, 2}), false)
function M.every(pred, ...)
   for _, v in ipairs(M.zip(...)) do
      if not(M.apply(pred, v)) then
	 return false
      end
   end
   return true
end


--[[--

miscellaneous
-------------

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

* `m.apply(proc, lst)` applies procedure `proc` to a list of arguments `lst`.
--]]--
---tap
-- g = function (x, y) return x - y end
-- is(m.apply(g, {1, 2}), -1)
function M.apply(proc, lst)
   return proc(table.unpack(lst))
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
* `m.length(lst)` - return the length of list `lst`.
--]]--
---tap
-- is(m.length({0, 1, 2}), 3)
function M.length(lst)
   return #lst
end

--[[--
* `m.append(lst1, lst2)` - appends the elements of list `lst2` to list `lst1`.
--]]--
---tap
-- is_deeply(m.append({1, 2, 3}, {4}), {1, 2, 3, 4})
function M.append(x, y)
   for _, v in ipairs(y) do
      table.insert(x, v)
   end
   return x
end
--[[--
* `m.reverse(lst)` - reverses the order of list `lst`.
--]]--
---tap
-- is_deeply(m.reverse({1, 2, 3}), {3, 2, 1})
-- is_deeply(m.reverse({1, 2, 3, 4}), {4, 3, 2, 1})
-- x = {1, 2, 3}
-- y = m.reverse(x)
-- is_deeply(y, {3, 2, 1})
-- is(y, x)
function M.reverse(r)
   local k
   for i = 1, #r / 2 do
      k = #r - i + 1
      r[i], r[k] = r[k], r[i]
   end
   return r
end
--[[--
* `m.zip(lst1, lst2, ...)` - With `n` lists, it returns a list
as long as the shortest of these lists,
each element of which is an `n`-element list comprised of
the corresponding elements from the parameter lists.
--]]--
---tap
-- is_deeply(m.zip({1, 2, 3}, {4, 5, 6}), {{1, 4}, {2, 5}, {3, 6}})
local function minlen(all)
   local n = math.huge
   local x
   for _, v in ipairs(all) do
      x = #v
      if x < n then
	 n = x
      end
   end
   if n == math.huge then
      n = 0
   end
   return n
end
function M.zip(...)
   local all = {...}
   local r = {}
   local n = minlen(all)
   local x
   for i = 1, n do
      x = {}
      r[i] = x
      for j, v in ipairs(all) do
	 x[j] = v[i]
      end
   end
   return r
end

--[[--
* `m.flatten(lst)` - flattens list `lst`.
--]]--
---tap
-- is_deeply(m.flatten({1, {2}, {{3}, 4}}), {1, 2, 3, 4})
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
