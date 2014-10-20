# Makefile.am

SUBDIRS = tuit

EXTRA_DIST = aux/tap.lua

LUA = @LUA@
PROVE = @PROVE@

check:
	LUA_PATH="./aux/?.lua;;" $(PROVE) -e "$(LUA) -ltap" tuit/*.t

# Makefile.am ends here
