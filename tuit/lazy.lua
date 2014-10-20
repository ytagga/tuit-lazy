--- tuit/lazy.lua - iteration over a lazy-evaluated array

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

tuit.lazy = tuit.lazy or {}
setmetatable(tuit.lazy, { __index = tuit.array})

table.unpack = table.unpack or unpack

local M = tuit.lazy

M.class = M

function M.bless(from, tab, idxf)
   tab = tab or {}
   local m = from.class
   if idxf then
      local f = function (t, n)
		   if type(n) == "string" then
		      return m[n]
		   else
		      return idxf(t, n)
		   end
		end
      setmetatable(tab, { __index = f })
   else
      setmetatable(tab, { __index = m })
   end
   return tab
end

function M.unfold_new(pred, f, seeds)
   local v
   local f = function (t, n)
		while pred(t) and #t < n do
		   v = f(t)
		   if v == nil then
		      return nil
		   end
		   table.insert(t, v)
		end
		if #t == n then
		   return v
		else
		   return nil
		end
	     end
   return M.bless(M, seeds, f)
end


function M.unfold(pred, proc, ...)
   local seeds = {...}
   local r = { table.unpack(seeds) }
   local cnt = #r
   local v
   local f = function (t, n)
		repeat
		   cnt = cnt + 1
		   v = proc(table.unpack(seeds))
		   if v == nil or pred(v) then
		      return nil
		   end
		   t[cnt] = v
		   table.remove(seeds, 1)
		   table.insert(seeds, v)
		until cnt >= n
		return v
	     end
   return M.bless(M, r, f)
end

function M.iota(cnt, init, step)
   init = init or 0
   step = step or 1
   local r = {}
   local v
   local f = function (t, n)
		if n <= cnt then
		   v = init + (n - 1) * step
		   t[n] = v
		   return v
		else
		   return nil
		end
	     end
   return M.bless(M, r, f)
end

function M.map(arr, proc)
   local r = {}
   local v
   local f = function (t, n)
		v = proc(arr[n])
		t[n] = v
		return v
	     end
   return M.bless(arr, r, f)
end

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
		   t[ocnt] = v
		until ocnt >= n
		return v
	     end
   return M.bless(arr, r, f)
end

function M.drop(arr, k)
   local r = {}
   local v
   local f = function (t, n)
		v = arr[n + k]
		t[n] = v
		return v
	     end
   return M.bless(arr, r, f)
end

function M.dropwhile(arr, pred)
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
   return M.bless(arr, r, f)
end

return M
--- tuit/lazy.lua ends here
