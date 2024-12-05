const std = @import("std");
const aoc = @import("aoc.zig");

const Allocator = std.mem.Allocator;

const expect = std.testing.expect;

pub const std_options = .{
    .log_level = .info,
};

pub const AOC_YEAR: u32 = 2024;
pub const AOC_DAY: u32 = 5;
pub const AocData = *Everything;

const Everything = struct {
    orders: [100]OrderingRule = [_]OrderingRule{.{}} ** 100,
    updates: []Update = &.{},
};
const OrderingRule = std.BoundedArray(u8, 100);
const Update = []u8;

pub fn aocSetup(allocator: Allocator, input: []const u8) anyerror!AocData {
    var data = try allocator.create(Everything);
    errdefer allocator.destroy(data);
    data.* = Everything{};

    var iter = std.mem.splitScalar(u8, input, '\n');
    var next_line: ?[]const u8 = iter.first();

    while (next_line) |line| : (next_line = iter.next()) {
        if (line.len == 0) {
            break;
        }
        const sep = std.mem.indexOfScalar(u8, line, '|') orelse return error.MissingSeparator;
        const before = try std.fmt.parseUnsigned(u8, line[0..sep], 10);
        const after = try std.fmt.parseUnsigned(u8, line[sep + 1 .. line.len], 10);

        try data.orders[@intCast(before)].append(after);
    }

    var updates = std.ArrayListUnmanaged([]const u8){};
    errdefer updates.deinit(allocator);

    next_line = iter.next();
    while (next_line) |line| : (next_line = iter.next()) {
        if (line.len == 0) {
            break;
        }
        var numbers = std.mem.splitScalar(u8, line, ',');
        var next_number: ?[]const u8 = numbers.first();

        var update = std.ArrayListUnmanaged(u8){};
        errdefer update.deinit(allocator);

        while (next_number) |number| : (next_number = numbers.next()) {
            const parsed = try std.fmt.parseUnsigned(u8, number, 10);
            try update.append(allocator, parsed);
        }

        try updates.append(allocator, update.items);
    }
    data.updates = @ptrCast(updates.items);
    return data;
}

pub fn aocPart1(allocator: Allocator, data: AocData) anyerror!u32 {
    _ = allocator;
    var total_page_numbers: u32 = 0;

    outer: for (data.updates) |update| {
        for (update, 0..) |item, i| {
            const order: *const OrderingRule = &data.orders[@intCast(item)];

            if (std.mem.indexOfAny(u8, update[0..i], order.slice()) != null) {
                // found a number that is supposed to be after `item`
                continue :outer;
            }
        }

        total_page_numbers += update[update.len / 2];
    }
    return total_page_numbers;
}

pub fn aocPart2(allocator: Allocator, data: AocData) anyerror!u32 {
    var total_page_numbers: u32 = 0;

    for (data.updates) |update| {
        for (update, 0..) |item, i| {
            const order: *const OrderingRule = &data.orders[@intCast(item)];

            if (std.mem.indexOfAny(u8, update[0..i], order.slice()) != null) {
                // found a number that is supposed to be after `item`
                break;
            }
        } else {
            continue;
        }

        var sorter = try UpdateSorter.init(allocator, &data.orders, update);
        defer sorter.deinit();

        std.sort.pdqContext(0, update.len, sorter);

        total_page_numbers += update[update.len / 2];
    }
    return total_page_numbers;
}

/// Stateful sorter that caches results of comparisons to avoid recomputing them
/// Yes, the "algorithm" is awful, but it works ¯\_(ツ)_/¯
const UpdateSorter = struct {
    const ResultCache = std.AutoHashMap(u16, bool);

    orders: []OrderingRule,
    update: []u8,
    cache: *ResultCache,

    pub fn init(allocator: Allocator, orders: []OrderingRule, update: []u8) !@This() {
        const cache = try allocator.create(ResultCache);
        cache.* = ResultCache.init(allocator);
        return .{
            .orders = orders,
            .update = update,
            .cache = cache,
        };
    }

    pub fn deinit(self: @This()) void {
        self.cache.deinit();
    }

    pub fn lessThan(self: @This(), a: usize, b: usize) bool {
        const before: u8 = self.update[a];
        const after: u8 = self.update[b];
        const order: *const OrderingRule = &self.orders[@intCast(self.update[a])];
        const lt = self.contains(order, after, before);
        return lt;
    }

    pub fn swap(self: @This(), a: usize, b: usize) void {
        return std.mem.swap(u8, &self.update[a], &self.update[b]);
    }

    fn contains(self: @This(), order: *const OrderingRule, after: u8, before: u8) bool {
        const cache_key: u16 = (@as(u16, @intCast(after)) << 8) | @as(u16, @intCast(before));
        if (self.cache.get(cache_key)) |cached| {
            return cached;
        }
        const result = self.containsInner(order, after, before);
        self.cache.put(cache_key, result) catch {
            std.log.err("Failed to cache result for {} < {}\n", .{ before, after });
            std.process.exit(1);
        };
        return result;
    }

    /// Recusively checking whether `before` is part of rule `after`.
    fn containsInner(self: @This(), order: *const OrderingRule, before: u8, after: u8) bool {
        if (std.mem.indexOfScalar(u8, self.update, after) == null) {
            return false;
        }
        if (std.mem.indexOfScalar(u8, order.slice(), before) != null) {
            return true;
        }
        for (order.slice()) |o| {
            const next_order: *const OrderingRule = &self.orders[@intCast(o)];
            if (self.contains(next_order, before, o)) {
                return true;
            }
        }
        return false;
    }
};

pub fn main() !void {
    aoc.run(.{});
}

test "aoc 2024, day 05 example" {
    const example =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try aocSetup(allocator, example);
    try expect(143 == try aocPart1(allocator, data));
    try expect(123 == try aocPart2(allocator, data));
}
