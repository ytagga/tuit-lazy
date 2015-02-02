# doc/Makefile.am

htmlfiles = index.html
htmlfiles += tuit-array.html tuit-list.html tuit-combine.html
htmlfiles += tuit-array-lazy.html

index.html : ../README.md
	sed -e s!\(doc/!\(! $? | markdown.lua --title "README" > $@

tuit-%.html : ../tuit/%.lua
	LUA_PATH="../?.lua;;" lua ../aux/scrape.lua -d $? | markdown.lua --title $? > $@

tuit-array-%.html : ../tuit/array/%.lua
	LUA_PATH="../?.lua;;" lua ../aux/scrape.lua -d $? | markdown.lua --title $? > $@

html-local : $(htmlfiles)

distclean-local :
	-rm $(htmlfiles)

# doc/Makefile.am ends here
