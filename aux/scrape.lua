--- scrape.lua - scrape comments up from a lua file
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
--[[--
NAME scrape.lua
===============

     Usage: lua -l scrape -e "doc()" < foo.lua > foo.md
        or: lua -l scrape -e "tap()" < foo.lua > foo.t

* `doc()` - gather up longer comments
--]]--
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
--[[--
* `tap()` - gather up shorter comment lines preceeded by `---tap`
--]]--
function tap()
   local sw = false
   local keep = {}
   local cnt = 0

   for line in io.lines() do
      if string.match(line, "^%-%-%-tap") then
	 sw = true
      elseif not(string.match(line, "^%-%- ")) then
	 sw = false
      elseif sw then
	 line = string.sub(line, 4)
	 if string.match(line, "^%s*is") or string.match(line, "^%s*ok") or string.match(line, "^%s*(un)?like") then
	    cnt = cnt + 1
	 end
	 table.insert(keep, line)
      end
   end
   if cnt > 0 then
      print("--- tap script - -*- mode:lua -*-")
      print("plan(" .. cnt .. ")")
      for _, line in ipairs(keep) do
	 print(line)
      end
      print("summary()")
   end
end
--- scrape.lua ends here
