--- tap script - -*- mode:lua -*-
_ = function ()
plan(7)
m = eval[[require 'tuit.lazy']] or skip_all()
is_deeply(m.unfold(
            function (x) return false end,
            function (x) return x[#x] + x[#x-1] end,
            function (x) return x end,
            {1, 1}):take(5),
            {1, 1, 2, 3, 5})
is_deeply(m.unfold(string.gmatch("a b c", "(%S+)")), {'a', 'b', 'c'})
is_deeply(m.range(1, math.huge):take(5), {1, 2, 3, 4, 5})
is_deeply(m.range(1, math.huge):map(function (x) return x * 2 end):take(5), {2, 4, 6, 8, 10})
is_deeply(m.range(1, math.huge):filter(function (x) return x % 2 == 0 end):take(5), {2, 4, 6, 8, 10})
is_deeply(m.range(1, math.huge):drop(3):take(5), {4, 5, 6, 7, 8})
is_deeply(m.range(1, math.huge):drop_while(function (x) return x < 3 end):take(5), {3, 4, 5, 6, 7})
summary()
end
f, v = pcall(_)
if not(f) then bail_out(v) end
