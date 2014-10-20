--- tuit/lazy.t -*- mode: lua -*-

plan(121 + 10)

m = eval[[require 'tuit.lazy']] or skip_all()
f = require "tuit.combine"

a = eval[[m.qw"a b c"]]
isa(a, 'table')
isa(getmetatable(a), 'table')
is(a[1], 'a')
is(a[2], 'b')
is(a[3], 'c')
is(a[4], nil)

a = eval[[m.unfold_new(function (s) return s[#s] < 10 end, function (s) return s[#s - 1] + s[#s] end, {1, 1})]]
isa(a, 'table')
is(#a, 2)
is(a[1], 1)
is(a[2], 1)
is(a[3], 2)
is(a[4], 3)
is(a[5], 5)
is(a[6], 8)
is(a[7], 13)
is(a[8], nil)

a = eval[[m.unfold(f.part(f.lt, 10), f.add, 1, 1)]]
isa(a, 'table')
is(#a, 2) -- lazy evaluation!
is(a[1], 1)
is(a[2], 1)
is(a[3], 2)
is(a[4], 3)
is(a[5], 5)
is(a[6], 8)
is(a[7], nil)

function toomany(x)
    if x > 100 then
       error("too many!")
    else
       return false
    end
 end
a = eval[[m.unfold(toomany, f.add, 1, 1)]]
isa(a, 'table')
is(#a, 2) -- lazy evaluation!
is(a[1], 1)
is(a[2], 1)
is(a[3], 2)
is(a[4], 3)
is(a[5], 5)
is(a[6], 8)
is(a[7], 13)

a = eval[[m.iota(5)]]
isa(a, 'table')
is(#a, 0) -- lazy evaluation!
is(a[1], 0)
is(a[5], 4)
is(a[6], nil)

a = eval[[m.iota(4, 1)]]
isa(a, 'table')
is(#a, 0) -- lazy evaluation!
is(a[1], 1)
is(a[4], 4)
is(a[5], nil)

a = eval[[m.iota(3, 5, -2)]]
isa(a, 'table')
is(#a, 0) -- lazy evaluation!
is(a[1], 5)
is(a[3], 1)
is(a[4], nil)

a = eval[[m.iota(math.huge)]]
isa(a, 'table')
is(#a, 0) -- lazy evaluation!
is(a[1], 0)
is(a[5], 4)

a = eval[[m.iota(math.huge, 1)]]
isa(a, 'table')
is(#a, 0) -- lazy evaluation!
is(a[1], 1)
is(a[4], 4)

a = eval[[m.iota(math.huge, 5, -2)]]
isa(a, 'table')
is(#a, 0) -- lazy evaluation!
is(a[1], 5)
is(a[3], 1)

b = eval[[a:take(2)]]
isa(b, 'table')
is(#b, 2)
is(b[1], 5)
is(b[2], 3)
is(b[3], nil)

b = eval[[a:take(4)]]
isa(b, 'table')
is(#b, 4)
is(b[1], 5)
is(b[2], 3)
is(b[3], 1)
is(b[4], -1)
is(b[5], nil)


b = eval[[a:drop(0)]]
isa(b, 'table')
is(#b, 0)
is(b[1], 5)
is(b[3], 1)

b = eval[[a:drop(1)]]
is(#b, 0)
is(b[1], 3)
is(b[3], -1)

is(a:find(f.part(f.lt, 3)), 5)
is(a:find(f.part(f.ge, 3)), 3)
is(a:find(f.part(f.gt, 3)), 1)

is(a:any(f.part(f.lt, 3)), true)
is(a:any(f.part(f.ge, 5)), true)

a = m.iota(5)
cnt = 0
function check(n)
   cnt = cnt + 1
end
a:foreach(check)
is(cnt, 5)
cnt = ""
function check(x)
   cnt = cnt .. x
end
a:foreach(check)
is(cnt, "01234")

function check(v, i)
   cnt = cnt .. v .. i
end
cnt = ""
a:each(check)
is(cnt, "0112233445")
cnt = 0
function check(v, i, a)
   if type(a) == 'table' then
      cnt = cnt + 1
   end
end
a:each(check)
is(cnt, 5)

is(a:fold(math.max, -1), 4)
is(a:fold(math.max, 5), 5)
is(a:fold(math.min, -1), -1)
is(a:fold(math.min, 5), 0)

b = eval[[a:map(f.part(f.add, 2))]]
isa(b, 'table')
is(#b, 0)
is(b[1], 2)
is(b[3], 4)
is(b[5], 6)

b = eval[[a:filter(function (x) return x % 2 == 0 end)]]
isa(b, 'table')
is(#b, 0)
is(b[1], 0)
is(b[2], 2)
is(b[3], 4)

b = eval[[a:filter(function (x) return x % 2 ~= 0 end)]]
isa(b, 'table')
is(#b, 0)
is(b[1], 1)
is(b[2], 3)

b = eval[[a:takewhile(f.part(f.gt, 3))]]
isa(b, 'table')
is(#b, 3)
is(b[1], 0)
is(b[2], 1)
is(b[3], 2)

b = eval[[a:takewhile(f.part(f.lt, 3))]]
isa(b, 'table')
is(#b, 0)
is(b[1], nil)

b = eval[[a:dropwhile(f.part(f.gt, 3))]]
isa(b, 'table')
is(#b, 0)
is(b[1], 3)
is(b[2], 4)

b = eval[[a:dropwhile(f.part(f.lt, 3))]]
isa(b, 'table')
is(#b, 0)
is(b[1], 0)
is(b[5], 4)

a = m.iota(math.huge)
b = eval[[a:dropwhile(f.part(f.gt, 3))]]
isa(b, 'table')
is(#b, 0)
is(b[1], 3)
is(b[2], 4)

b = eval[[a:dropwhile(f.part(f.lt, 3))]]
isa(b, 'table')
is(#b, 0)
is(b[1], 0)
is(b[2], 1)

summary()
--- tuit/stream.t ends here
