# General Makefile for paroli-server

COFFEE_FILES := $(wildcard *.coffee)
COFFEE_JS := ${COFFEE_FILES:.coffee=.js}

.PHONY: all clean distclean install uninstall start docs

all: $(COFFEE_JS)
	./utils/makeexe.sh install.js start.js admin.js

%.js: %.coffee
	coffee -c $<
	@- docco $< > /dev/null

clean:
	@- rm $(COFFEE_JS)

distclean: clean

install: all
	./install.js

uninstall:
	@- rm -rf data

docs:
	@- docco $(COFFEE_FILES)

start: all
	./start.js

testjohn:
	./admin.js removeuser john
	./admin.js adduser john


