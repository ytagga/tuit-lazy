--- tap script - -*- mode:lua -*-
_ = function ()
plan(6)
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
summary()
end
f, v = pcall(_)
if not(f) then bail_out(v) end
