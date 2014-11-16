--- tuit/array.lua - iteration over an array

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
tuit.array = tuit.array or {}

local M = tuit.array
local MT = { __index = M }

table.unpack = table.unpack or unpack

--[[--

tuit.array
==========

NAME
----

tuit.array - iteration over a linear table

SYNOPSIS
--------

     M = require "tuit.array"
     return M.unfold(
              function (x) return #x >= 10 end,
              function (x) return x[#x] + x[#x-1] end,
              function (x) return x end,
              {1, 1}):take(5) -- {1, 1, 2, 3, 5}

DESCRIPTION
-----------

This module provides linear list functions.
Some have a similar one in tuit.list' module,
but the order of the arguments may be different.
The first argument of most functions in this module is a list.

Objectifier and constructors
----------------------------

--]]--
---tap
-- m = assert(require 'tuit.array')
-- plan()
--[[--
* `m.bless(arr)` - tells list `arr` that it should work as `tuit.array` object.
--]]--
---tap
-- is(m.bless{'a', 'b', 'c'}:count(function(x) return true end), 3)
function M.bless(arr)
   arr = arr or {}
   setmetatable(arr, MT)
   return arr
end

--[[--
* `m.unfold([null], kar, [kdr, seed, head]) - is a generic recursive constructor.
The default values of `seed` is `{}`, that of `head` is `seed` or `{}`, that of `kdr` is the identity function, and that of `null` is a constant function that returns `false`.
--]]--
---tap
-- is_deeply(m.unfold(
--             function (x) return #x >= 5 end,
--             function (x) return x[#x] + x[#x-1] end,
--             function (x) return x end,
--             {1, 1}),
--             {1, 1, 2, 3, 5})
-- is_deeply(m.unfold(string.gmatch("a b c", "(%S+)")), {'a', 'b', 'c'})
function M.unfold(pred, kar, kdr, seed, head)
   seed = seed or {}
   if head == nil then
      if type(seed) == 'table' then
	 head = seed
      else
	 head = {}
      end
   end
   M.bless(head)
   kdr = kdr or function (x) return x end
   if kar == nil then
      kar = pred
      pred = function (x) return false end
   end
   local v
   local i = #head
   while not(pred(seed)) do
      v = kar(seed)
      if v == nil then
	 break
      end
      i = i + 1
      head[i] = v
      seed = kdr(seed)
   end
   return head
end
--[[--
* m.range(init, finish, [step]) - returns an array beginning with `init` and ending with `finish`, stepping up or down by `step`.
--]]--
---tap
-- is_deeply(m.range(1, 5), {1, 2, 3, 4, 5})
-- is_deeply(m.range(4, 1), {4, 3, 2, 1})
-- is_deeply(m.range(4, 1, -2), {4, 2})
function M.range(init, finish, step)
   local r = M.bless()
   step = step or 1
   if init > finish then
      if step > 0 then
	 step = - step
      end
   else
      if step < 0 then
	 step = - step
      end
   end
   for i = init, finish, step do
      table.insert(r, i)
   end
   return r
end
--[[--

iterator and accumulator
------------------------

* `arr:ipairs()` - will be used in construction `for`. In Lua 5.2,  this
function is used in the metamethod for the original `ipairs` function.

--]]--
function M.ipairs(arr)
   return coroutine.wrap(
      function ()
	 local i = 0
	 local v
	 while true do
	    i = i + 1
	    v = arr[i]
	    if v == nil then
	       break
	    end
	    coroutine.yield(i, v)
	 end
	 return nil
   end)
end

MT.__ipairs = function (arr) return M.ipairs(arr), arr, 0 end

--[[--
* `arr:fold(proc, left_id)` - iterates procedure `proc` over an acumulator value and the elements of `arr` from left to right, starting with an acumulator value `init`. If `lst` is empty, it returns `init`.
--]]--
---tap
-- is(m.bless{'a', 'b', 'c'}:fold(function (r, x) return r .. x end, 'X'), 'Xabc')
function M.fold(arr, kons, knil)
   local r = knil
   for _, v in M.ipairs(arr) do
      r = kons(r, v)
   end
   return r
end

--[[--

map, filter and selectors
-------------------------

* `arr:map(proc)` - applies `proc` element-wise to the elements of `arr` in order and returns a list of the results.
--]]--
---tap
-- is_deeply(m.bless{1, 2, 3}:map(function (x) return x + 1 end), {2, 3, 4})
function M.map(arr, proc)
   local r = M.bless({})
   for i, v in M.ipairs(arr) do
      r[i] = proc(v)
   end
   return r
end

--[[--
* `arr:filter(pred)` - returns a list of the elements of `arr` that satisfy predicate `pred`.
--]]--
---tap
-- is_deeply(m.bless{1, 2, 3}:filter(function (x) return x % 2 == 0 end), {2})
-- is_deeply(m.bless{1, 2, 3}:filter(function (x) return x % 2 ~= 0 end), {1, 3})
function M.filter(arr, pred)
   local r = M.bless({})
   local j = 1
   for _, v in M.ipairs(arr) do
      if pred(v) then
	 r[j] = v
	 j = j + 1
      end
   end
   return r
end

--[[--
* `arr:each(proc)` - calls procedure `proc` with the elements of `arr` in order.
--]]--
---tap
-- x = ''
-- m.bless{1, 2, 3}:each(function (y) x = x .. y end)
-- is(x, '123')
function M.each(arr, proc)
   for _, v in M.ipairs(arr) do
      proc(v)
   end
end
--[[--
* `arr:each_ipairs(proc)` - calls procedure `proc` with an index and its value of `arr` in order.
--]]--
---tap
-- x = ''
-- m.bless{'a', 'b', 'c'}:each_ipair(function (i, v) x = x .. i .. v end)
-- is(x, '1a2b3c')
function M.each_ipair(arr, proc)
   for i, v in M.ipairs(arr) do
      proc(i, v)
   end
end
--[[--
* `arr:find(pred_or_elt)` - returns the index and the value of the first element of `arr` that is equivalent to or satisfies the first argument.
--]]--
---tap
-- function g(x) return x == 3 end
-- x, y = m.bless{1, 3, 5}:find(g)
-- is(x, 2)
-- is(y, 3)
-- x, y = m.bless{1, 7, 5}:find(g)
-- is(x, false)
-- is(y, nil)
function M.find(arr, x)
   local pred
   if type(x) == 'function' then
      pred = x
   else
      pred = function (y) return x == y end
   end
   for i, v in M.ipairs(arr) do
      if pred(v) then
	 return i, v
      end
   end
   return false
end
--[[--
* `arr:take(n)` - returns an array of the first `n` elements of `arr`.
--]]--
---tap
---tap
-- is_deeply(m.bless{1, 2, 3}:take(2), {1, 2})
function M.take(arr, n)
   local r = M.bless({})
   for i, v in M.ipairs(arr) do
      if i > n then
	 break
      end
      r[i] = v
   end
   return r
end
--[[--
* ``arr:drop(n)` - returns an array of all elements but the first `n`  ones of `arr`.
--]]--
---tap
-- is_deeply(m.bless{1, 3, 5}:drop(1), {3, 5})
function M.drop(arr, n)
   local r = M.bless({})
   local j = 1
   for i, v in M.ipairs(arr) do
      if i > n then
	 r[j] = v
	 j = j + 1
      end
   end
   return r
end
--[[--
* `arr:take_while(pred)` - returns the longest initial sequence of `arr` whose elements all satisfy the predicate `pred`.
--]]--
---tap
-- is_deeply(m.bless{1, 3, 5}:take_while(function (x) return x < 3 end), {1})
function M.take_while(arr, pred)
   local r = M.bless({})
   local j = 1
   for _, v in M.ipairs(arr) do
      if pred(v) then
	 r[j] = v
	 j = j + 1
      else
	 break
      end
   end
   return r
end
--[[--
* `arr:drop_while(pred) - returns an array of all elements but the ones in the longest sequence whose elements all satisfy `pred`.
--]]--
---tap
-- is_deeply(m.bless{1, 3, 5}:drop_while(function (x) return x < 3 end), {3, 5})
function M.drop_while(arr, pred)
   local r = M.bless({})
   local j
   local flag = false
   for _, v in M.ipairs(arr) do
      if flag then
	 j = j + 1
	 r[j] = v
      elseif not pred(v) then
	 flag = true
	 j = 1
	 r[j] = v
      end
   end
   return r
end
--[[--
* `arra:any(pred)` - returns `true` if `pred` returns true on any application, else returns `false`.
--]]--
---tap
-- is(m.bless{1, 2, 3}:any(function (x) return x % 2 == 0 end), true)
-- is(m.bless{1, 2, 3}:any(function (x) return x > 4 end), false)
function M.any(arr, pred)
   for _, v in M.ipairs(arr) do
      if pred(v) then
	 return true
      end
   end
   return false
end
--[[--
* `arr:every(pred)` - returns `true` if `pred` returns true on every application, else returns `false`.
--]]--
---tap
-- is(m.bless{1, 2, 3}:every(function (x) return x % 2 == 0 end), false)
-- is(m.bless{1, 2, 3}:every(function (x) return x < 4 end), true)
function M.every(arr, pred)
   for _, v in M.ipairs(arr) do
      if not pred(v) then
	 return false
      end
   end
   return true
end

--[[--
* `arr:count(pred)` - returns the number of the elements that satisfy `pred`
--]]--
---tap
-- is(m.bless{1, 2, 3, 4, 5}:count(function (x) return x % 2 == 0 end), 2)
function M.count(arr, pred)
   local r = 0
   for _, v in M.ipairs(arr) do
      if pred(v) then
	 r = r + 1
      end
   end
   return r
end
--[[--
* ``arr:last()` - returns the last element of `arr`.
--]]--
---tap
-- is(m.bless{1, 2, 3, 4, 5}:last(), 5)
function M.last(arr)
   local r = nil
   for _, v in M.ipairs(arr) do
      r = v
   end
   return r
end
--[[--

SEE ALSO
========

[tuit.list](list.html)

AUTHOR
======

TAGA Yoshitaka
--]]--

return M
--- tuit/array.lua ends here
