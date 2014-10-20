--- tuit/array.lua - iteration over an array

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
tuit.array = tuit.array or {}

local M = tuit.array
local MT = { __index = M }

table.unpack = table.unpack or unpack

function M.bless(arr)
   setmetatable(arr, MT)
   return arr
end

function M.ipairs(arr)
   return coroutine.wrap(
      function ()
	 local i = 1
	 local v = arr[i]
	 while v ~= nil do
	    coroutine.yield(i, v)
	    i = i + 1
	    v = arr[i]
	 end
	 return nil
   end)
end

function M.unfold(pred, proc, ...)
   local r = M.bless({})
   local v
   local seeds = {...}
   for _, v in ipairs(seeds) do
      table.insert(r, v)
   end
   while true do
      v = proc(table.unpack(seeds))
      if v == nil or pred(v) then
	 break
      end
      table.insert(r, v)
      table.remove(seeds, 1)
      table.insert(seeds, v)
   end
   return r
end

local function no(x)
   return false
end
function M.qw(str)
   return M.unfold(no, string.gmatch(str, "(%S+)"))
end

function M.dispatch(any)
   if type(any) == "table" then
      return M.bless(any)
   elseif type(any) == "string" then
      return M.qw(any)
   elseif type(any) == "function" then
      return M.unfold(any)
   else
      return M.bless({ any })
   end
end

function M.iota(cnt, init, step)
   init = init or 0
   step = step or 1
   local r = M.bless({})
   local v = init
   for i = 1, cnt do
      r[i] = v
      v = v + step
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

function M.find(arr, pred)
   for _, v in M.ipairs(arr) do
      if pred(v) then
	 return v
      end
   end
   return nil
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

function M.foreach(arr, proc)
   for _, v in M.ipairs(arr) do
      proc(v)
   end
end

function M.each(arr, proc)
   for i, v in M.ipairs(arr) do
      proc(v, i, arr)
   end
end


function M.fold(arr, kons, knil)
   local r = knil
   for _, v in M.ipairs(arr) do
      r = kons(v, r)
   end
   return r
end

function M.map(arr, proc)
   local r = M.bless({})
   for i, v in M.ipairs(arr) do
      r[i] = proc(v)
   end
   return r
end

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

return M
--- tuit/array.lua ends here
