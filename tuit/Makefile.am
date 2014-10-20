# tuit/Makefil.am

LUA = @LUA@

tuitdir = $(datadir)/lua/$(LUA_VERSION)/@LUA_MODPATH@

dist_tuit_DATA = combine.lua array.lua lazy.lua list.lua

TESTS = $(dist_tuit_DATA:.lua=.t)
TEST_EXTENSIONS = .t
T_LOG_COMPILER = $(LUA)
AM_TESTS_ENVIRONMENT = LUA_PATH="../aux/?.lua;../?.lua;;" ; export LUA_PATH;
AM_T_LOG_FLAGS = -l tap

EXTRA_DIST = $(TESTS)

# tuit/Makefil.am ends here
