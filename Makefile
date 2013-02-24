# General Makefile for paroli-server

COFFEE_FILES := $(wildcard *.coffee)
COFFEE_JS := ${COFFEE_FILES:.coffee=.js}

.PHONY: all clean distclean install uninstall

all: $(COFFEE_JS)
	./utils/makeexe.sh install.js start.js

%.js: %.coffee
	coffee -c $<

clean:
	@- rm $(COFFEE_JS)

distclean: clean

install: all
	./install.js

uninstall:
	@- rm -rf data


