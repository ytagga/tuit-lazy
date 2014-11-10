# tuit/array/Makefil.am

LUA = @LUA@

tuitarraydir = $(datadir)/lua/$(LUA_VERSION)/@LUA_MODPATH@/array

dist_tuitarray_DATA = lazy.lua

TESTS = $(dist_tuitarray_DATA:.lua=.t)
TEST_EXTENSIONS = .t
T_LOG_COMPILER = $(LUA)
AM_TESTS_ENVIRONMENT = LUA_PATH="../../aux/?.lua;../../?.lua;;" ; export LUA_PATH;
AM_T_LOG_FLAGS = -l tap

EXTRA_DIST = $(TESTS)

MARKDOWN = $(HOME)/bin/markdown.lua
docfiles = lazy.html

.lua.html :
	LUA_PATH="../../aux/?.lua;;" $(LUA) -l scrape -e "doc()" < $? | $(MARKDOWN) > $@

doc : $(docfiles)


.lua.t :
	LUA_PATH="../../aux/?.lua;;" $(LUA) -l scrape -e "tap()" < $? > $@

# tuit/array/Makefil.am ends here
