# Makefile.am

SUBDIRS = tuit

EXTRA_DIST = aux/tap.lua

LUA = @LUA@

RELEASE = 1

rock : $(PACKAGE)-$(VERSION)-$(RELEASE).rockspec

$(PACKAGE)-$(VERSION)-$(RELEASE).rockspec : rockspec
	sed -e 's/@RELEASE@/$(RELEASE)/' $? > $@

# Makefile.am ends here
