const std = @import("std");
const Vec3 = @import("vector.zig").Vec3;

pub const Color = Vec3;

/// Write a pixel color to a PPM image format output stream.
pub fn write(writer: *std.Io.Writer, pixel_color: Color) !void {
    const red = pixel_color.x;
    const green = pixel_color.y;
    const blue = pixel_color.z;

    // We use 255.999 to ensure that 1.0 maps to 255, not 254.
    const red_byte: u8 = @intFromFloat(255.999 * red);
    const green_byte: u8 = @intFromFloat(255.999 * green);
    const blue_byte: u8 = @intFromFloat(255.999 * blue);

    try writer.print("{d} {d} {d}\n", .{
        red_byte,
        green_byte,
        blue_byte,
    });
}
