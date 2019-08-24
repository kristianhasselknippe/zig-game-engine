const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zig-open-gl", "src/main.zig");
    exe.setBuildMode(mode);

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("glfw");
    exe.linkSystemLibrary("epoxy");
    exe.linkSystemLibrary("assimp");
    exe.linkSystemLibrary("cglm");
    if (builtin.os == builtin.Os.linux) {
        exe.linkSystemLibrary("unwind");
    }

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    {
        var t = b.addTest("test.zig");
        t.linkSystemLibrary("c");
        t.linkSystemLibrary("glfw");
        t.linkSystemLibrary("epoxy");
        t.linkSystemLibrary("assimp");
        t.linkSystemLibrary("cglm");
        const test_step = b.step("test", "Run all tests");
        test_step.dependOn(&t.step);
    }

}
