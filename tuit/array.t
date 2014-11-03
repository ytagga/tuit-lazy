--- tap script - -*- mode:lua -*-
_ = function ()
plan(17)
m = eval[[require 'tuit.array']] or skip_all()
is(m.bless{'a', 'b', 'c'}:count(function(x) return true end), 3)
is_deeply(m.bless{1, 1}:unfold(
            function (x) return #x >= 5 end,
            function (x) return x[#x] + x[#x-1] end,
            function (x) return x end),
            {1, 1, 2, 3, 5})
is_deeply(m.bless():unfold(string.gmatch("a b c", "(%S+)")), {'a', 'b', 'c'})
is_deeply(m.bless():range(1, 5), {1, 2, 3, 4, 5})
is_deeply(m.bless():range(4, 1), {4, 3, 2, 1})
is_deeply(m.bless():range(4, 1, -2), {4, 2})
is(m.bless{'a', 'b', 'c'}:fold(function (r, x) return r .. x end, 'X'), 'Xabc')
is_deeply(m.bless{1, 2, 3}:map(function (x) return x + 1 end), {2, 3, 4})
is_deeply(m.bless{1, 2, 3}:filter(function (x) return x % 2 == 0 end), {2})
is_deeply(m.bless{1, 2, 3}:filter(function (x) return x % 2 ~= 0 end), {1, 3})
x = ''
m.bless{1, 2, 3}:each(function (y) x = x .. y end)
is(x, '123')
x = ''
m.bless{'a', 'b', 'c'}:each_ipair(function (i, v) x = x .. i .. v end)
is(x, '1a2b3c')
function g(x) return x == 3 end
x, y = m.bless{1, 3, 5}:find(g)
is(x, 2)
is(y, 3)
x, y = m.bless{1, 7, 5}:find(g)
is(x, false)
is(y, nil)
is_deeply(m.bless{1, 2, 3}:take(2), {1, 2})
summary()
end
f, v = pcall(_)
if not(f) then bail_out(v) end
