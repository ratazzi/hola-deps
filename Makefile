PREFIX ?= $(PWD)/install
BUILD_DIR ?= $(PWD)/build
NPROC ?= $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

.PHONY: all clean install-dirs zlib openssl libssh2 pcre2 http-parser libgit2 mruby package verify

all: install-dirs zlib openssl libssh2 pcre2 http-parser libgit2 mruby

install-dirs:
	mkdir -p $(PREFIX)/lib $(PREFIX)/include $(BUILD_DIR)

# zlib - foundational dependency
zlib: install-dirs
	@echo "Building zlib..."
	cd deps/zlib && \
		./configure --static --prefix=$(PREFIX) && \
		$(MAKE) -j$(NPROC) && \
		$(MAKE) install

# OpenSSL - crypto library
openssl: install-dirs
	@echo "Building OpenSSL..."
	cd deps/openssl && \
		./config no-shared --prefix=$(PREFIX) --libdir=lib no-tests && \
		$(MAKE) -j$(NPROC) && \
		$(MAKE) install_sw

# libssh2 - depends on OpenSSL and zlib
libssh2: openssl zlib
	@echo "Building libssh2..."
	mkdir -p $(BUILD_DIR)/libssh2 && cd $(BUILD_DIR)/libssh2 && \
		cmake ../../deps/libssh2 \
			-DCMAKE_INSTALL_PREFIX=$(PREFIX) \
			-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
			-DBUILD_SHARED_LIBS=OFF \
			-DBUILD_EXAMPLES=OFF \
			-DBUILD_TESTING=OFF \
			-DOPENSSL_ROOT_DIR=$(PREFIX) \
			-DCRYPTO_BACKEND=OpenSSL && \
		$(MAKE) -j$(NPROC) && \
		$(MAKE) install

# PCRE2 - regex library for libgit2
pcre2: install-dirs
	@echo "Building PCRE2..."
	cd deps/pcre2 && \
		./autogen.sh && \
		./configure --disable-shared --enable-static --prefix=$(PREFIX) && \
		$(MAKE) -j$(NPROC) && \
		$(MAKE) install

# http-parser - HTTP parsing library for libgit2
http-parser: install-dirs
	@echo "Building http-parser..."
	cd deps/http-parser && \
		$(MAKE) package && \
		cp libhttp_parser.a $(PREFIX)/lib/ && \
		cp http_parser.h $(PREFIX)/include/

# libgit2 - depends on OpenSSL, libssh2, zlib, pcre2, http-parser
libgit2: openssl libssh2 zlib pcre2 http-parser
	@echo "Building libgit2..."
	mkdir -p $(BUILD_DIR)/libgit2 && cd $(BUILD_DIR)/libgit2 && \
		cmake ../../deps/libgit2 \
			-DCMAKE_INSTALL_PREFIX=$(PREFIX) \
			-DCMAKE_PREFIX_PATH=$(PREFIX) \
			-DBUILD_SHARED_LIBS=OFF \
			-DBUILD_TESTS=OFF \
			-DBUILD_CLI=OFF \
			-DUSE_SSH=ON \
			-DOPENSSL_ROOT_DIR=$(PREFIX) \
			-DUSE_HTTPS=OpenSSL \
			-DREGEX_BACKEND=pcre2 \
			-DUSE_GSSAPI=OFF \
			-DUSE_NTLMCLIENT=OFF \
			-DUSE_ICONV=OFF && \
		$(MAKE) -j$(NPROC) && \
		$(MAKE) install

# mruby - Ruby VM library
mruby: install-dirs
	@echo "Building mruby..."
	cd deps/mruby && \
		rake && \
		mkdir -p $(PREFIX)/mruby/lib $(PREFIX)/mruby/include && \
		cp -r build/host/lib $(PREFIX)/mruby/ && \
		cp -r include $(PREFIX)/mruby/

# Verify all libraries are built for the correct architecture
verify:
	@echo "Verifying built libraries..."
	@echo "=== Static Libraries ==="
	@find $(PREFIX)/lib -name "*.a" -exec file {} \;
	@echo ""
	@echo "=== mruby Libraries ==="
	@find $(PREFIX)/mruby/lib -name "*.a" -exec file {} \;

# Package artifacts for distribution
package: verify
	@echo "Packaging artifacts..."
	# Copy build files to install directory for packaging
	cp build.zig.zon build.zig root.zig $(PREFIX)/
	tar czf hola-deps-$$(uname -m)-$$(uname -s | tr '[:upper:]' '[:lower:]').tar.gz \
		-C $(PREFIX) \
		build.zig.zon build.zig root.zig include lib mruby
	@echo "Package created: hola-deps-$$(uname -m)-$$(uname -s | tr '[:upper:]' '[:lower:]').tar.gz"

clean:
	rm -rf $(BUILD_DIR) $(PREFIX) *.tar.gz
	cd deps/openssl && git clean -fdx || true
	cd deps/zlib && git clean -fdx || true
	cd deps/libssh2 && git clean -fdx || true
	cd deps/pcre2 && git clean -fdx || true
	cd deps/http-parser && git clean -fdx || true
	cd deps/libgit2 && git clean -fdx || true
	cd deps/mruby && git clean -fdx || true
