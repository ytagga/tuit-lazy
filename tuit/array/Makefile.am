# tuit/array/Makefil.am

LUA = LUA_PATH="$(top_srcdir)/?.lua;;" @LUA@

tuitarraydir = $(datadir)/lua/$(LUA_VERSION)/@LUA_MODPATH@/array

dist_tuitarray_DATA = lazy.lua nonce.lua

tests = $(dist_tuitarray_DATA:.lua=.t)

EXTRA_DIST = $(tests)

check-local : $(tests)

.lua.t :
	$(LUA) $(top_srcdir)/aux/scrape.lua --tap $? > $@

distclean-local :
	-rm $(tests)

# tuit/array/Makefil.am ends here
