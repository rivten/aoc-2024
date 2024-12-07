const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 6;
pub const AocData = struct {
    height: usize,
    width: usize,
    start_x: isize,
    start_y: isize,
    grid: [*][*]const u8,
};

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    const dims = getInputDimensions(input);

    const grid: [][*]const u8 = try allocator.alloc([*]u8, dims.height);
    errdefer allocator.free(grid);

    var iter = std.mem.splitScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.first();
    var y: usize = 0;
    var start_x: isize = 0;
    var start_y: isize = 0;

    while (next_line) |line| : (next_line = iter.next()) {
        if (line.len == 0) {
            continue;
        }
        if (std.mem.indexOfScalar(u8, line, '^')) |x| {
            start_x = @intCast(x);
            start_y = @intCast(y);
        }
        grid[y] = line.ptr;
        y += 1;
    }

    return .{
        .height = dims.height,
        .width = dims.width,
        .start_x = start_x,
        .start_y = start_y,
        .grid = grid.ptr,
    };
}

const directions = [4][2]isize{ .{ 0, -1 }, .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 } };

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!u32 {
    // Each cell in `visited` is a bitfield of directions visited.
    const visited = try allocator.alloc(u8, data.height * data.width);
    defer allocator.free(visited);

    _ = traverse(data, visited, -9999, -9999);

    var count: u32 = 0;
    for (visited) |v| {
        if (v > 0) {
            count += 1;
        }
    }

    return count;
}

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!u32 {
    var block_count: u32 = 0;

    // Each cell in `visited` is a bitfield of directions visited.
    const visited = try allocator.alloc(u8, data.height * data.width);
    defer allocator.free(visited);
    const visited_first = try allocator.alloc(u8, data.height * data.width);
    defer allocator.free(visited_first);

    _ = traverse(data, visited_first, -9999, -9999);

    // as an optimization, only check cell that were visited in the first traversal
    for (visited_first, 0..) |v, idx| {
        if (v == 0) {
            continue;
        }
        const x: isize = @intCast(idx % data.width);
        const y: isize = @intCast(idx / data.width);

        if (!(x == data.start_x and y == data.start_y) and traverse(data, visited, x, y)) {
            block_count += 1;
        }
    }

    return block_count;
}

pub fn main() !void {
    aoc.run(.{});
}

fn traverse(data: AocData, visited: []u8, bx: isize, by: isize) bool {
    var px = data.start_x;
    var py = data.start_y;
    var dir: usize = 0;

    @memset(visited, 0);

    while (getAt(data, px, py) != null) {
        const idx = @as(usize, @intCast(py)) * data.width + @as(usize, @intCast(px));
        const dir_mask = @as(u8, 1) << @as(u2, @intCast(dir));

        if ((visited[idx] & dir_mask) != 0) {
            return true;
        }

        visited[idx] |= (@as(u8, 1) << @as(u3, @intCast(dir)));
        var nx = px + directions[dir][0];
        var ny = py + directions[dir][1];

        while ((nx == bx and ny == by) or getAt(data, nx, ny) == '#') {
            dir = @as(u2, @intCast(dir)) +% @as(u2, 1);
            nx = px + directions[dir][0];
            ny = py + directions[dir][1];
        }

        px += directions[dir][0];
        py += directions[dir][1];
    }
    return false;
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

test "aoc 2024, day 06 example" {
    const example =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try aocSetup(allocator, example);
    try expect(41 == try aocPart1(allocator, data));
    try expect(6 == try aocPart2(allocator, data));
}
