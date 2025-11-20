const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ray_tracing",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const render_step = b.step("run", "Render image to src/images/image.ppm");
    
    const mkdir_cmd = b.addSystemCommand(&.{
        "mkdir",
        "-p", "src/images",
    });
    render_step.dependOn(&mkdir_cmd.step);
    
    const render_cmd = b.addSystemCommand(&.{
        "sh",
        "-c",
    });
    
    const exe_path = b.getInstallPath(.bin, exe.name);
    const redirect_command = b.fmt("\"{s}\" > src/images/image.ppm", .{exe_path});

    render_cmd.addArg(redirect_command);
    render_cmd.step.dependOn(b.getInstallStep());
    render_cmd.step.dependOn(&mkdir_cmd.step);
    
    render_step.dependOn(&render_cmd.step);
    
    const info_cmd = b.addSystemCommand(&.{
        "echo",
        "Image written to src/images/image.ppm",
    });
    info_cmd.step.dependOn(&render_cmd.step);
    render_step.dependOn(&info_cmd.step);
}
