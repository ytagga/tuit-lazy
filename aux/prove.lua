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
aux/prove.lua (tuit-auxiliary) 0.01
Simple TAP consumer

Usage: lua aux/prove.lua [OPTION] FILE ...

     -e,  --exec=CMD  interpreter to run the tests (lua itself)
     -l,  --log       FILEs are log files (default if the suffix is .log)
          --help      display this message and exit
          --version   print version information and exit
]=]

require "tuit.tap"

results = {}
if #argv == 0 then
   table.insert(results, tuit.tap.parse("stdin", io.stdin))
else
   local fd
   local cmd
   for _, v in ipairs(argv) do
      if argv.log or string.match(v, "%.log$") then
	 fd = assert(io.open(v))
      else
	 cmd = argv.exec or argv._lua
	 fd = assert(io.popen(cmd .. " " .. v))
      end
      table.insert(results, tuit.tap.parse(v, fd))
      io.close(fd)
   end
end
os.exit(tuit.tap.show(results))
--- aux/prove.lua ends here
