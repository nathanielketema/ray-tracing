const std = @import("std");

const vector = @import("vector.zig");
const Vec3 = vector.Vec3;
const Point3 = vector.Point3;

/// A ray in 3D space, defined by an origin point and a direction vector.
/// In ray tracing, rays are cast from the camera through pixels into the scene.
/// The ray equation is: P(t) = origin + t * direction
/// where t is a scalar parameter (distance along the ray).
pub const Ray = extern struct {
    origin: Point3,
    direction: Vec3,

    pub fn init_zero() Ray {
        return Ray{
            .origin = Point3.init_zero(),
            .direction = Vec3.init_zero(),
        };
    }

    pub fn init(ray_origin: Point3, ray_direction: Vec3) Ray {
        return Ray{
            .origin = ray_origin,
            .direction = ray_direction,
        };
    }

    /// Get a point along the ray at parameter t.
    /// Returns: origin + t * direction
    /// 
    /// Examples:
    /// - t = 0.0 returns the origin
    /// - t = 1.0 returns origin + direction
    /// - t < 0.0 gives points behind the origin (opposite direction)
    pub fn at(self: Ray, t: f64) Point3 {
        return vector.add(self.origin, vector.scale(self.direction, t));
    }
};
