# General Makefile for paroli-server

#COFFEE_FILES := $(wildcard *.coffee)
COFFEE_FILES = $(wildcard src/*.coffee)
#COFFEE_JS := ${COFFEE_FILES:.coffee=.js}
COFFEE_JS = $(patsubst src/%.coffee, build/%.js, $(COFFEE_FILES))

.PHONY: all clean distclean install uninstall start docs

all: $(COFFEE_JS)
	@- ./utils/makeexe.sh install.js start.js admin.js
	@- rm -f ./build/node_modules
	@- ln -s ../node_modules ./build/node_modules

build/%.js: src/%.coffee
	coffee -o build -c $<
	@- docco $< > /dev/null

clean:
	@- rm -rf ./build
#	@- rm $(COFFEE_JS)

distclean: clean

install: all
	./build/install.js

uninstall:
	@- rm -rf data

docs:
	@- docco $(COFFEE_FILES)

start: all
	./build/start.js

testjohn:
	./build/admin.js removeuser john
	./build/admin.js adduser john


