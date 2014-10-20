# Makefile (will be Makefile.am)

LUA = lua

check:
	LUA_PATH="./aux/?.lua;;" prove -e "$(LUA) -ltap" tuit/*.t

clean:
	-rm *~
	-rm tuit/*~

# Makefile.am ends here
