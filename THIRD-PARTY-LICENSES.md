# Third-Party Licenses

This project includes the following third-party dependencies as git submodules. Each dependency retains its original license.

## Dependencies

### http-parser (v2.9.0)
- **License**: MIT License
- **Copyright**: Joyent, Inc. and other Node contributors
- **Location**: `deps/http-parser/`
- **License File**: `deps/http-parser/LICENSE-MIT`

### mruby
- **License**: MIT License
- **Copyright**: mruby developers
- **Location**: `deps/mruby/`
- **License File**: `deps/mruby/LICENSE`

### zlib (v1.3.1)
- **License**: Zlib License
- **Copyright**: Jean-loup Gailly and Mark Adler
- **Location**: `deps/zlib/`
- **License File**: `deps/zlib/LICENSE`
- **Notes**: Very permissive license similar to MIT/BSD

### libssh2 (1.11.0)
- **License**: BSD 3-Clause License
- **Copyright**: Multiple contributors (see COPYING for details)
- **Location**: `deps/libssh2/`
- **License File**: `deps/libssh2/COPYING`

### pcre2 (10.42)
- **License**: BSD License
- **Copyright**: University of Cambridge, Zoltan Herczeg
- **Location**: `deps/pcre2/`
- **License File**: `deps/pcre2/LICENCE`

### openssl (3.6.0)
- **License**: Apache License 2.0
- **Copyright**: The OpenSSL Project
- **Location**: `deps/openssl/`
- **License File**: `deps/openssl/LICENSE.txt`

### libgit2
- **License**: GPLv2 with Linking Exception
- **Copyright**: libgit2 contributors
- **Location**: `deps/libgit2/`
- **License File**: `deps/libgit2/COPYING`
- **Notes**: The linking exception permits linking this library with any program regardless of that program's license

## License Compatibility

All dependencies are compatible with this project's MIT License:
- MIT, BSD, and Zlib licenses are permissive and fully compatible
- Apache 2.0 is compatible with MIT for distribution
- libgit2's GPLv2 with Linking Exception explicitly permits linking without GPL requirements

## Full License Texts

For the complete text of each dependency's license, please refer to the license files in their respective directories under `deps/`.
