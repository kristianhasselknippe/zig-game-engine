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

    

    const test_step = b.step("test", "Test the app");
    const cglmTests = b.addTest("./src/cglm.zig");
    test_step.dependOn(&cglmTests.step);

    test_step.dependOn(b.getInstallStep());
}
