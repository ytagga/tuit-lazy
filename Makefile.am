# Makefile.am

SUBDIRS = tuit

EXTRA_DIST = aux/tap.lua

LUA = @LUA@

PROVE = @PROVE@

RELEASE = 1

rockspec : $(PACKAGE)-$(VERSION)-$(RELEASE).rockspec

$(PACKAGE)-$(VERSION)-$(RELEASE).rockspec : rockspec.in
	sed -e "s/\@RELEASE\@/$(RELEASE)/; \
		s/\@PACKAGE\@/$(PACKAGE)/; \
                s/\@VERSION\@/$(VERSION)/" $? > $@

clean-local :
	-rm  $(PACKAGE)-$(VERSION)-$(RELEASE).rockspec

check-local :
	LUA_PATH="aux/?.lua;?.lua;;" $(PROVE) -e "$(LUA) -l tuit.tap" tuit/*.t tuit/*/*.t

# Makefile.am ends here
