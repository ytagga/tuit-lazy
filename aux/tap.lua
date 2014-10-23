--- tap.lua - simple producer for the Test Anything Protocol

-----------------------------------------------------------------
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
-- Usage:
-- lua -l tap script.t
-----------------------------------------------------------------
local M = {}

loadstring = loadstring or load

local function init()
   for _, v in pairs{"ok", "not_ok", "xfail", "cnt", "plan"} do
      M[v] = 0
   end
   for _, v in pairs{"skip", "todo"} do
      M[v] = nil
   end
end

function summary()
   if M.cnt ~= M.plan then
      print("# plan(" .. M.cnt .. ") - recommended")
   end
   if gnu then
      os.exit(M.not_ok - M.xfail)
   else
      os.exit(M.not_ok)
   end
end

--- plan(n) - tells how many tests will be run
function plan(n)
   M.plan = n
   print("1.." .. n)
   M.cnt = 0
end

--- skip(msg) - skips some tests with telling msg
--  or stops skipping if msg is false
function skip(msg)
   M.skip = msg
   if M.skip then
      M.skip = string.gsub(M.skip, "\n", "\n#")
   end
end

--- eval(str) - evaluate an expression. If an error occurs,
--  following tests will be skipped until skip(false) is called.
function eval(str)
   M.skip = nil
   local flag, ret = pcall(loadstring("return (" .. str .. ")"))
   if flag then
      return ret
   else
      skip(ret)
      return nil
   end
end

--- skip_all(msg) - skips all tests.
function skip_all(msg)
   print("1..0 " .. "# skip - " .. (msg or M.skip))
   os.exit(255)
end

--- bail_out(msg) - skips all the resting tests.
function bail_out(msg)
   print("Bail out! - " .. (msg or M.skip))
   os.exit(255)
end

--- todo(msg)
function todo(msg)
   M.todo = msg
end

--- check functions - these functions return expr itself.
local function cv_ok(x, y)
   return x
end
local function check(expr, val, msg, cv)
   M.cnt = M.cnt + 1
   if M.skip then
      print("ok " .. M.cnt .. " # skip " .. M.skip)
   else
      if cv(expr, val) then
	 M.ok = M.ok + 1
	 if M.todo then
	    print("ok " .. M.cnt .. " # TODO " .. M.todo)
	 elseif msg then
	    print("ok " .. M.cnt .. " - " .. msg)
	 else
	    print("ok " .. M.cnt)
	 end
      else
	 M.not_ok = M.not_ok + 1
	 if M.todo then
	    M.xfail = M.xfail + 1
	    print("not ok " .. M.cnt .. " # TODO " .. M.todo)
	 elseif msg then
	    print("not ok " .. M.cnt .. " - " .. msg)
	 else
	    print("not ok " .. M.cnt)
	 end
	 if cv == cv_ok then
	    print("# got:", expr)
	 else
	    print("# got:", expr, "but expected:", val)
	 end
      end
   end
   return expr
end

function ok(expr, msg)
   return check(expr, nil, msg, cv_ok)
end
function is(expr, val, msg)
   return check(expr, val, msg, function (x, y) return x == y end)
end
function isnt(expr, val, msg)
   return check(expr, val, msg, function (x, y) return x ~= y end)
end
function like(expr, val, msg)
   return check(expr, val, msg, function (x, y) return string.match(x, y) end)
end
function unlike(expr, val, msg)
   return check(expr, val, msg, function (x, y) return not string.match(x, y) end)
end
function isa(expr, val, msg)
   return check(expr, val, msg, function (x, y) return type(x) == y end)
end

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

function is_deeply(expr, val, msg)
   return check(expr, val, msg, function (x, y) return cv_deeply(x, y) and cv_deeply(y, x) end)
end


init()
return M
--- stap.lua ends here
