const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 3;
pub const AocData = []const u8;

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!u32 {
    _ = allocator;
    var offset: usize = 0;
    var total: u32 = 0;

    while (std.mem.indexOfScalarPos(u8, data, offset, 'm')) |prefix_idx| {
        const mul = parseMulInstruction(data, prefix_idx) catch {
            offset += 1;
            continue;
        };
        offset = mul.offset;
        total += mul.lhs * mul.rhs;
    }
    return total;
}

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!u32 {
    _ = allocator;
    var offset: usize = 0;
    var total: u32 = 0;
    var mul_enabled = true;

    while (std.mem.indexOfAnyPos(u8, data, offset, "dm")) |prefix_idx| {
        // Believe it or not, Zig does have if..else if |err| syntax yet... So behold!
        const mul = parseMulInstruction(data, prefix_idx) catch {
            const do_offset = parseDoInstruction(data, prefix_idx) catch {
                const dont_offset = parseDontInstruction(data, prefix_idx) catch {
                    offset += 1;
                    continue;
                };
                mul_enabled = false;
                offset = dont_offset;
                continue;
            };
            mul_enabled = true;
            offset = do_offset;
            continue;
        };
        offset = mul.offset;
        if (mul_enabled) {
            total += mul.lhs * mul.rhs;
        }
    }
    return total;
}

pub fn main() !void {
    aoc.run(.{});
}

fn parseMulInstruction(data: []const u8, start_index: usize) !struct { lhs: u32, rhs: u32, offset: usize } {
    if (!std.mem.startsWith(u8, data[start_index..], "mul(")) return error.UnexpectedInstruction;

    var offset = start_index + 4;

    const sep_idx = std.mem.indexOfNonePos(u8, data, offset, "0123456789") orelse return error.NoLhs;
    if (data[sep_idx] != ',') return error.BadSeparator;
    const lhs: u32 = try std.fmt.parseUnsigned(u32, data[offset..sep_idx], 10);

    offset = sep_idx + 1;

    const end_idx = std.mem.indexOfNonePos(u8, data, offset, "0123456789") orelse return error.NoRhs;
    if (data[end_idx] != ')') return error.MissingEnd;
    const rhs: u32 = try std.fmt.parseUnsigned(u32, data[offset..end_idx], 10);

    offset = end_idx + 1;
    return .{ .lhs = lhs, .rhs = rhs, .offset = offset };
}

fn parseDoInstruction(data: []const u8, start_index: usize) !usize {
    if (std.mem.startsWith(u8, data[start_index..], "do()")) {
        return start_index + 4;
    } else {
        return error.UnexpectedInstruction;
    }
}

fn parseDontInstruction(data: []const u8, start_index: usize) !usize {
    if (std.mem.startsWith(u8, data[start_index..], "don't()")) {
        return start_index + 7;
    } else {
        return error.UnexpectedInstruction;
    }
}

test "aoc 2024, day 03 example part 1" {
    const example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try expect(161 == try aocPart1(allocator, example));
}

test "aoc 2024, day 03 example part 2" {
    const example = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try expect(48 == try aocPart2(allocator, example));
}
