# tuit/array/Makefil.am

LUA = LUA_PATH="../../?.lua;;" @LUA@

tuitarraydir = $(datadir)/lua/$(LUA_VERSION)/@LUA_MODPATH@/array

dist_tuitarray_DATA = lazy.lua

EXTRA_DIST = $(dist_tuitarray_DATA:.lua=.t)

MARKDOWN = $(HOME)/bin/markdown.lua
docfiles = lazy.html

.lua.html :
	$(LUA) -l scrape -e "doc()" < $? | $(MARKDOWN) > $@

doc : $(docfiles)

check-local : $(EXTRA_DIST)

.lua.t :
	$(LUA) -l tuit.tap -e "tuit.tap.scrape()" < $? > $@

# tuit/array/Makefil.am ends here
