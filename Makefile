# ==========================================
# Template
# ==========================================

CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -fPIC
LDFLAGS = 

SRCDIR = src
INCDIR = include
LIBDIR = lib
BINDIR = bin
BUILDDIR = build

TARGET = main
STATIC_LIB = lib_static.a
SHARED_LIB = lib_dynamic.so

# ==========================================

MAIN_SRC = $(SRCDIR)/main.c
MAIN_OBJ = $(BUILDDIR)/main.o

# Static_lib
STATIC_SRCS = $(SRCDIR)/static_lib/static.c
STATIC_OBJS = $(patsubst $(SRCDIR)/%.c, $(BUILDDIR)/%.o, $(STATIC_SRCS))

# Dynamic lib
SHARED_SRCS = $(SRCDIR)/dynamic_lib/dynamic.c
SHARED_OBJS = $(patsubst $(SRCDIR)/%.c, $(BUILDDIR)/%.o, $(SHARED_SRCS))

# Includes
INC = -I$(INCDIR) -I$(INCDIR)/static_lib -I$(INCDIR)/shared_lib

# ==========================================

$(BUILDDIR):
	mkdir -p $(BUILDDIR)/static_lib $(BUILDDIR)/shared_lib

$(BINDIR):
	mkdir -p $(BINDIR)

$(LIBDIR):
	mkdir -p $(LIBDIR)

# ==========================================
# Targets
# ==========================================

all: directories $(BINDIR)/$(TARGET)

directories: $(BUILDDIR) $(BINDIR) $(LIBDIR)

$(LIBDIR)/$(STATIC_LIB): $(STATIC_OBJS) | $(LIBDIR)
	ar rcs $@ $^

$(LIBDIR)/$(SHARED_LIB): $(SHARED_OBJS) | $(LIBDIR)
	$(CC) -shared $^ -o $@

$(MAIN_OBJ): $(MAIN_SRC) | $(BUILDDIR)
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

$(BUILDDIR)/static_lib/%.o: $(SRCDIR)/static_lib/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

$(BUILDDIR)/shared_lib/%.o: $(SRCDIR)/shared_lib/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

$(BINDIR)/$(TARGET): $(MAIN_OBJ) $(LIBDIR)/$(STATIC_LIB) $(LIBDIR)/$(SHARED_LIB)
	$(CC) $(MAIN_OBJ) -L$(LIBDIR) -lstatic -ldynamic -o $@ -Wl,-rpath,$(LIBDIR)

# ==========================================

build: all

clean:
	rm -rf $(BUILDDIR)

distclean: clean
	rm -rf $(BINDIR) $(LIBDIR)

rebuild: distclean all

install: all
	sudo cp $(BINDIR)/$(TARGET) /usr/local/bin/
	sudo cp $(LIBDIR)/$(SHARED_LIB) /usr/local/lib/
	sudo cp $(LIBDIR)/$(STATIC_LIB) /usr/local/lib/
	sudo ldconfig

uninstall:
	sudo rm -f /usr/local/bin/$(TARGET)
	sudo rm -f /usr/local/lib/$(SHARED_LIB)
	sudo rm -f /usr/local/lib/$(STATIC_LIB)
	sudo ldconfig

# ==========================================

.PHONY: all build clean distclean rebuild install uninstall directories
