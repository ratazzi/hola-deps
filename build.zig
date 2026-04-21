const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // This package doesn't build anything, it just provides pre-built libraries
    // Create a module that exposes the paths for use by dependent packages
    const hola_deps = b.addModule("hola_deps", .{
        .root_source_file = b.path("root.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = hola_deps;
}

// Expose paths and library configuration to dependent packages
pub fn configureDeps(
    step: *std.Build.Step.Compile,
    b: *std.Build,
    dep: *std.Build.Dependency,
) void {
    const deps_path = dep.path(".").getPath(b);

    // Add include paths
    step.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{deps_path}) });
    step.addIncludePath(.{ .cwd_relative = b.fmt("{s}/mruby/include", .{deps_path}) });

    // Add library paths
    step.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{deps_path}) });
    step.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/mruby/lib", .{deps_path}) });

    // Link all static libraries
    // Core libraries
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libgit2.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libcurl.a", .{deps_path}) });

    // Shared dependencies (OpenSSL, SSH, compression)
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libssl.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libcrypto.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libssh2.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libz.a", .{deps_path}) });

    // curl-specific dependencies
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libnghttp2.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libnghttp3.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libbrotlidec.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libbrotlicommon.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libzstd.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libcares.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libidn2.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libpsl.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libunistring.a", .{deps_path}) });

    // libgit2-specific dependencies
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libpcre2-8.a", .{deps_path}) });
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/lib/libhttp_parser.a", .{deps_path}) });

    // mruby
    step.addObjectFile(.{ .cwd_relative = b.fmt("{s}/mruby/lib/libmruby.a", .{deps_path}) });

    step.linkLibC();
}

// Helper to get paths
pub fn getPaths(b: *std.Build, dep: *std.Build.Dependency) struct {
    mruby: []const u8,
    libgit2: []const u8,
} {
    const deps_path = dep.path(".").getPath(b);
    return .{
        .mruby = b.fmt("{s}/mruby", .{deps_path}),
        .libgit2 = deps_path,
    };
}
