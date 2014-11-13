--- aux/prove.lua - TAP consumer
--------------------------------------------------------------
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
--------------------------------------------------------------
argv = require "tuit.cmdline" [=[
aux/prove.lua (tuit-auxiliary) 0.0
Simple TAP consumer

Usage: lua aux/prove.lua [OPTION] FILE ...

     -e,  --exec=CMD  interpreter to run the tests (lua itself)
     -l,  --log       FILEs are log files (default if the suffix is .log)
          --help      display this message and exit
          --version   print version information and exit
]=]

function parse_file(filename, fd)
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
   if fd ~= io.stdin then
      io.close(fd)
   end
   return r
end

function parse_any(filename)
   local fd
   if not(filename) or filename == "stdin" then
      filename = "stdin"
      fd = io.stdin
   elseif argv.log or string.match(filename, "%.log$") then
      fd = io.open(filename) or error("can't open - " .. filename)
   else
      local cmd = argv.exec or argv._lua
      fd = io.popen(cmd .. " " .. filename) or error("can't invoke - " .. filename)
   end
   return parse_file(filename, fd)
end

function parse_args(argv)
   local r
   local results = {}
   if #argv == 0 then
      r = parse_any()
      table.insert(results, r)
   else
      for _, v in ipairs(argv) do
	 r = parse_any(v)
	 table.insert(results, r)
      end
   end
   return results
end

function print_results(results)
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

r = print_results(parse_args(argv))
os.exit(r)
--- aux/prove.lua ends here
