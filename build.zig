const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});

    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    exe_mod.addIncludePath(upstream.path("."));

    exe_mod.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = source_files,
        .flags = c_flags,
    });
    exe_mod.linkSystemLibrary("rt", .{});

    switch (target.result.os.tag) {
        .linux => {
            exe_mod.addCSourceFile(.{
                .file = upstream.path("os-posix.c"),
                .flags = c_flags,
            });
        },
        else => {
            std.debug.print(
                "Can't build for {s} yet!\n",
                .{@tagName(target.result.os.tag)},
            );
            return;
        },
    }

    const exe = b.addExecutable(.{
        .name = "samu",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);
}

const c_flags: []const []const u8 = &.{
    "-std=c99",
    "-Wall",
    "-Wextra",
    "-Wshadow",
    "-Wmissing-prototypes",
    "-Wpedantic",
    "-Wno-unused-parameter",
};

const source_files: []const []const u8 = &.{
    "build.c",
    "deps.c",
    "env.c",
    "graph.c",
    "htab.c",
    "log.c",
    "parse.c",
    "samu.c",
    "scan.c",
    "tool.c",
    "tree.c",
    "util.c",
};
