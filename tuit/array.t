--- tuit/array.t -*- mode:lua -*-

plan(124)

m = eval[[require 'tuit.array']] or skip_all()
f = require "tuit.combine"

a =  {5, 7, 8}
isa(a, 'table')
is(getmetatable(a), nil)

a = m.bless(a)
isa(a, 'table')
isa(getmetatable(a), 'table')

is(a[1], 5)
is(a[2], 7)
is(a[3], 8)
is(a[4], nil)

a = eval[[m.qw"a b c"]]
isa(a, 'table')
isa(getmetatable(a), 'table')
is(a[1], 'a')
is(a[2], 'b')
is(a[3], 'c')
is(a[4], nil)


a = eval[[m.unfold(f.part(f.lt, 10), f.add, 1, 1)]]
isa(a, 'table')
is(#a, 6)
is(a[1], 1)
is(a[2], 1)
is(a[3], 2)
is(a[4], 3)
is(a[5], 5)
is(a[6], 8)
is(a[7], nil)

a = eval[[m.iota(5)]]
isa(a, 'table')
is(#a, 5)
is(a[1], 0)
is(a[5], 4)
is(a[6], nil)

a = eval[[m.iota(4, 1)]]
isa(a, 'table')
is(#a, 4)
is(a[1], 1)
is(a[4], 4)
is(a[5], nil)

a = eval[[m.iota(3, 5, -2)]]
isa(a, 'table')
is(#a, 3)
is(a[1], 5)
is(a[2], 3)
is(a[3], 1)

b = eval[[m.copy(a)]]
isa(b, 'table')
is(#b, 3)
is(b[1], 5)
is(b[3], 1)

b = eval[[a:copy()]]
isa(b, 'table')
is(#b, 3)
is(b[1], 5)
is(b[3], 1)

b = eval[[a:take(2)]]
isa(b, 'table')
is(#b, 2)
is(b[1], 5)
is(b[2], 3)
is(b[3], nil)

b = eval[[a:take(3)]]
isa(b, 'table')
is(#b, 3)
is(b[1], 5)
is(b[2], 3)
is(b[3], 1)

b = eval[[a:take(4)]]
isa(b, 'table')
is(#b, 3)
is(b[1], 5)
is(b[2], 3)
is(b[3], 1)

b = eval[[a:take(0)]]
isa(b, 'table')
is(#b, 0)


b = eval[[a:drop(0)]]
isa(b, 'table')
is(#b, 3)
is(b[1], 5)
is(b[2], 3)
is(b[3], 1)

b = eval[[a:drop(1)]]
isa(b, 'table')
is(#b, 2)
is(b[1], 3)
is(b[2], 1)

b = eval[[a:drop(2)]]
isa(b, 'table')
is(#b, 1)
is(b[1], 1)

b = eval[[a:drop(3)]]
isa(b, 'table')
is(#b, 0)

b = eval[[a:drop(4)]]
isa(b, 'table')
is(#b, 0)

is(a:last(), 1)
is(a:count(f.part(f.gt, 3)), 1)
is(a:count(f.part(f.le, 3)), 2)

is(a:find(f.part(f.gt, 3)), 1)
is(a:find(f.part(f.lt, 3)), 5)

ok(a:any(f.part(f.lt, 3)))
ok(not(a:every(f.part(f.lt, 3))))
ok(a:any(f.part(f.ge, 5)))
ok(a:every(f.part(f.ge, 5)))
ok(not(a:any(f.part(f.lt, 5))))
ok(not(a:every(f.part(f.lt, 5))))

a = m.iota(5)
cnt = 0
function check(n)
    cnt = cnt + 1
end
eval[[a:foreach(check)]]
is(cnt, 5)
cnt = ""
function check(x)
    cnt = cnt .. x
end
eval[[a:foreach(check)]]
is(cnt, "01234")

function check(v, i)
    cnt = cnt .. v .. i
end
cnt = ""
eval[[a:each(check)]]
is(cnt, "0112233445")

cnt = 0
function check(v, i, a)
    if type(a) == 'table' then
       cnt = cnt + 1
    end
end
eval[[a:each(check)]]
is(cnt, 5)

is(a:fold(math.max, -1), 4)
is(a:fold(math.max, 5), 5)
is(a:fold(math.min, -1), -1)
is(a:fold(math.min, 5), 0)


b = eval[[a:map(f.part(f.add, 2))]]
isa(b, 'table')
is(#b, 5)
is(b[1], 2)
is(b[3], 4)
is(b[5], 6)

b = eval[[a:filter(function (x) return x % 2 == 0 end)]]
isa(b, 'table')
is(#b, 3)
is(b[1], 0)
is(b[2], 2)
is(b[3], 4)

b = eval[[a:takewhile(f.part(f.gt, 3))]]
isa(b, 'table')
is(#b, 3)
is(b[1], 0)
is(b[2], 1)
is(b[3], 2)

b = eval[[a:takewhile(f.part(f.lt, 3))]]
isa(b, 'table')
is(#b, 0)

b = eval[[a:dropwhile(f.part(f.gt, 5))]]
isa(b, 'table')
is(#b, 0)

b = eval[[a:dropwhile(f.part(f.gt, 3))]]
isa(b, 'table')
is(#b, 2)
is(b[1], 3)
is(b[2], 4)

b = eval[[a:dropwhile(f.part(f.lt, 3))]]
isa(b, 'table')
is(b[1], 0)
is(b[5], 4)

---
summary()
--- tuit/array.t ends
