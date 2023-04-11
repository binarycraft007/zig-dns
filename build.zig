const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("dns", .{
        .source_file = .{ .path = "src/dns.zig" },
    });

    const network_pkg = b.dependency("network", .{
        .target = target,
        .optimize = optimize,
    });

    const network_module = network_pkg.module("network");

    const exe = b.addExecutable(.{
        .name = "zig-dns",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("dns", module);
    exe.addModule("network", network_module);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/dns.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe_tests.addModule("network", network_module);

    const tests_cmd = exe_tests.run();
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&tests_cmd.step);
}
