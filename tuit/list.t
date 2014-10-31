--- tap script - -*- mode:lua -*-
_ = function ()
plan(48)
m = eval[[require 'tuit.list']] or skip_all()
is_deeply(m.list(), {})
is_deeply(m.list(1, 2, 3), {1, 2, 3})
a = {1, 2, 3}
is_deeply(m.list_copy(a), {1, 2, 3})
isnt(m.list_copy(a), a)
y = {1, 1}
is_deeply(m.unfold(function (x) return #x >= 5 end,
                   function (x) return x[#x-1] + x[#x] end,
                   function (x) return x end,
                   y, y), {1, 1, 2, 3, 5})
is(m.fold_left(function (x, y) return x + y end, 0, {1, 2, 3}), 6)
is(m.fold_left(function (x, y) return x .. y end, "A", {}), "A")
is(m.fold_left(function (x, y, z) return x + y - z end, 0, {1, 2, 3}, {4, 5, 6}), -9)
is(m.fold_right(function (x, y) return x + y end, 0, {1, 2, 3}), 6)
is(m.fold_right(function (x, y) return x .. y end, "A", {}), "A")
is(m.fold_right(function (x, y, z) return x + y - z end, 0, {1, 2, 3}, {4, 5, 6}), 7)
is(m.reduce(function (x, y) return x + y end, {1, 2, 3}), 6)
is(m.reduce(function (x, y) return x .. y end, {}), nil)
is(m.reduce(function (x, y) return x .. y end, {'A', 'B'}), 'AB')
is(m.reduce_right(function (x, y) return x + y end, {1, 2, 3}), 6)
is(m.reduce_right(function (x, y) return x .. y end, {}), nil)
is(m.reduce_right(function (x, y) return x .. y end, {'A', 'B'}), 'AB')
is_deeply(m.map(function (x, y, z) return x + y - z end, {1, 2}, {3, 4}, {5, 6}), {-1, 0})
is_deeply(m.filter(function (x) return x % 2 == 0 end, {1, 2, 3, 4}), {2, 4})
x = ''
m.each(function (p, q) x = x .. p .. q end, {1, 2, 3}, {'a', 'b', 'c'})
is(x, "1a2b3c")
x = ''
m.each_ipair(function (p, q) x = x .. p .. q end, {'a', 'b', 'c'})
is(x, "1a2b3c")
function g(x) return x == 3 end
x, y = m.find(g, {1, 3, 5})
is(x, 2)
is(y, 3)
x, y = m.find(g, {1, 7, 5})
is(x, false)
is(y, nil)
is_deeply(m.take({1, 2, 3}, 2), {1, 2})
x = {1, 2, 3}
y = m.drop(x, 2)
is_deeply(y, {3})
is(y, x)
is_deeply(m.take_while(function (x) return x < 3 end, {1, 3, 5}), {1})
is_deeply(m.drop_while(function (x) return x <= 3 end, {1, 3, 5}), {5})
is(m.any(function (x) return x == 2 end, {1, 2, 3}), true)
is(m.any(function (x) return x == 2 end, {1, 3, 5}), false)
is(m.every(function (x) return x == 2 end, {2, 2, 2}), true)
is(m.every(function (x) return x == 2 end, {2, 1, 2}), false)
ok(m.equal(1, 1))
ok(m.equal({{1, 2}, {3}}, {{1, 2}, {3}}))
ok(m.equal({0, {1, 2}}, {0, {1, 2}}))
g = function (x, y) return x - y end
is(m.apply(g, {1, 2}), -1)
is(m.last({1, 2, 3}), 3)
is(m.first({1, 2, 3}), 1)
is(m.length({0, 1, 2}), 3)
is_deeply(m.append({1, 2, 3}, {4}), {1, 2, 3, 4})
is_deeply(m.reverse({1, 2, 3}), {3, 2, 1})
is_deeply(m.reverse({1, 2, 3, 4}), {4, 3, 2, 1})
x = {1, 2, 3}
y = m.reverse(x)
is_deeply(y, {3, 2, 1})
is(y, x)
is_deeply(m.zip({1, 2, 3}, {4, 5, 6}), {{1, 4}, {2, 5}, {3, 6}})
is_deeply(m.flatten({1, {2}, {{3}, 4}}), {1, 2, 3, 4})
summary()
end
f, v = pcall(_)
if not(f) then bail_out(v) end
