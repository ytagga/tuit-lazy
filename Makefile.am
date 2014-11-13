# Makefile.am

SUBDIRS = tuit aux

LUA = @LUA@

RELEASE = 1

rockspec : $(PACKAGE)-$(VERSION)-$(RELEASE).rockspec

$(PACKAGE)-$(VERSION)-$(RELEASE).rockspec : rockspec.in
	sed -e "s/\@RELEASE\@/$(RELEASE)/; \
		s/\@PACKAGE\@/$(PACKAGE)/; \
                s/\@VERSION\@/$(VERSION)/" $? > $@

clean-local :
	-rm  $(PACKAGE)-$(VERSION)-$(RELEASE).rockspec

check-local :
	LUA_PATH="?.lua;;" $(LUA) $(top_srcdir)/aux/prove.lua tuit/*.t tuit/*/*.t

# Makefile.am ends here
