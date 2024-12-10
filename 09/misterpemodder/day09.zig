const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 9;
pub const AocData = struct {
    blocks: []u16,
    max_id: u16,
};
pub const AocResult = u64;

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    var blocks = std.ArrayListUnmanaged(u16){};
    errdefer blocks.deinit(allocator);
    var max_id: u16 = 0;

    for (std.mem.trim(u8, input, &std.ascii.whitespace), 0..) |c, i| {
        const count: u8 = c - '0';
        if (i % 2 == 0) {
            try blocks.appendNTimes(allocator, @intCast(i / 2 + 1), @intCast(count));
            max_id = @intCast(i / 2 + 1);
        } else {
            try blocks.appendNTimes(allocator, 0, @intCast(count));
        }
    }
    return .{
        .blocks = blocks.items,
        .max_id = max_id,
    };
}

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!AocResult {
    var blocks: []u16 = try allocator.alloc(u16, data.blocks.len);
    @memcpy(blocks, data.blocks); // duplicate blocks to avoid modifying part 2 input
    var next_free: ?usize = std.mem.indexOfScalar(u16, blocks, 0);

    while (next_free) |free| : (next_free = std.mem.indexOfScalarPos(u16, blocks, free, 0)) {
        blocks[free] = blocks[blocks.len - 1];
        blocks = blocks[0 .. blocks.len - 1];
    }
    return computeChecksum(blocks);
}

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!AocResult {
    _ = allocator;
    const blocks: []u16 = data.blocks;
    var file_id: u16 = data.max_id;

    while (file_id > 0) : (file_id -= 1) {
        const file = findLastFile(blocks, file_id) orelse continue;
        const file_len = file.end - file.start;
        const free = findFirstFree(blocks[0..file.start], file_len) orelse continue;

        @memset(blocks[free.start .. free.start + file_len], file_id);
        @memset(blocks[file.start..file.end], 0);
    }
    return computeChecksum(blocks);
}

fn computeChecksum(blocks: []const u16) u64 {
    var checksum: u64 = 0;

    for (blocks, 0..) |block, i| {
        if (block > 0) {
            checksum += @as(u64, @intCast(block - 1)) * @as(u64, @intCast(i));
        }
    }

    return checksum;
}

const BlockSpan = struct {
    start: usize,
    end: usize,
};

fn findLastFile(blocks: []const u16, file_id: u16) ?BlockSpan {
    const file_end: usize = std.mem.lastIndexOfScalar(u16, blocks, file_id) orelse return null;
    var file_start: usize = file_end;

    while (blocks[file_start] == file_id) : (file_start -= 1) {
        if (file_start == 0) {
            break;
        }
    } else {
        file_start += 1;
    }
    return .{
        .start = file_start,
        .end = file_end + 1,
    };
}

fn findFirstFree(blocks: []const u16, min_len: usize) ?BlockSpan {
    var free_offset: usize = 0;

    while (free_offset + min_len < blocks.len) {
        const free_start = std.mem.indexOfScalarPos(u16, blocks, free_offset, 0) orelse break;
        const free_end = std.mem.indexOfNonePos(u16, blocks, free_start, &.{0}) orelse blocks.len;
        const free_len = free_end - free_start;

        if (free_len >= min_len) {
            return .{
                .start = free_start,
                .end = free_end,
            };
        }
        free_offset = free_end;
    }
    return null;
}

pub fn main() !void {
    aoc.run(.{});
}

test "aoc 2024, day 09 example" {
    const example = "2333133121414131402";

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data: AocData = try aocSetup(allocator, example);
    try expect(1928 == try aocPart1(allocator, data));
    try expect(2858 == try aocPart2(allocator, data));
}
