LISTNAME=easylist.txt
PREFIX ?= /usr/local/
EXTENSION_DIR ?= $(PREFIX)/lib/wyebrowser
ifeq ($(DEBUG), 1)
	CFLAGS += -Wall -g -Iinclude
else
	DEBUG = 0
	CFLAGS += -Wno-deprecated-declarations -Iinclude
endif
DDEBUG=-DDEBUG=${DEBUG}

all: build lib/adblock.so bin/wyebab build/librun.o bin/testrun

PHONY:
build:
	mkdir build
	mkdir bin
	mkdir lib

lib/adblock.so: src/ab.c src/ephy-uri-tester.c build/librun.o Makefile
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< build/librun.o -shared -fPIC \
		`pkg-config --cflags --libs gtk+-3.0 glib-2.0 webkit2gtk-4.1` \
		$(DDEBUG) -DISEXT -DEXENAME=\"wyebab\"

bin/wyebab: src/ab.c src/ephy-uri-tester.c build/librun.o Makefile
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< build/librun.o \
		`pkg-config --cflags --libs glib-2.0 gio-2.0` \
		$(DDEBUG) -DDIRNAME=\"wyebadblock\" -DLISTNAME=\"$(LISTNAME)\"

build/librun.o: src/wyebrun.c Makefile
	$(CC) $(CFLAGS) $(LDFLAGS) -c -o $@ $< -fPIC\
		`pkg-config --cflags --libs glib-2.0` \
		$(DDEBUG)

bin/testrun: src/wyebrun.c Makefile
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< \
		`pkg-config --cflags --libs glib-2.0 gio-2.0` \
		$(DDEBUG) -DTESTER=1

clean:
	rm -rf build
	rm -rf bin
	rm -rf lib

install:
	install -Dm755 bin/wyebab     $(DESTDIR)$(PREFIX)/bin/wyebab
	install -Dm755 lib/adblock.so $(DESTDIR)$(EXTENSION_DIR)/adblock.so

uninstall:
	rm -f  $(PREFIX)/bin/wyebab
	rm -f  $(EXTENSION_DIR)/adblock.so
	-rmdir $(EXTENSION_DIR)


re: clean all
#	$(MAKE) clean
#	$(MAKE) all

full: re install
