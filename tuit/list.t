--- list.t -*- mode:lua -*-
plan(20)

m = eval[[require 'tuit.list']] or skip_all()

is(m.equal(m.list(1, 2, 3), {1, 2, 3}), true)

is(m.equal({1, 2, 3}, {1, 2, 3}), true)
is(m.equal({1, 2, 3}, {1, 2}), false)
is(m.equal({1, 2}, {1, 2, 3}), false)
is(m.equal({1, {2, 3}}, {1, {2, 3}}), true)

is(m.equal(m.append({1}, {2, 3}, {}, {4}), {1, 2, 3, 4}), true)

skip(false)

is(m.equal(m.make_list(3, 'a'), {'a', 'a', 'a'}), true)
is(m.equal(m.make_list(3), {true, true, true}), true)
is(m.equal(m.make_list(0), {}), true)



function id(n) return n end
is(m.equal(m.list_tabulate(4, id), {0, 1, 2, 3}), true)
function db(n) return n * 2 end
is(m.equal(m.list_tabulate(4, db), {0, 2, 4, 6}), true)

a = {1, 2, 3}
ok(m.equal(m.list_copy(a), a))
isnt(m.list_copy(a), a)

is(m.equal(m.iota(3), {0, 1, 2}), true)
is(m.equal(m.iota(3, 1), {1, 2, 3}), true)
is(m.equal(m.iota(3, 1, 2), {1, 3, 5}), true)

function eq(x, y) return x == y end

is(m.list_eq(eq, {1, 2, 3}, {1, 2, 3}), true)
is(m.list_eq(eq, {1, 2, 3}, {1, 2, 4}), false)

is(m.equal(m.flatten({1, {2, {3}}}), {1, 2, 3}), true)

is(m.equal(m.zip({1, 2}, {'a', 'b', 'c'}), {{1, 'a'}, {2, 'b'}}), true)


summary()
