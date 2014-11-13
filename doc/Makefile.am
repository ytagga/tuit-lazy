# doc/Makefile.am

htmlfiles = index.html tuit-array.html tuit-list.html tuit-combine.html tuit-array-lazy.html

index.html : ../README.md
	sed -e s!\(doc/!\(! $? | markdown.lua --title "README" > $@

tuit-%.html : ../tuit/%.lua
	LUA_PATH="../?.lua;;" lua ../aux/scrape.lua -d $? | markdown.lua > $@

tuit-array-%.html : ../tuit/array/%.lua
	LUA_PATH="../?.lua;;" lua ../aux/scrape.lua -d $? | markdown.lua > $@

html-local : $(htmlfiles)

distclean-local :
	-rm $(htmlfiles)

# doc/Makefile.am ends here
