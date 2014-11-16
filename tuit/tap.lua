--- tuit/tap.lua - simple test harness for the Test Anything Protocol
---------------------------------------------------------------------
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
-----------------------------------------------------------------
--[[--

tuit.tap
========

NAME
----

tuit.tap - simple testsuite for the Test Anything Protocol

SYNOPSIS
--------

     lua aux/scrape.lua --tap foo.lua > foo.t
     lua aux/prove.lua foo.t > foo.log

--]]--

tuit = tuit or {}
tuit.tap = tuit.tap or {}
local M = tuit.tap

loadstring = loadstring or load

--[[--

Functions for test scripts
--------------------------

* `plan(n)` - tells how many tests will be run. The argument, if missing, will be added by `M.make_script()`.
--]]--
function plan(n)
   print("1.." .. n)
   M.cnt = 0
   M.not_ok = 0
end

--[[--
* `eval(str)` - evaluates an expression unless `skip` directive is set.
This function will be used in the first argument of check functions
when `skip` or `todo` directive may be set.  If `skip` flag is set,
`str` will not be evaluated.
--]]--
function eval(str)
   if M.skip then
      return str
   else
      local flag, ret = pcall(loadstring("return (" .. str .. ")"))
      if flag then
	 M.err = nil
	 return ret
      else
	 M.err = ret
	 return nil
      end
   end
end

--[[--
* `skip_all(msg)` - skips all tests.
--]]--
function skip_all(msg)
   print("1..0 " .. "# skip - " .. msg)
   os.exit(255)
end
--[[--
* `bail_out(msg)` - skips all the resting tests.
--]]--
function bail_out(msg)
   print("Bail out! - " .. msg)
   os.exit(255)
end

--[[--
* `skip_on_error(why)` - skips some tests till `skip(false)` when an error occurs.  If this function is called before `plan()`, all tests will be skipped.
--]]--
function skip_on_error(msg)
   if M.err then
      M.skip = msg or M.err
      if M.cnt == nil then
	 skip_all()
      end
   else
      M.skip = nil
   end
end
--[[--
* `skip(why)` - skips some tests with telling `why` or stops skipping if `why` is `false`.
--]]--
function skip(msg)
   M.skip = msg
end
--[[--
* `todo(msg)` - tells the following tests till `todo(false)` will be counted as TODO tests.
--]]--
-- todo(msg)
function todo(msg)
   M.todo = msg
end
-----------------------
--- check functions ---
-----------------------
--- auxiliary function for ok()
local function cv_ok(x, y)
   return x
end
--- auxiliary pretty print
local function pretty(x)
   local typ = type(x)
   if typ == 'table' then
      local r = '{'
      for i, v in ipairs(x) do
	 if i ~= 1 then
	    r = r .. ', '
	 end
	 r = r .. pretty(v)
      end
      return r .. '}'
   elseif typ == 'string' then
      return string.format("%q", x)
   else
      return tostring(x)
   end
end
--- the main part of check functions
local function check(expr, val, msg, cv)
   if not(M.cnt) then
      M.cnt = 0
      M.not_ok = 0
   end
   M.cnt = M.cnt + 1
   local which = "not ok"
   local diff

   if M.skip then
      which = "ok"
   elseif M.err then
      M.not_ok = M.not_ok + 1
      diff = M.err
   elseif cv(expr, val) then
      which = "ok"
   elseif cv == cv_ok then
      M.not_ok = M.not_ok + 1
      diff = "got: " .. pretty(expr)
   else
      M.not_ok = M.not_ok + 1
      diff = "got: " .. pretty(expr) .. ", but expected: " .. pretty(val)
   end

   local output = which .. " " .. M.cnt
   if msg then
      output = output .. " - " .. msg
   end
   if diff then
      output = output .. " - " .. diff
   end
   if M.skip then
      output = output .. " # skip - " .. M.skip
   elseif M.todo then
      output = output .. " # TODO - " .. M.todo
   end
   print(output)
   M.err = nil
   return expr
end
--[[--
* `ok(expr, [msg])` - checks if `expr` is true.
--]]--
function ok(expr, msg)
   return check(expr, nil, msg, cv_ok)
end
--[[--
* `is(expr, val, [msg])` - checks if `expr` is equivalent to `val`.
--]]--
function is(expr, val, msg)
   return check(expr, val, msg, function (x, y) return x == y end)
end
--[[--
* `isnt(expr, val, [msg])` - checks if `expr` is not equivalent to `val`.
--]]--
function isnt(expr, val, msg)
   return check(expr, val, msg, function (x, y) return x ~= y end)
end
--[[--
* `like(expr, val, [msg])` - checks if `expr` matches to pattern `val`.
--]]--
function like(expr, val, msg)
   return check(expr, val, msg, function (x, y) return string.match(x, y) end)
end
--[[--
* `unlike(expr, val, [msg])` - checks if `expr` does not match to pattern `val`.
--]]--
function unlike(expr, val, msg)
   return check(expr, val, msg, function (x, y) return not string.match(x, y) end)
end
--[[--
* `isa(expr, val, [msg])` - checks if the type of `expr` is `val`.
--]]--
function isa(expr, val, msg)
   return check(expr, val, msg, function (x, y) return type(x) == y end)
end
--- auxiliary function for is_deeply()
local function cv_deeply(x, y)
   if type(x) ~= "table" then
      return x == y
   elseif type(y) ~= "table" then
      return false
   else
      for k, v in pairs(x) do
	 if not(cv_deeply(v, y[k])) then
	    return false
	 end
      end
      return true
   end
end
--[[--
* `is_deeply(expr, val, [msg])` - checks if `expr` is equal to `val`.
--]]--
function is_deeply(expr, val, msg)
   return check(expr, val, msg, function (x, y) return cv_deeply(x, y) and cv_deeply(y, x) end)
end

--[[--

Producer
--------

* `tuit.tap.make_script()` - reads a Lua file and gathers up TAP test code chunks in comments.

--]]--

local check_func_tab = {}

-- CHNAGE THIS TABLE IF YOU REWRITE tuit/tap.lua! --
for i, v in ipairs{'ok', 'is', 'isnt', 'like', 'unlike', 'isa', 'is_deeply'} do
   check_func_tab[v] = i
end

local function has_check_func(line)
   local v = string.match(line, "^%s*([%w_]+)")
   return check_func_tab[v]
end

function M.make_script()
   local sw = false
   local cnt = 0
   local keep = {}
   local plan = nil

   print("--- tap script - -*- mode:lua -*-")
   print('require "tuit.tap"')
   print("local t = loadstring [=====[")
   for line in io.lines() do
      if string.match(line, "^%-%-%-tap") then
	 sw = true
      elseif not(string.match(line, "^%-%- ")) then
	 sw = false
      elseif sw then
	 line = string.sub(line, 4)
	 if has_check_func(line) then
	    cnt = cnt + 1
	 end
	 table.insert(keep, line)
	 if string.match(line, "plan(.*)") then
	    plan = true
	 end
      end
   end
   if not(plan) then
      print("plan(" .. cnt .. ")")
   end
   for _, line in ipairs(keep) do
      if string.match(line, "plan()") then
	 line = string.gsub(line, "plan%(%)", "plan(" .. cnt .. ")")
      end
      print(line)
   end
   print("]=====]")
   print("if t == nil then")
   print('  skip_all("broken test script")')
   print("end")
   print("local f, v = pcall(t)")
   print("if not(f) then")
   print("   bail_out(v)")
   print("end")
   print("os.exit(tuit.tap.not_ok)")
end

--[[--

Consumer
--------

* `tuit.tap.parse(filename)` - parses a TAP log or the output of a TAP script and returns a table that contains the results.

--]]--

function M.parse(filename, fd)
   local r = {}
   r.filename = filename
   r.ok = 0
   r.not_ok = 0
   r.skip = 0
   r.todo = 0
   local n = 0
   local num, dir
   for line in fd:lines() do
      if string.match(line, "^Bail out!") then
	 error("Bail out! - " .. filename)
	 return nil -- bail out
      elseif string.match(line, "^%s*not ok") then
	 n = n + 1
	 num = string.match(line, "not ok%s+(%d+)")
	 if num then
	    n = tonumber(num)
	 end
	 dir = string.match(line, "#%s+(%a%a%a%a)")
	 if dir then
	    dir = string.lower(dir)
	    if dir == "todo" then
	       r.todo = r.todo + 1
	    end
	 end
	 table.insert(r, n)
	 r.not_ok = r.not_ok + 1
      elseif string.match(line, "^%s*ok") then
	 n = n + 1
	 num = string.match(line, "ok%s+(%d+)")
	 if num then
	    n = tonumber(num)
	 end
	 dir = string.match(line, "#%s+(%a%a%a%a)")
	 if dir then
	    dir = string.lower(dir)
	    if dir == "skip" then
	       r.skip = r.skip + 1
	    elseif dir == "todo" then
	       r.todo = r.todo + 1
	    end
	 end
	 r.ok = r.ok + 1
      elseif string.match(line, "^%s*1%.%.") then
	 num = string.match(line, "^%s*1%.%.(%d+)")
	 if num == '0' then
	    r.plan = 0
	    return r
	 end
	 r.plan = tonumber(num)
      else
	 --- ignore!
      end
   end
   r.num = n
   return r
end

--[[--

* `tuit.tap.show(results)` - shows the results and returns the number of the test scripts in which some errors occurred.

--]]--

function M.show(results)
   local r = 0
   for _, v in ipairs(results) do
      if v.not_ok > 0 then
	 r = r + 1
	 print(v.filename, "failed: " .. table.concat(v, ', '))
	 print(string.format("-- ok %d/%d (%4.2f%%))", v.ok, v.num, v.ok / v.num * 100))
      else
	 print(v.filename, "ok")
      end
      if v.plan == 0 then
	 print("-- skipped all")
      end
      if v.plan == nil or v.plan ~= v.num then
	 print(string.format("-- dubious - has %d tests", v.num))
      end
      if v.skip > 0 then
	 print(string.format("-- %d test(s) skipped", v.skip))
      end
      if v.todo > 0 then
	 print(string.format("-- %d TODO test(s)", v.todo))
      end
   end
   return r
end

return M
--- tuit/tap.lua ends here
