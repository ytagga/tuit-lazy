--- tuit/cmdline.lua -- parse command line options
---------------------------------------------------------------
-- Copyright (c) 2013-2014 TAGA Yoshitaka <tagga@tsuda.ac.jp>
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
---------------------------------------------------------------

--[[--

NAME
====

tuit.cmdline - parse command options according to the usage message

SYNOPSIS
========

    argv = require 'tuit.cmdline' [=[
    VERSION INFORMATION

    Usage: %s [OPTION] ... [FILE] ...
    DESCRIPTION

    -a                       short option only (argv.opt_a in Lua)
    -b, --basic              short and long options (argv.basic)
    -c, --with-argument=REQ  requires an argument (argv.with_argument)
    -d, --optional[=OPT]     can take an argument (argv.optional)
    ]=]

    for i, v in ipairs(argv) do
      -- do something
    end

DESCRIPTION
===========

`tuit.cmdline` provides a command line parser whose configurations
are given in a usage message.

If you `require` this library, `require` returns a function which
takes a string argument and which returns a table containing option
information and the other arguments.

The script name nad the Lua program
-----------------------------------

Pattern `%s` in the usage message will be replaced with
the global `arg[0]`, which will be the script name.

The script name is stored in `argv._script` and the Lua program
and its options are concatenated and stored in `argv._lua`.


Options
-------

A short option is a character following a single "-",
for example `-a`.
Its argument, if any, will be specifed in its long counterpart.
A short option `-a` is accessed via `argv.opt_a` if it has no long
option.

A long option is a name following "--", for example `--for-example`.
You can access it via `argv.for_example`.
If the name is followed by `=`, it requires an argument.
If the name is followed by `[`, it can take an optional argument.

The value of options without an argument is either `true` or `nil`.

Predefined options
------------------

* `--help` prints the usage message and exits successfully.

* `--version` writes out the version information and exits successfully.

* `--` ends parsing options.

Other arguments
---------------

Non-option arguments are stored in `argv`. This table can be accessed
as an array.

--]]--

local M = {}
tuit = tuit or {}
tuit.cmdline = tuit.cmdline or M

local function die(msg, key)
   io.stderr:write(arg[0] .. ": " .. msg .. " - " .. key)
   os.exit(1)
end

local function apply_opt(self, lname, val)
   local proc = self[lname]
   if type(proc) == 'function' then
      proc(val)
   elseif type(proc) == 'table' then
      table.insert(proc, val)
   else
      self[lname] = val
   end
end

local function get_lua_name(sw, name)
   if not name then
      return "opt_" .. sw
   else
      name = string.gsub(name, "(%W)", "_")
      return name
   end
end

local function get_short_option(desc)
   local sw = string.match(desc, "^%s*%-(%w)")
   return sw
end
local function get_long_option(desc)
   local name, br, eq
   name, br, eq = string.match(desc, "%-%-([a-z][%w%-]+)(%[?)(=?)")
   local opt = 'no'
   if eq and #eq > 0 then
      if #br > 0 then
	 opt = 'may'
      else
	 opt = 'must'
      end
   end
   return name, opt
end

local function on_option(desc, short, long, optarg)
   local sw, name, opt
   sw = get_short_option(desc)
   name, opt = get_long_option(desc)
   local key = sw or name or error("parse_opts: invalid description - " .. desc)
   local lname = get_lua_name(sw, name)
   if sw then
      short[sw] = lname
   end
   if name then
      long[name] = lname
   end
   optarg[lname] = opt
end

local function collect_options(msg)
   local short = {}
   local long = {}
   local optarg = {}
   for desc in string.gmatch(msg, "([^\n]*)") do
      if string.match(desc, "^%s*%-") then
	 on_option(desc, short, long, optarg)
      end
   end
   return short, long, optarg
end

local function parse_long_option(self, i, long, optarg)
   local this = arg[i]
   local name, val, lname

   name, val = string.match(arg[i], "^%-%-([a-z][%w%-]+)=(.*)$")
   if name then
      lname = long[name] or die("unknown option", name)
      if optarg[lname] == 'no' then
	 die("option doesn't take an argument", name)
      end
      apply_opt(self, lname, val)
      return i + 1
   end
   name = string.match(arg[i], "^%-%-([a-z][%w%-]+)$")
   lname = long[name] or die("unknown option", name)
   if optarg[lname] == 'must' and i == #arg then
      die("option requires an argument", name)
   elseif optarg[lname] == 'may' and i == #arg then
      apply_opt(self, lname, true)
      return i + 1
   elseif optarg[lname] ~= 'no' then
      apply_opt(self, lname, arg[i + 1])
      return i + 2
   else
      apply_opt(self, lname, true)
      return i + 1
   end
end

local function parse_short_options(self, i, short, optarg)
   local this = string.sub(arg[i], 2)
   local c, lname

   while true do
      c = string.sub(this, 1, 1)
      if #c == 0 then
	return i + 1
      end
      this = string.sub(this, 2)
      lname = short[c] or die("unknown option", c)
      if optarg[lname] == 'no' then
	 apply_opt(self, lname, true)
      elseif #this > 0 then
	 apply_opt(self, lname, this)
	 return i + 1
      elseif optarg[lname] == 'must' and i == #arg then
	 die("option requires an argument", c)
      elseif optarg[lname] == 'may' and i == #arg then
	 apply_opt(self, lname, true)
	 return i + 1
      else
	 apply_opt(self, lname, arg[i + 1])
	 return i + 2
      end
   end
end

local function lua_program()
   local i = -1
   local tmp = {}
   while arg[i] do
      table.insert(tmp, 1, arg[i])
      i = i - 1
   end
   return table.concat(tmp, ' ')
end

function M.Init(msg)
   msg = string.gsub(msg, "^\n+", "")
   msg = string.gsub(msg, "\n+$", "")
   msg = string.gsub(msg, "%%s", arg[0])
   local i, j, version, help
   i, j = string.find(msg, "\n\n+")
   if i then
      version = string.sub(msg, 1, i - 1)
      help = string.sub(msg, j + 1)
   else
      help = msg
   end
   local short, long, optarg = collect_options(msg)

   local self = {}

   self._script = arg[0]
   self._lua = lua_program()

   self.help =
   function ()
      print(msg)
      os.exit(0)
   end
   long['help'] = 'help'

   if version then
      self.version =
      function ()
	 print(version)
	 os.exit(0)
      end
      long['version'] = 'version'
   end

   i = 1
   while i <= #arg do
      if arg[i] == '--' then
	 while i < #arg do
	    i = i + 1
	    table.insert(self, arg[i])
	 end
	 break
      elseif arg[i] == '-' or string.match(arg[i], "^[^%-]") then
	 table.insert(self, arg[i])
	 i = i + 1
      elseif string.match(arg[i], "^%-%-") then
	 i = parse_long_option(self, i, long, optarg)
      else
	 i = parse_short_options(self, i, short, optarg)
      end
   end

   return self
end

return M.Init

--[[--

BUGS
====

* Long options may not be abbreviated even if the abbreviation is not
  ambiguous.

* The environment variables `POSIXLY_CORRECT` and `GETOPT_COMPATIBLE`
  are ignored.

AUTHOR
======

TAGA Yoshitaka

SEE ALSO
========

[getopt(3)](http://www.gnu.org/software/libc/manual/html_node/Getopt.html),
[Lapp Framework](http://lua-users.org/wiki/LappFramework),
[apr.getopt](http://peterodding.com/code/lua/apr/docs/#apr.getopt).
--]]--
--- tuit/cmdline.lua ends here
