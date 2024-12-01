const std = @import("std");
const aoc = @import("aoc.zig");

const assert = std.debug.assert;
const expect = std.testing.expect;

const Allocator = std.mem.Allocator;

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 1;
pub const AocData = struct { size: usize, left: [*]i32, right: [*]i32 };

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    const size = countLines(input);

    const left = try allocator.alloc(i32, size);
    errdefer allocator.free(left);
    const right = try allocator.alloc(i32, size);
    errdefer allocator.free(right);

    var iter = std.mem.splitAny(u8, input, &std.ascii.whitespace);
    var next_number: ?[]const u8 = iter.first();
    var current: usize = 0;

    while (next_number) |number| : (next_number = iter.next()) {
        if (number.len == 0) {
            continue;
        }
        const num = try std.fmt.parseInt(i32, number, 10);
        if (current % 2 == 0) {
            left[current / 2] = num;
        } else {
            right[current / 2] = num;
        }
        current += 1;
    }

    if (size * 2 != current) {
        return error.NumberMismatch;
    }
    std.sort.pdq(i32, left, {}, std.sort.asc(i32));
    std.sort.pdq(i32, right, {}, std.sort.asc(i32));
    return .{ .size = size, .left = @ptrCast(left), .right = @ptrCast(right) };
}

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!u32 {
    _ = allocator;
    var total_distance: u32 = 0;

    for (0..data.size) |i| {
        total_distance += @abs(data.right[i] - data.left[i]);
    }
    return total_distance;
}

const Freq = struct {
    number: i32,
    count: u32,

    pub fn order_i32(context: void, key: i32, freq: Freq) std.math.Order {
        _ = context;
        return std.math.order(key, freq.number);
    }
};

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!u32 {
    const left = data.left[0..data.size];
    const right = data.right[0..data.size];

    var i: usize = 0;
    var unique_count: usize = 0;
    var freqs: []Freq = try allocator.alloc(Freq, data.size);
    defer allocator.free(freqs);

    // 1: Compute occurences of each number of the right list
    while (i < data.size) {
        const next_idx = std.mem.indexOfNonePos(i32, right, i, &.{right[i]}) orelse right.len;
        const count = next_idx - i;

        assert(count >= 1);
        freqs[unique_count] = .{ .number = right[i], .count = @intCast(count) };
        unique_count += 1;
        i = next_idx;
    }
    freqs = freqs[0..unique_count];

    // 2: Sum the right occurences of each number of the left list
    var similarity_score: u32 = 0;
    for (left) |number| {
        if (std.sort.binarySearch(Freq, number, freqs, {}, Freq.order_i32)) |freq_idx| {
            similarity_score += @as(u32, @intCast(number)) * freqs[freq_idx].count;
        }
    }
    return similarity_score;
}

pub fn main() !void {
    aoc.run(.{});
}

fn countLines(input: []const u8) usize {
    var iter = std.mem.splitScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.first();
    var count: usize = 0;

    while (next_line) |line| : (next_line = iter.next()) {
        if (line.len == 0) {
            continue;
        }
        count += 1;
    }
    return count;
}

test "aoc 2024, day 01 example" {
    const example =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data: AocData = try aocSetup(allocator, example);
    try expect(11 == try aocPart1(allocator, data));
    try expect(31 == try aocPart2(allocator, data));
}
