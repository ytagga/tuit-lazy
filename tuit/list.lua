--- tuit/list.lua - list library

local M = {}

function M.equal(a, b)
   if type(a) ~= 'table' or type(b) ~= 'table' then
      return a == b
   elseif #a ~= #b then
      return false
   else
      for i = 1, #a do
	 if not M.equal(a[i], b[i]) then
	    return false
	 end
      end
      return true
   end
end

function M.list(...)
   local r = {...}
   return r
end

function M.make_list(n, fill)
   fill = fill or true
   local r = {}
   for i = 1, n do
      table.insert(r, fill)
   end
   return r
end

function M.append(...)
   local r = {}
   for _, v in ipairs{...} do
      for _, w in ipairs(v) do
	 table.insert(r, w)
      end
   end
   return r
end

function M.list_tabulate(n, proc)
   local r = {}
   n = n - 1
   for i = 0, n do
      table.insert(r, proc(i))
   end
   return r
end

function M.list_copy(a)
   local r = {}
   for i, v in ipairs(a) do
      r[i] = v
   end
   return r
end

function M.iota(n, init, step)
   init = init or 0
   step = step or 1
   local k = init
   local r = {}
   for i = 1, n do
      r[i] = k
      k = k + step
   end
   return r
end

local function list_eq2(eq, a, b)
   if #a ~= #b then
      return false
   end
   for i = 1, #a do
      if not(eq(a[i], b[i])) then
	 return false
      end
   end
   return true
end

function M.list_eq(eq, x, ...)
   for _, v in ipairs{...} do
      if not list_eq2(eq, x, v) then
	 return false
      end
   end
   return true
end

function M.zip(...)
   local all = {...}
   local r = {}
   local n = math.huge
   local x
   for j, v in ipairs(all) do
      x = #v
      if x < n then
	 n = x
      end
   end
   for i = 1, n do
      r[i] = {}
      for j, v in ipairs(all) do
	 r[i][j] = v[i]
      end
   end
   return r
end


local function flat(x, r)
   if type(x) == 'table' then
      for i, v in ipairs(x) do
	 flat(v, r)
      end
   else
      table.insert(r, x)
   end
end

function M.flatten(x)
   local r = {}
   flat(x, r)
   return r
end


return M
--- tuit/list.lua ends here
