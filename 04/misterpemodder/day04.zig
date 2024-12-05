const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 4;
pub const AocData = struct {
    height: usize,
    width: usize,
    grid: [*][*]const u8,
};

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    const dims = getInputDimensions(input);

    const grid: [][*]const u8 = try allocator.alloc([*]u8, dims.height);
    errdefer allocator.free(grid);

    var iter = std.mem.splitScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.first();
    var y: usize = 0;

    while (next_line) |line| : (next_line = iter.next()) {
        if (line.len == 0) {
            continue;
        }
        grid[y] = line.ptr;
        y += 1;
    }

    return .{
        .height = dims.height,
        .width = dims.width,
        .grid = grid.ptr,
    };
}

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!u32 {
    _ = allocator;
    return countPatterns(data, xMasLinePattern);
}

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!u32 {
    _ = allocator;
    return countPatterns(data, masCrossPattern);
}

pub fn main() !void {
    aoc.run(.{});
}

fn countPatterns(data: AocData, comptime pattern_fn: anytype) u32 {
    var count: u32 = 0;
    for (0..data.height) |y| {
        for (0..data.width) |x| {
            count += @call(.auto, pattern_fn, .{ data, @as(isize, @intCast(x)), @as(isize, @intCast(y)) });
        }
    }
    return count;
}

fn xMasLinePattern(data: AocData, x: isize, y: isize) u32 {
    const directions = [_][2]isize{ .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 }, .{ 0, 1 }, .{ -1, 1 }, .{ -1, 0 } };

    if (data.grid[@intCast(y)][@intCast(x)] != 'X') {
        return 0;
    }
    var count: u8 = 0;
    inline for (directions) |dir| {
        if (getAt(data, x + dir[0], y + dir[1]) == 'M' //
        and getAt(data, x + dir[0] * 2, y + dir[1] * 2) == 'A' //
        and getAt(data, x + dir[0] * 3, y + dir[1] * 3) == 'S') {
            count += 1;
        }
    }
    return count;
}

fn masCrossPattern(data: AocData, x: isize, y: isize) u32 {
    if (data.grid[@intCast(y)][@intCast(x)] != 'A') {
        return 0;
    }
    const top_left = getAt(data, x - 1, y - 1);
    const top_right = getAt(data, x + 1, y - 1);
    const bottom_left = getAt(data, x - 1, y + 1);
    const bottom_right = getAt(data, x + 1, y + 1);
    const diagonal_1 = (top_left == 'M' and bottom_right == 'S') or (top_left == 'S' and bottom_right == 'M');
    const diagonal_2 = (top_right == 'M' and bottom_left == 'S') or (top_right == 'S' and bottom_left == 'M');

    return if (diagonal_1 and diagonal_2) 1 else 0;
}

fn getAt(data: AocData, x: isize, y: isize) ?u8 {
    if (y < 0 or x < 0 or y >= data.height or x >= data.width) {
        return null;
    }
    return data.grid[@intCast(y)][@intCast(x)];
}

fn getInputDimensions(input: []const u8) struct { width: usize, height: usize } {
    var iter = std.mem.splitScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.first();
    var height: usize = 0;
    var width: usize = 0;

    while (next_line) |line| : (next_line = iter.next()) {
        if (line.len == 0) {
            continue;
        }
        height += 1;
        width = @max(width, line.len);
    }
    return .{ .width = width, .height = height };
}

test "aoc 2024, day 04 example" {
    const example =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try aocSetup(allocator, example);
    try expect(18 == try aocPart1(allocator, data));
    try expect(9 == try aocPart2(allocator, data));
}
