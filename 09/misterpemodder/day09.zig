const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 9;
pub const AocData = []const u8;
pub const AocResult = u64;

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!AocResult {
    var blocks = std.ArrayListUnmanaged(u16){};
    defer blocks.deinit(allocator);

    for (std.mem.trim(u8, data, &std.ascii.whitespace), 0..) |c, i| {
        const count: u8 = c - '0';
        if (i % 2 == 0) {
            try blocks.appendNTimes(allocator, @intCast(i / 2 + 1), @intCast(count));
        } else {
            try blocks.appendNTimes(allocator, 0, @intCast(count));
        }
    }

    var bs: []u16 = blocks.items;
    var next_free: ?usize = std.mem.indexOfScalar(u16, bs, 0);

    while (next_free) |free| : (next_free = std.mem.indexOfScalarPos(u16, bs, free, 0)) {
        bs[free] = bs[bs.len - 1];
        bs = bs[0 .. bs.len - 1];
    }

    var checksum: u64 = 0;

    for (bs, 0..) |block, i| {
        checksum += @as(u64, @intCast(block - 1)) * @as(u64, @intCast(i));
    }

    return checksum;
}

fn printLine(bs: []u16) void {
    for (bs) |block| {
        if (block > 0) {
            std.debug.print("{}", .{block - 1});
        } else {
            std.debug.print(".", .{});
        }
    }
    std.debug.print("\n", .{});
}

// 6_227_094_154_536 > X > 5_423_689_415_101
pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!AocResult {
    var blocks = std.ArrayListUnmanaged(u16){};
    defer blocks.deinit(allocator);
    var max_id: u16 = 0;

    for (std.mem.trim(u8, data, &std.ascii.whitespace), 0..) |c, i| {
        const count: u8 = c - '0';
        if (i % 2 == 0) {
            try blocks.appendNTimes(allocator, @intCast(i / 2 + 1), @intCast(count));
            max_id = @intCast(i / 2 + 1);
        } else {
            try blocks.appendNTimes(allocator, 0, @intCast(count));
        }
    }

    const bs: []u16 = blocks.items;
    // var next_free: ?usize = std.mem.indexOfScalar(u16, bs, 0);

    // printLine(bs);
    while (max_id > 0) : (max_id -= 1) {
        const end_pos: usize = std.mem.lastIndexOfScalar(u16, bs, max_id) orelse continue;
        var start_pos: usize = end_pos;

        while (bs[start_pos] == max_id) : (start_pos -= 1) {
            if (start_pos == 0) {
                break;
            }
        } else {
            start_pos += 1;
        }
        const len = end_pos - start_pos + 1;
        // std.debug.print("I: {}, start: {}, end: {}, len: {}\n", .{ max_id - 1, start_pos, end_pos, len });
        var offset: usize = 0;

        if (bs[start_pos] != max_id or bs[end_pos] != max_id) {
            std.debug.print("RANGE TOO LARGE: {} at {} to {}\n", .{ max_id, start_pos, end_pos });
        }

        if ((start_pos > 0 and bs[start_pos - 1] == max_id) or (end_pos + 1 < bs.len and bs[end_pos + 1] == max_id)) {
            std.debug.print("RANGE TOO SMALL: {} at {} to {}\n", .{ max_id, start_pos, end_pos });
        }

        while (offset + len < start_pos) {
            const free_start = std.mem.indexOfScalarPos(u16, bs, offset, 0) orelse break;
            const free_end = std.mem.indexOfNonePos(u16, bs, free_start, &.{0}) orelse bs.len;
            const free_len = free_end - free_start;

            if (free_len >= len) {
                if (std.mem.indexOfNone(u16, bs[free_start .. free_start + len], &.{0})) |z| {
                    std.debug.print("OVERWRITING DATA: {} at {}\n", .{ bs[z + free_start], z + free_start });
                }
                if (std.mem.indexOfNone(u16, bs[start_pos .. end_pos + 1], &.{max_id})) |z| {
                    std.debug.print("OVERWRITING DATA: {} at {}\n", .{ bs[z + start_pos], z + start_pos });
                }

                if ((bs[free_start .. free_start + len]).len != (bs[start_pos .. end_pos + 1]).len) {
                    std.debug.print("LENGTH MISMATCH: {} != {}\n", .{ (bs[free_start .. free_start + len]).len, (bs[start_pos .. end_pos + 1]).len });
                }
                @memset(bs[free_start .. free_start + len], max_id);
                @memset(bs[start_pos .. end_pos + 1], 0);
                // printLine(bs);
                break;
            }
            offset = free_end;
        }
    }

    var checksum: u64 = 0;

    for (bs, 0..) |block, i| {
        if (block > 0) {
            checksum += @as(u64, @intCast(block - 1)) * @as(u64, @intCast(i));
        }
    }

    return checksum;
}

pub fn main() !void {
    aoc.run(.{});
}
