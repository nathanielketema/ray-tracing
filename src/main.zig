const std = @import("std");
const assert = std.debug.assert;
const Io = std.Io;

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const image_width = 256;
    const image_height = 256;

    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});

    for (0..image_height) |j| {
        for (0..image_width) |i| {
            const r: f64 = @as(f64, @floatFromInt(i)) / (image_width - 1);
            const g: f64 = @as(f64, @floatFromInt(j)) / (image_height - 1);
            const b: f64 = 0.0;

            const ir: i32 = @intFromFloat(255.999 * r);
            const ig: i32 = @intFromFloat(255.999 * g);
            const ib: i32 = @intFromFloat(255.999 * b);

            try stdout.print("{d} {d} {d}\n", .{ir, ig, ib});
        }
    }

    try stdout.flush();
}
