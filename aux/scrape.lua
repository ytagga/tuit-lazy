--- scrape.lua - gather up comments from a lua file
------------------------------------------------------------------
-- Copyright (C) 2014 TAGA Yoshitaka <tagga@tsuda.ac.jp>
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
------------------------------------------------------------------

argv = require "tuit.cmdline" [=[
aux/scrape.lua (tuit-auxliary) 0.01

Usage: lua %s --tap FOO.lua > FOO.t
   or: lua %s --doc FOO.lua > FOO.md
Gather up comments from a Lua file

     -d, --doc        collect long comments between --[[-- and --]]--
     -t, --tap        collect comments lines beginnng with ---tap (default)
         --help       display this message and exit
         --version    output version information and exit
]=]

-- doc() ------------------------------------------------
function doc()
   local sw = false

   for line in io.lines() do
      if string.match(line, "^%-%-%[%[%-%-") then
	 sw = true
      elseif string.match(line, "^%-%-%]%]%-%-") then
	 sw = false
      elseif sw then
	 print(line)
      end
   end
end

-- tap() ------------------------------------------------
local check_func_tab = {}

-- Chnage this table if you rewrite tuit/tap.lua! --
for i, v in ipairs{'ok', 'is', 'isnt', 'like', 'unlike', 'isa', 'is_deeply'} do
   check_func_tab[v] = i
end

local function has_check_func(line)
   local v = string.match(line, "^%s*([%w_]+)")
   return check_func_tab[v]
end

function tap()
   local sw = false
   local cnt = 0

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
	 print(line)
      end
   end
   print("]=====]")
   print("if t == nil then")
   print('  skip_all("broken test script")')
   print("end")
   print("plan(" .. cnt .. ")")
   print("local f, v = pcall(t)")
   print("if not(f) then")
   print("   bail_out(v)")
   print("end")
   print("os.exit(tuit.tap.not_ok)")
end

-- main -------------------------------------------------
if #argv > 0 then
   io.input(argv[1])
end
if argv.doc then
   doc()
else
   tap()
end
--- scrape.lua ends here
