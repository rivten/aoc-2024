const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 10;
pub const AocData = struct {
    height: usize,
    width: usize,
    grid: [*][*]const u8,
};
pub const AocResult = u32;

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    const dims = getInputDimensions(input);

    const grid: [][*]const u8 = try allocator.alloc([*]u8, dims.height);
    errdefer allocator.free(grid);

    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.next();
    var y: usize = 0;

    while (next_line) |line| : (next_line = iter.next()) {
        grid[y] = line.ptr;
        y += 1;
    }

    return .{
        .height = dims.height,
        .width = dims.width,
        .grid = grid.ptr,
    };
}

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!AocResult {
    const visited: []bool = try allocator.alloc(bool, data.width * data.height);
    defer allocator.free(visited);

    var score: u32 = 0;

    for (0..data.height) |y| {
        for (0..data.width) |x| {
            if (data.grid[y][x] == '0') {
                @memset(visited, false);
                score += endsReachableFrom(data, visited, x, y);
            }
        }
    }

    return score;
}

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!AocResult {
    const visited: []u32 = try allocator.alloc(u32, data.width * data.height);
    defer allocator.free(visited);

    var total: u32 = 0;

    for (0..data.height) |y| {
        for (0..data.width) |x| {
            if (data.grid[y][x] == '0') {
                @memset(visited, 0);
                countTrails(data, visited, x, y);

                for (visited) |v| {
                    total += v;
                }
            }
        }
    }
    return total;
}

fn endsReachableFrom(data: AocData, visited: []bool, x: usize, y: usize) u32 {
    if (visited[y * data.width + x]) {
        return 0;
    }
    if (data.grid[y][x] == '9') {
        visited[y * data.width + x] = true;
        return 1;
    }
    const current: u8 = data.grid[y][x];
    const next: u8 = current + 1;
    var count: u32 = 0;

    if (x > 0 and data.grid[y][x - 1] == next) {
        count += endsReachableFrom(data, visited, x - 1, y);
    }
    if (x + 1 < data.width and data.grid[y][x + 1] == next) {
        count += endsReachableFrom(data, visited, x + 1, y);
    }
    if (y > 0 and data.grid[y - 1][x] == next) {
        count += endsReachableFrom(data, visited, x, y - 1);
    }
    if (y + 1 < data.height and data.grid[y + 1][x] == next) {
        count += endsReachableFrom(data, visited, x, y + 1);
    }
    return count;
}

fn countTrails(data: AocData, visited: []u32, x: usize, y: usize) void {
    if (data.grid[y][x] == '9') {
        visited[y * data.width + x] += 1;
        return;
    }
    const current: u8 = data.grid[y][x];
    const next: u8 = current + 1;

    if (x > 0 and data.grid[y][x - 1] == next) {
        countTrails(data, visited, x - 1, y);
    }
    if (x + 1 < data.width and data.grid[y][x + 1] == next) {
        countTrails(data, visited, x + 1, y);
    }
    if (y > 0 and data.grid[y - 1][x] == next) {
        countTrails(data, visited, x, y - 1);
    }
    if (y + 1 < data.height and data.grid[y + 1][x] == next) {
        countTrails(data, visited, x, y + 1);
    }
}

fn getInputDimensions(input: []const u8) struct { width: usize, height: usize } {
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.next();
    var height: usize = 0;
    var width: usize = 0;

    while (next_line) |line| : (next_line = iter.next()) {
        height += 1;
        width = @max(width, line.len);
    }

    return .{ .width = width, .height = height };
}

pub fn main() !void {
    aoc.run(.{});
}

test "aoc 2024, day 10 example" {
    const example =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data: AocData = try aocSetup(allocator, example);
    try expect(36 == try aocPart1(allocator, data));
    try expect(81 == try aocPart2(allocator, data));
}
