# tuit/Makefil.am

SUBDIRS = array

LUA = LUA_PATH="$(top_srcdir)/?.lua;;" @LUA@

tuitdir = $(datadir)/lua/$(LUA_VERSION)/@LUA_MODPATH@

dist_tuit_DATA = combine.lua array.lua list.lua

tests = $(dist_tuit_DATA:.lua=.t)

EXTRA_DIST = $(tests) tap.lua cmdline.lua

check-local : $(tests)

.lua.t :
	$(LUA) $(top_srcdir)/aux/scrape.lua --tap $? > $@

distclean-local :
	-rm $(tests)

# tuit/Makefil.am ends here
