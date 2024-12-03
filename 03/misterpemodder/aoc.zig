//! Advent of Code Runner.
//! This file is responsible for downloading the input for a given year and day,
//! then running the aocSetup, aocPart1, and aocPart2 functions from the root module.
//!
//! The root module *must* have the following public fields:
//! - AOC_YEAR: u32
//! - AOC_DAY: u32
//! - AocData: type
//!
//! The root module may have the following public functions:
//! - aocSetup: fn (Allocator, []const u8) anyerror!AocData
//! - aocPart1: fn (Allocator, AocData) anyerror!u32
//! - aocPart2: fn (Allocator, AocData) anyerror!u32

const std = @import("std");
const fs = std.fs;
const json = std.json;
const abort = std.process.abort;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Timer = std.time.Timer;

const aoc_log = std.log.scoped(.aoc);

const AocRunConfig = struct {
    year_field: []const u8 = "AOC_YEAR",
    day_field: []const u8 = "AOC_DAY",
    data_type: []const u8 = "AocData",
    setup_fn: []const u8 = "aocSetup",
    part1_fn: []const u8 = "aocPart1",
    part2_fn: []const u8 = "aocPart2",
};

pub fn AocSetupFn(DataType: type) type {
    return fn (Allocator, []const u8) anyerror!DataType;
}

pub fn AocSolutionFn(DataType: type) type {
    return fn (Allocator, DataType) anyerror!u32;
}

pub fn run(comptime config: AocRunConfig) void {
    const root = @import("root");

    checkRunConfig(config, root);
    const year: u32 = @field(root, config.year_field);
    const day: u32 = @field(root, config.day_field);
    const DataType: type = @field(root, config.data_type);

    aoc_log.info("== Running Advent of Code {d} - Day {d} ==", .{ year, day });

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var input = std.ArrayList(u8).init(allocator);
    defer input.deinit();

    getInput(allocator, year, day, &input) catch |err| {
        aoc_log.err("Failed to get input: {}", .{err});
        return;
    };

    const setup_fn = getDeclOptional(AocSetupFn(DataType), root, config.setup_fn);
    const part1_fn = getDeclOptional(AocSolutionFn(DataType), root, config.part1_fn);
    const part2_fn = getDeclOptional(AocSolutionFn(DataType), root, config.part2_fn);

    const setup_data: DataType = runSetupFunction(DataType, setup_fn, allocator, input.items) catch return;
    runSolutionFunction(DataType, part1_fn, 1, allocator, setup_data) catch {};
    runSolutionFunction(DataType, part2_fn, 2, allocator, setup_data) catch {};
}

fn checkRunConfig(comptime config: AocRunConfig, comptime root: anytype) void {
    if (!@hasDecl(root, config.year_field)) {
        @compileError("Missing public field " ++ config.year_field ++ " in root module");
    }
    if (!@hasDecl(root, config.day_field)) {
        @compileError("Missing public field " ++ config.day_field ++ " in root module");
    }
    if (!@hasDecl(root, config.data_type)) {
        @compileError("Missing public type " ++ config.data_type ++ " in root module");
    }
}

fn getDeclOptional(comptime ty: type, comptime root: anytype, comptime name: []const u8) ?ty {
    if (@hasDecl(root, name)) {
        return @field(root, name);
    }
    return null;
}

fn runSetupFunction(comptime DataType: type, setup_fn: ?AocSetupFn(DataType), allocator: Allocator, input: []const u8) !DataType {
    if (setup_fn) |f| {
        aoc_log.info("Running setup function", .{});

        var timer = Timer.start() catch abort();
        const result = f(allocator, input) catch |err| {
            aoc_log.err("Setup function failed in {}µs: {}", .{ readTimeUs(&timer), err });
            return err;
        };
        aoc_log.info("Setup function completed in {}µs", .{readTimeUs(&timer)});
        return result;
    } else if (DataType == []const u8) {
        aoc_log.info("No setup to perform", .{});
        return input;
    } else {
        @compileError("Data type must be of type []const u8 when missing setup function");
    }
}

fn runSolutionFunction(comptime DataType: type, solution_fn: ?AocSolutionFn(DataType), part: u32, allocator: Allocator, data: DataType) !void {
    if (solution_fn) |f| {
        aoc_log.info("Running part {d}", .{part});

        var timer = Timer.start() catch abort();
        const result = f(allocator, data) catch |err| {
            aoc_log.err("Part {d} failed in {}µs: {}", .{ part, readTimeUs(&timer), err });
            return err;
        };
        aoc_log.info("Part {d} completed in {}µs => {d}", .{ part, readTimeUs(&timer), result });
    } else {
        aoc_log.warn("No solution provided for part {d}", .{part});
    }
}

fn readTimeUs(timer: *Timer) u64 {
    return timer.read() / 1_000;
}

const JsonConfig = struct {
    token: []const u8 = "",
};

fn getInput(allocator: Allocator, year: u32, day: u32, input: *ArrayList(u8)) !void {
    return getInputFromCache(allocator, year, day, input) catch {
        aoc_log.info("No cached input found, downloading from server...", .{});
        try getInputFromServer(allocator, year, day, input);
        storeInputInCache(allocator, year, day, input.items) catch |err| {
            aoc_log.warn("Failed to store input in cache: {}", .{err});
        };
    };
}

fn getInputFromCache(allocator: Allocator, year: u32, day: u32, input: *ArrayList(u8)) !void {
    const cwd = fs.cwd();

    const relative_path = try std.fmt.allocPrint(allocator, ".aoc/input_{d}_{d}.txt", .{ year, day });
    defer allocator.free(relative_path);

    var file = try cwd.openFile(relative_path, .{ .mode = .read_only });
    defer file.close();

    aoc_log.info("Reading input from cache: {s}", .{relative_path});
    try file.reader().readAllArrayList(input, std.math.maxInt(usize));
    aoc_log.info("Read input: {d} bytes", .{input.items.len});
}

fn getInputFromServer(allocator: Allocator, year: u32, day: u32, input: *ArrayList(u8)) !void {
    var http_client = std.http.Client{ .allocator = allocator };
    defer http_client.deinit();

    const url = try std.fmt.allocPrint(allocator, "https://adventofcode.com/{}/day/{}/input", .{ year, day });
    defer allocator.free(url);

    aoc_log.info("Reading API token", .{});

    const token = getToken(allocator) catch |err| {
        aoc_log.err("Failed to get API token, please set a value in the \"config\" field of .aoc/config.json", .{});
        return err;
    };
    defer allocator.free(token);

    aoc_log.info("Download input from {s}...", .{url});

    const session_cookie = try std.fmt.allocPrint(allocator, "session={s}", .{token});
    defer allocator.free(session_cookie);

    const header = [1]std.http.Header{.{ .name = "Cookie", .value = session_cookie }};

    const res = try http_client.fetch(.{
        .location = .{ .url = url },
        .response_storage = .{ .dynamic = input },
        .method = .GET,
        .extra_headers = &header,
    });

    if (res.status.class() == .success) {
        aoc_log.info("Downloaded input: {d} bytes", .{input.items.len});
        return;
    }

    return switch (res.status) {
        .not_found => error.NotFound,
        .bad_request, .unauthorized, .forbidden => error.NotLogged,
        else => error.Unknown,
    };
}

fn getToken(allocator: Allocator) ![]const u8 {
    const cwd = fs.cwd();

    var file = cwd.openFile(".aoc/config.json", .{ .mode = .read_only }) catch |err| switch (err) {
        fs.File.OpenError.FileNotFound => {
            const new_config = JsonConfig{
                .token = try getTokenFromStdin(allocator),
            };
            writeJsonConfig(new_config) catch |e| {
                aoc_log.err("Failed to write JSON config: {}", .{err});
                return e;
            };
            return new_config.token;
        },
        else => return err,
    };
    defer file.close();

    var reader = json.reader(allocator, file.reader());
    defer reader.deinit();

    const parsed = try json.parseFromTokenSource(JsonConfig, allocator, &reader, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });
    errdefer parsed.deinit();

    if (parsed.value.token.len == 0) {
        return error.EmptyAPIToken;
    }
    return parsed.value.token;
}

fn getTokenFromStdin(allocator: Allocator) ![]const u8 {
    const stdin = std.io.getStdIn();

    while (true) {
        try std.io.getStdOut().writeAll("Please enter your AOC session token: ");
        if (try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |token| {
            if (token.len > 0) {
                return token;
            }
        }
    }
}

fn storeInputInCache(allocator: Allocator, year: u32, day: u32, input: []const u8) !void {
    var aoc_dir = try fs.cwd().makeOpenPath(".aoc", .{});
    defer aoc_dir.close();

    const relative_path = try std.fmt.allocPrint(allocator, "input_{d}_{d}.txt", .{ year, day });
    defer allocator.free(relative_path);
    var file = try aoc_dir.createFile(relative_path, .{});
    defer file.close();

    aoc_log.info("Caching input to {s}", .{relative_path});
    try file.writer().writeAll(input);
}

fn writeJsonConfig(config: JsonConfig) !void {
    var aoc_dir = try fs.cwd().makeOpenPath(".aoc", .{});
    defer aoc_dir.close();

    var file = try aoc_dir.createFile("config.json", .{});
    defer file.close();

    try json.stringify(config, .{ .whitespace = .indent_2 }, file.writer());
}
