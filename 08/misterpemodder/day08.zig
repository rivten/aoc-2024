const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 8;
pub const AocResult = u32;
pub const AocData = struct {
    height: usize,
    width: usize,
    input: []const u8,
};

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    _ = allocator;

    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.next();
    var height: usize = 0;
    var width: usize = 0;

    while (next_line) |line| : (next_line = iter.next()) {
        height += 1;
        width = @max(width, line.len);
    }

    return .{
        .height = height,
        .width = width,
        .input = input,
    };
}

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!AocResult {
    const anti_nodes = try allocator.alloc(u8, data.height * data.width);
    defer allocator.free(anti_nodes);
    @memset(anti_nodes, 0);

    for (data.input, 0..) |c, offset| {
        if (c == '.' or c == '\n') {
            continue;
        }
        var other_offset: ?usize = std.mem.indexOfScalarPos(u8, data.input, offset + 1, c);
        const x: isize = @intCast(offset % (data.width + 1));
        const y: isize = @intCast(offset / (data.width + 1));

        while (other_offset) |oo| : (other_offset = std.mem.indexOfScalarPos(u8, data.input, oo + 1, c)) {
            const ox: isize = @intCast(oo % (data.width + 1));
            const oy: isize = @intCast(oo / (data.width + 1));

            const anx1 = x + (ox - x) * 2;
            const any1 = y + (oy - y) * 2;
            const anx2 = x - (ox - x);
            const any2 = y - (oy - y);

            if (anx1 >= 0 and anx1 < @as(isize, @intCast(data.width)) and any1 >= 0 and any1 < @as(isize, @intCast(data.height))) {
                anti_nodes[@as(usize, @intCast(any1)) * data.width + @as(usize, @intCast(anx1))] = 1;
            }
            if (anx2 >= 0 and anx2 < @as(isize, @intCast(data.width)) and any2 >= 0 and any2 < @as(isize, @intCast(data.height))) {
                anti_nodes[@as(usize, @intCast(any2)) * data.width + @as(usize, @intCast(anx2))] = 1;
            }
        }
    }

    var unique_anti_nodes: u32 = 0;
    for (anti_nodes) |an| {
        if (an > 0) {
            unique_anti_nodes += 1;
        }
    }
    return unique_anti_nodes;
}

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!AocResult {
    const width: isize = @intCast(data.width);
    const height: isize = @intCast(data.height);

    const anti_nodes = try allocator.alloc(u8, data.height * data.width);
    defer allocator.free(anti_nodes);
    @memset(anti_nodes, 0);

    for (data.input, 0..) |c, offset| {
        if (c == '.' or c == '\n') {
            continue;
        }
        var other_offset: ?usize = std.mem.indexOfScalarPos(u8, data.input, offset + 1, c);
        const x: isize = @intCast(offset % (data.width + 1));
        const y: isize = @intCast(offset / (data.width + 1));

        while (other_offset) |oo| : (other_offset = std.mem.indexOfScalarPos(u8, data.input, oo + 1, c)) {
            const ox: isize = @intCast(oo % (data.width + 1));
            const oy: isize = @intCast(oo / (data.width + 1));

            var slope_x: isize = ox - x;
            var slope_y: isize = oy - y;
            const gcd: isize = @intCast(std.math.gcd(@abs(slope_x), @abs(slope_y)));

            slope_x = @divTrunc(slope_x, gcd);
            slope_y = @divTrunc(slope_y, gcd);

            var px = x;
            var py = y;
            while (px >= 0 and px < width and py >= 0 and py < height) {
                anti_nodes[@intCast(py * width + px)] = 1;
                px += slope_x;
                py += slope_y;
            }
            px = x - slope_x;
            py = y - slope_y;
            while (px >= 0 and px < width and py >= 0 and py < height) {
                anti_nodes[@intCast(py * width + px)] = 1;
                px -= slope_x;
                py -= slope_y;
            }
        }
    }

    var unique_anti_nodes: u32 = 0;
    for (anti_nodes) |an| {
        if (an > 0) {
            unique_anti_nodes += 1;
        }
    }
    return unique_anti_nodes;
}

pub fn main() !void {
    aoc.run(.{});
}

test "aoc 2024, day 08 example" {
    const example =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data: AocData = try aocSetup(allocator, example);
    try expect(14 == try aocPart1(allocator, data));
    try expect(34 == try aocPart2(allocator, data));
}
