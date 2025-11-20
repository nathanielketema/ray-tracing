const std = @import("std");
const assert = std.debug.assert;
const testing = std.testing;
const PRNG = std.Random.DefaultPrng;

pub const Point3 = Vec3;

/// A 3D vector for representing points, directions, and colors in ray tracing.
/// In ray tracing, this type serves multiple purposes:
/// - Geometric points in 3D space (x, y, z coordinates)
/// - Direction vectors (for rays, surface normals, etc.)
/// - RGB color values (red, green, blue components)
pub const Vec3 = extern struct {
    x: f64,
    y: f64,
    z: f64,

    /// Initialize a vector with all components set to init_zero.
    pub fn init_zero() Vec3 {
        return .{
            .x = 0.0,
            .y = 0.0,
            .z = 0.0,
        };
    }

    /// Initialize a vector with specific x, y, z components.
    pub fn init(x_value: f64, y_value: f64, z_value: f64) Vec3 {
        return .{
            .x = x_value,
            .y = y_value,
            .z = z_value,
        };
    }

    pub fn negate(self: Vec3) Vec3 {
        return .{
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
        };
    }

    /// Compute the magnitude squared of the vector.
    pub fn length_squared(self: Vec3) f64 {
        return self.x * self.x +
            self.y * self.y +
            self.z * self.z;
    }

    /// Compute the magnitude of the vector.
    pub fn length(self: Vec3) f64 {
        return @sqrt(self.length_squared());
    }

    pub fn format(self: Vec3, writer: std.Io.Writer) !void {
        try writer.print("{d} {d} {d}\n", .{ self.x, self.y, self.z });
    }
};

pub fn add(vector_a: Vec3, vector_b: Vec3) Vec3 {
    return .{
        .x = vector_a.x + vector_b.x,
        .y = vector_a.y + vector_b.y,
        .z = vector_a.z + vector_b.z,
    };
}

/// Subtract vector_b from vector_a component-wise.
pub fn sub(vector_a: Vec3, vector_b: Vec3) Vec3 {
    return .{
        .x = vector_a.x - vector_b.x,
        .y = vector_a.y - vector_b.y,
        .z = vector_a.z - vector_b.z,
    };
}

/// Multiply two vectors component-wise (Hadamard product).
/// This is NOT the dot product or cross product!
/// Used for color blending in ray tracing.
pub fn mul(vector_a: Vec3, vector_b: Vec3) Vec3 {
    return Vec3{
        .x = vector_a.x * vector_b.x,
        .y = vector_a.y * vector_b.y,
        .z = vector_a.z * vector_b.z,
    };
}

/// Multiply by a scalar.
pub fn scale(vector: Vec3, scalar: f64) Vec3 {
    return Vec3{
        .x = scalar * vector.x,
        .y = scalar * vector.y,
        .z = scalar * vector.z,
    };
}

/// Divide by a scalar.
pub fn div(vector: Vec3, scalar: f64) Vec3 {
    assert(scalar != 0);
    return scale(vector, 1.0 / scalar);
}

/// Same direction returns:
/// - 0 if perpendicular,
/// - positive if same direction,
/// - negative if opposite directions.
pub fn dot_product(vector_a: Vec3, vector_b: Vec3) f64 {
    return vector_a.x * vector_b.x +
        vector_a.y * vector_b.y +
        vector_a.z * vector_b.z;
}

/// Returns a vector perpendicular to both input vectors.
/// Direction follows the right-hand rule.
pub fn cross_product(vector_a: Vec3, vector_b: Vec3) Vec3 {
    return .{
        .x = (vector_a.y * vector_b.z) - (vector_a.z * vector_b.y),
        .y = (vector_a.z * vector_b.x) - (vector_a.x * vector_b.z),
        .z = (vector_a.x * vector_b.y) - (vector_a.y * vector_b.x),
    };
}

/// Return a unit vector pointing in the same direction as vector.
pub fn unit(vector: Vec3) Vec3 {
    return div(vector, vector.length());
}

fn random_vec3(prng: *PRNG, min: f64, max: f64) Vec3 {
    const random = prng.random();
    return Vec3{
        .x = min + random.float(f64) * (max - min),
        .y = min + random.float(f64) * (max - min),
        .z = min + random.float(f64) * (max - min),
    };
}

/// useful for division tests
fn random_nonzero(prng: *PRNG, min: f64, max: f64) Vec3 {
    while (true) {
        const vector = random_vec3(prng, min, max);
        if (vector.length_squared() > 1e-10) {
            return vector;
        }
    }
}

test "property: vector addition is commutative" {
    // Property: a + b = b + a for all vectors a, b
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector_a = random_vec3(&prng, -100.0, 100.0);
        const vector_b = random_vec3(&prng, -100.0, 100.0);

        const result_ab = add(vector_a, vector_b);
        const result_ba = add(vector_b, vector_a);

        try testing.expectApproxEqAbs(result_ab.x, result_ba.x, 1e-10);
        try testing.expectApproxEqAbs(result_ab.y, result_ba.y, 1e-10);
        try testing.expectApproxEqAbs(result_ab.z, result_ba.z, 1e-10);
    }
}

test "property: zero is additive identity" {
    // Property: a + 0 = a for all vectors a
    var prng: PRNG = .init(testing.random_seed);

    const zero = Vec3.init_zero();
    for (0..1000) |_| {
        const vector = random_vec3(&prng, -100.0, 100.0);
        const result = add(vector, zero);

        try testing.expectApproxEqAbs(result.x, vector.x, 1e-10);
        try testing.expectApproxEqAbs(result.y, vector.y, 1e-10);
        try testing.expectApproxEqAbs(result.z, vector.z, 1e-10);
    }
}

test "property: scalar multiplication distributes over addition" {
    // Property: k * (a + b) = k * a + k * b for all vectors a, b and scalar k
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector_a = random_vec3(&prng, -100.0, 100.0);
        const vector_b = random_vec3(&prng, -100.0, 100.0);
        const scalar = prng.random().float(f64) * 200.0 - 100.0;

        const result_left = scale(add(vector_a, vector_b), scalar);
        const result_right = add(
            scale(vector_a, scalar),
            scale(vector_b, scalar),
        );

        try testing.expectApproxEqAbs(result_left.x, result_right.x, 1e-8);
        try testing.expectApproxEqAbs(result_left.y, result_right.y, 1e-8);
        try testing.expectApproxEqAbs(result_left.z, result_right.z, 1e-8);
    }
}

test "property: dot product is commutative" {
    // Property: a · b = b · a for all vectors a, b
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector_a = random_vec3(&prng, -100.0, 100.0);
        const vector_b = random_vec3(&prng, -100.0, 100.0);

        const dot_ab = dot_product(vector_a, vector_b);
        const dot_ba = dot_product(vector_b, vector_a);

        try testing.expectApproxEqAbs(dot_ab, dot_ba, 1e-10);
    }
}

test "property: dot product with self equals length squared" {
    // Property: a · a = |a|² for all vectors a
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector = random_vec3(&prng, -100.0, 100.0);

        const dot_self = dot_product(vector, vector);
        const length_sq = vector.length_squared();

        try testing.expectApproxEqAbs(dot_self, length_sq, 1e-10);
    }
}

test "property: unit vector has length 1" {
    // Property: |unit(a)| = 1 for all non-zero vectors a
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector = random_nonzero(&prng, -100.0, 100.0);
        const unit_vector = unit(vector);

        const length = unit_vector.length();
        try testing.expectApproxEqAbs(length, 1.0, 1e-10);
    }
}

test "property: cross product is perpendicular to both vectors" {
    // Property: (a × b) · a = 0 and (a × b) · b = 0 for all vectors a, b
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector_a = random_vec3(&prng, -100.0, 100.0);
        const vector_b = random_vec3(&prng, -100.0, 100.0);

        const cross_prd = cross_product(vector_a, vector_b);

        const dot_with_a = dot_product(cross_prd, vector_a);
        const dot_with_b = dot_product(cross_prd, vector_b);

        // Allow larger tolerance because cross product can magnify errors
        try testing.expectApproxEqAbs(dot_with_a, 0.0, 1e-8);
        try testing.expectApproxEqAbs(dot_with_b, 0.0, 1e-8);
    }
}

test "property: cross product anti-commutative" {
    // Property: a × b = -(b × a) for all vectors a, b
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector_a = random_vec3(&prng, -100.0, 100.0);
        const vector_b = random_vec3(&prng, -100.0, 100.0);

        const cross_ab = cross_product(vector_a, vector_b);
        const cross_ba = cross_product(vector_b, vector_a);
        const neg_cross_ba = cross_ba.negate();

        try testing.expectApproxEqAbs(cross_ab.x, neg_cross_ba.x, 1e-10);
        try testing.expectApproxEqAbs(cross_ab.y, neg_cross_ba.y, 1e-10);
        try testing.expectApproxEqAbs(cross_ab.z, neg_cross_ba.z, 1e-10);
    }
}

test "property: double negation returns original" {
    // Property: -(-a) = a for all vectors a
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const vector = random_vec3(&prng, -100.0, 100.0);
        const double_negated = vector.negate().negate();

        try testing.expectApproxEqAbs(vector.x, double_negated.x, 1e-10);
        try testing.expectApproxEqAbs(vector.y, double_negated.y, 1e-10);
        try testing.expectApproxEqAbs(vector.z, double_negated.z, 1e-10);
    }
}

test "property: normalized direction remains normalized after scaling origin" {
    // In ray tracing: ray(t) = origin + t * direction
    // If direction is normalized, it stays normalized regardless of origin or t
    var prng: PRNG = .init(testing.random_seed);

    for (0..1000) |_| {
        const ray_origin = random_vec3(&prng, -100.0, 100.0);
        const ray_direction_unnormalized = random_nonzero(&prng, -10.0, 10.0);
        const ray_direction = unit(ray_direction_unnormalized);
        const ray_parameter_t = prng.random().float(f64) * 200.0 - 100.0;

        // The direction should still be unit length
        try testing.expectApproxEqAbs(ray_direction.length(), 1.0, 1e-10);

        // Computing a point on the ray doesn't change direction's length
        _ = add(ray_origin, scale(ray_direction, ray_parameter_t));
        try testing.expectApproxEqAbs(ray_direction.length(), 1.0, 1e-10);
    }
}
