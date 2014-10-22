# Makefile.am

SUBDIRS = tuit

EXTRA_DIST = aux/tap.lua

LUA = @LUA@

RELEASE = 1

rockspec : $(PACKAGE)-$(VERSION)-$(RELEASE).rockspec

$(PACKAGE)-$(VERSION)-$(RELEASE).rockspec : rockspec.in
	sed -e "s/\@RELEASE\@/$(RELEASE)/; \
		s/\@PACKAGE\@/$(PACKAGE)/; \
                s/\@VERSION\@/$(VERSION)/" $? > $@

clean-local :
	-rm  $(PACKAGE)-$(VERSION)-$(RELEASE).rockspec

# Makefile.am ends here
