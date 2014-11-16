--- tuit/array/lazy.lua - iteration over a lazy-evaluated array

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

require "tuit.array"

tuit.array.lazy = tuit.array.lazy or {}
setmetatable(tuit.array.lazy, { __index = tuit.array})

table.unpack = table.unpack or unpack

local M = tuit.array.lazy

M.class = M
M.newindex = nil

---tap
-- m = assert(require 'tuit.array.lazy')
-- plan()
-- y = 0
-- x = m.bless(function (t, n) y = y + 1; return y end)
-- isa(x, 'table')
-- is(x[1], 1)
-- is(x[2], 2)
-- is(x[1], 1)

function M.bless(obj, idxf, tab)
   if type(obj) == 'function' then
      tab = idxf
      idxf = obj
      obj = M
   end
   tab = tab or {}
   if idxf then
      local v
      local f = function (t, n)
		   if type(n) == "string" then
		      return M[n]
		   else
		      v = idxf(t, n)
		      t[n] = v
		      return v
		   end
		end
      setmetatable(tab, { __index = f, __newindex = obj.newindex })
   else
      setmetatable(tab, { __index = obj.class, __newindex = obj.newindex  })
   end
   return tab
end

local function unfolder(pred, kar, kdr, seed, head)
   local v
   local i = 0
   return coroutine.wrap(
      function ()
	 while i < #head do
	    i = i + 1
	    coroutine.yield(head[i])
	 end
	 while not(pred(seed)) do
	    v = kar(seed)
	    if v == nil then
	       break
	    end
	    i = i + 1
	    head[i] = v
	    coroutine.yield(v)
	    seed = kdr(seed)
	 end
	 return nil
      end
   )
end

local function unfold_indexer(pred, kar, kdr, seed, head)
   seed = seed or {}
   if head == nil then
      if type(seed) == 'table' then
	 head = seed
      else
	 head = {}
      end
   end
   kdr = kdr or function (x) return x end
   if kar == nil then
      kar = pred
      pred = function (x) return false end
   end
   local i = 0
   local f = unfolder(pred, kar, kdr, seed, head)
   local v = true
   return function (t, n)
	     if i > n then
		return head[n]
	     else
		while i < n and v do
		   i = i + 1
		   v = f()
		   head[i] = v
		end
		return v
	     end
	  end, head
end

--[[--
--]]--
---tap
-- is_deeply(m.unfold(
--             function (x) return false end,
--             function (x) return x[#x] + x[#x-1] end,
--             function (x) return x end,
--             {1, 1}):take(5),
--             {1, 1, 2, 3, 5})
-- is_deeply(m.unfold(string.gmatch("a b c", "(%S+)")), {'a', 'b', 'c'})
function M.unfold(pred, kar, kdr, seed, head)
   return M.bless(unfold_indexer(pred, kar, kdr, seed, head))
end
--[[--
--]]--
---tap
-- is_deeply(m.range(1, math.huge):take(5), {1, 2, 3, 4, 5})
function M.range(init, finish, step)
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
   local v
   return M.bless(function (t, n)
		      v = init + step * (n - 1)
		      t[n] = v
		      return v
		end)
end
--[[--
--]]--
---tap
-- is_deeply(m.range(1, math.huge):map(function (x) return x * 2 end):take(5), {2, 4, 6, 8, 10})
function M.map(arr, proc)
   local r = {}
   local v
   local f = function (t, n)
		v = proc(arr[n])
		r[n] = v
		return v
	     end
   return M.bless(arr, f, r)
end
---tap
-- is_deeply(m.range(1, math.huge):filter(function (x) return x % 2 == 0 end):take(5), {2, 4, 6, 8, 10})
function M.filter(arr, pred)
   local r = {}
   local icnt = 0
   local ocnt = 0
   local v
   local f = function (t, n)
		repeat
		   ocnt = ocnt + 1
		   repeat
		      icnt = icnt + 1
		      v = arr[icnt]
		      if v == nil then
			 return nil
		      end
		   until pred(v)
		   r[ocnt] = v
		until ocnt >= n
		return v
	     end
   return M.bless(arr, f, r)
end

--[[--
--]]--
---tap
-- is_deeply(m.range(1, math.huge):drop(3):take(5), {4, 5, 6, 7, 8})
function M.drop(arr, k)
   local r = {}
   local v
   local f = function (t, n)
		v = arr[n + k]
		r[n] = v
		return v
	     end
   return M.bless(arr, f, r)
end
--[[--
--]]--
---tap
-- is_deeply(m.range(1, math.huge):drop_while(function (x) return x < 3 end):take(5), {3, 4, 5, 6, 7})
function M.drop_while(arr, pred)
   local r = {}
   local cnt = 0
   local v
   local flag = false
   local f = function (t, n)
		if flag then
		   v = arr[n + cnt]
		   r[n] = v
		   return v
		else
		   local j = 0
		   repeat
		      j = j + 1
		      v = arr[j]
		      if v == nil then
			 return nil
		      end
		   until not pred(v)
		   flag = true
		   cnt = j - 1
		   j = 0
		   repeat
		      j = j + 1
		      v = arr[j + cnt]
		      if v == nil then
			 return nil
		      end
		      r[j] = v
		   until j >= n
		   return v
		end
	     end
   return M.bless(arr, f, r)
end

return M
--- tuit/array/lazy.lua ends here
