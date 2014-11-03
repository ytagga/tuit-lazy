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

NAME
====

tuit.array - iteration over a linear table

SYNOPSIS
========

     m = require "tuit.array"

DESCRIPTION
===========

This module provides linear list functions.
Some have a similar one in tuit.list' module,
but the order of the arguments may be different.
The first argument of most functions are a list.

objectifier and constructors
----------------------------

--]]--
---tap
-- m = eval[[require 'tuit.array']] or skip_all()

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
* `head:unfold([null], kar, [kdr, seed]) - is a generic recursive constructor.
The default values of `seed` is `head`, that of `kdr` is the identity function,
and that of `null` is a constant function that returns `false`.
--]]--
---tap
-- is_deeply(m.bless{1, 1}:unfold(
--             function (x) return #x >= 5 end,
--             function (x) return x[#x] + x[#x-1] end,
--             function (x) return x end),
--             {1, 1, 2, 3, 5})
-- is_deeply(m.bless():unfold(string.gmatch("a b c", "(%S+)")), {'a', 'b', 'c'})
function M.unfold(head, pred, kar, kdr, seed)
   seed = seed or head
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
* head:range(init, finish, [step]) - 
--]]--
---tap
-- is_deeply(m.bless():range(1, 5), {1, 2, 3, 4, 5})
-- is_deeply(m.bless():range(4, 1), {4, 3, 2, 1})
-- is_deeply(m.bless():range(4, 1, -2), {4, 2})
function M.range(head, init, finish, step)
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
   return M.unfold(head,
		   function (x)
		      if step > 0 then
			 return x > finish
		      else
			 return x < finish
		      end
		   end,
		   function (x) return x end,
		   function (x) return x + step end,
		   init)
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


function M.copy(arr)
   local r = M.bless({})
   for i, v in M.ipairs(arr) do
      r[i] = v
   end
   return r
end


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

function M.last(arr)
   local r = nil
   for _, v in M.ipairs(arr) do
      r = v
   end
   return r
end

function M.count(arr, pred)
   local r = 0
   for _, v in M.ipairs(arr) do
      if pred(v) then
	 r = r + 1
      end
   end
   return r
end



function M.any(arr, pred)
   for _, v in M.ipairs(arr) do
      if pred(v) then
	 return true
      end
   end
   return false
end

function M.every(arr, pred)
   for _, v in M.ipairs(arr) do
      if not pred(v) then
	 return false
      end
   end
   return true
end







function M.takewhile(arr, pred)
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

function M.dropwhile(arr, pred)
   local r = M.bless({})
   local j = 2
   local flag = false
   for _, v in M.ipairs(arr) do
      if flag then
	 r[j] = v
	 j = j + 1
      elseif not pred(v) then
	 flag = true
	 r[1] = v
      end
   end
   return r
end

--[[--

SEE ALSO
========

[tuit.list](list.html)

AUTHOR
======

TAGA Yoshitaka.
--]]--

return M
--- tuit/array.lua ends here
