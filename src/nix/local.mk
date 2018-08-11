programs += nix

nix_DIR := $(d)

nix_SOURCES := $(wildcard $(d)/*.cc)

nix_LIBS = libexpr libmain libstore libutil libformat

nix_LDFLAGS = -lreadline -pthread

$(eval $(call install-symlink, nix, $(bindir)/nix-hash))
