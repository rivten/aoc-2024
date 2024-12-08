const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 7;
pub const AocData = [][]u64;
pub const AocResult = u64;

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    const size = countLines(input);

    var equations = try allocator.alloc([]u64, size);
    errdefer allocator.free(equations);

    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.next();
    var i: usize = 0;

    while (next_line) |line| : ({
        next_line = iter.next();
        i += 1;
    }) {
        var equation = std.ArrayListUnmanaged(u64){};
        errdefer equation.deinit(allocator);

        var values_iter = std.mem.tokenizeAny(u8, line, ": ");
        var next_value: ?[]const u8 = values_iter.next();

        while (next_value) |value| : (next_value = values_iter.next()) {
            const num = try std.fmt.parseInt(u64, value, 10);
            try equation.append(allocator, num);
        }
        equations[i] = equation.items;
    }

    return equations;
}

pub fn aocPart1(allocator: Allocator, equations: AocData) anyerror!AocResult {
    _ = allocator;
    return sumValidEquations(equations, .{ mul, add });
}

pub fn aocPart2(allocator: Allocator, equations: AocData) anyerror!AocResult {
    _ = allocator;
    return sumValidEquations(equations, .{ mul, add, concat });
}

pub fn main() !void {
    aoc.run(.{});
}

fn sumValidEquations(equations: AocData, comptime operators: anytype) u64 {
    var result: u64 = 0;

    for (equations) |equation| {
        const target = equation[0];
        const operands = equation[1..];

        if (isSolvable(target, operands[0], operands[1..], operators)) {
            result += target;
        }
    }
    return result;
}

fn isSolvable(target: u64, total: u64, operands: []u64, comptime operators: anytype) bool {
    if (total == target) {
        return true;
    } else if (total > target or operands.len == 0) {
        return false;
    }
    inline for (operators) |operator| {
        if (isSolvable(target, operator(total, operands[0]), operands[1..], operators)) {
            return true;
        }
    }
    return false;
}

fn mul(lhs: u64, rhs: u64) u64 {
    return lhs * rhs;
}

fn add(lhs: u64, rhs: u64) u64 {
    return lhs + rhs;
}

fn concat(lhs: u64, rhs: u64) u64 {
    var pow: u64 = 10;
    while (pow <= rhs) : (pow *= 10) {}
    return lhs *| pow +| rhs;
}

fn countLines(input: []const u8) usize {
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.next();
    var count: usize = 0;

    while (next_line) |_| : (next_line = iter.next()) {
        count += 1;
    }
    return count;
}

test "aoc 2024, day 07 example" {
    const example =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data: AocData = try aocSetup(allocator, example);
    try expect(3749 == try aocPart1(allocator, data));
    try expect(11387 == try aocPart2(allocator, data));
}
