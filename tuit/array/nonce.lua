--- tuit/array/nonce.lua - iteration over a lazy-evaluated array

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
require "tuit.array.lazy"

tuit.array.nonce = tuit.array.nonce or {}
setmetatable(tuit.array.nonce, { __index = tuit.array.lazy })
table.unpack = table.unpack or unpack

local M = tuit.array.nonce
M.class = M

function M.newindex(t, n, v) return v end

---tap
-- m = assert(require 'tuit.array.nonce')
-- plan()
-- y = 0
-- x = m.bless(m, function (t, n) y = y + 1; return y end)
-- isa(x, 'table')
-- is(x[1], 1)
-- is(x[2], 2)
-- is(x[1], 3)

return M
--- tuit/array/nonce.lua ends here
