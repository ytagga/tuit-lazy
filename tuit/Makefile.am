# tuit/Makefil.am

SUBDIRS = array

LUA = LUA_PATH="../?.lua;;" @LUA@

tuitdir = $(datadir)/lua/$(LUA_VERSION)/@LUA_MODPATH@

dist_tuit_DATA = combine.lua array.lua list.lua

EXTRA_DIST = $(dist_tuit_DATA:.lua=.t)

MARKDOWN = $(HOME)/bin/markdown.lua
docfiles = combine.html list.html array.html

.lua.html :
	$(LUA) -l scrape -e "doc()" < $? | $(MARKDOWN) > $@

doc : $(docfiles)

check-local : $(EXTRA_DIST)

.lua.t :
	$(LUA) -l tuit.tap -e "tuit.tap.scrape()" < $? > $@

# tuit/Makefil.am ends here
