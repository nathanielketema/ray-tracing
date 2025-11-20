const std = @import("std");
const assert = std.debug.assert;
const Io = std.Io;

const vec3 = @import("vector.zig");
const color = @import("color.zig");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const image_width = 256;
    const image_height = 256;

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.log.info("\rScanlines remaining: {d} ", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_color = color.Color.init(
                @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(image_width - 1)),
                @as(f64, @floatFromInt(j)) / @as(f64, @floatFromInt(image_height - 1)),
                0.0,
            );
            try color.write(stdout, pixel_color);
        }
    }
    std.log.info("\rDone.                 \n", .{});

    try stdout.flush();
}
