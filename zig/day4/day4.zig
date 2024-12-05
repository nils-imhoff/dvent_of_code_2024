const std = @import("std");

pub fn main() !void {
    const puzzle_input = @embedFile("input04.txt");
    try part1(puzzle_input);
    try part2(puzzle_input);
}

pub fn part1(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    // Read the input lines into an ArrayList
    var lines = std.ArrayList([]const u8).init(alloc);
    defer lines.deinit();

    var tokenizer = std.mem.tokenize(u8, input, "\n");
    while (tokenizer.next()) |line| {
        if (line.len == 0) continue; // Skip empty lines
        try lines.append(line);
    }

    const num_rows = lines.items.len;
    if (num_rows == 0) {
        std.debug.print("Part 1: 0\n", .{});
        return;
    }
    const num_cols = lines.items[0].len;

    const word = "XMAS";

    const dirs = [_][2]i32{
        [_]i32{ 1, 0 }, // Right
        [_]i32{ -1, 0 }, // Left
        [_]i32{ 0, 1 }, // Down
        [_]i32{ 0, -1 }, // Up
        [_]i32{ 1, 1 }, // Diagonal down-right
        [_]i32{ -1, -1 }, // Diagonal up-left
        [_]i32{ 1, -1 }, // Diagonal down-left
        [_]i32{ -1, 1 }, // Diagonal up-right
    };

    var count: usize = 0;

    for (0..num_rows) |row| {
        for (0..num_cols) |col| {
            for (dirs) |dir| {
                if (try match_word(lines.items, word, row, col, dir[1], dir[0], num_rows, num_cols)) {
                    count += 1;
                }
            }
        }
    }

    std.debug.print("Part 1: {d}\n", .{count});
}

fn match_word(grid: [][]const u8, word: []const u8, start_row: usize, start_col: usize, dy: i32, dx: i32, num_rows: usize, num_cols: usize) !bool {
    const word_len = word.len;
    var x: i32 = @intCast(start_col);
    var y: i32 = @intCast(start_row);

    const max_cols: i32 = @intCast(num_cols);
    const max_rows: i32 = @intCast(num_rows);

    for (0..word_len) |i| {
        if (x < 0 or x >= max_cols or y < 0 or y >= max_rows) {
            return false;
        }
        const c = grid[@intCast(y)][@intCast(x)];
        if (c != word[i]) {
            return false;
        }
        x += dx;
        y += dy;
    }
    return true;
}

pub fn part2(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    // Read the input lines into an ArrayList
    var lines = std.ArrayList([]const u8).init(alloc);
    defer lines.deinit();

    var tokenizer = std.mem.tokenize(u8, input, "\n");
    while (tokenizer.next()) |line| {
        if (line.len == 0) continue; // Skip empty lines
        try lines.append(line);
    }

    const num_rows = lines.items.len;
    if (num_rows == 0) {
        std.debug.print("Part 2: 0\n", .{});
        return;
    }
    const num_cols = lines.items[0].len;

    const starts = [_][2][2]i32{
        .{ .{ -1, 1 }, .{ 1, 1 } },
        .{ .{ 1, 1 }, .{ 1, -1 } },
        .{ .{ 1, -1 }, .{ -1, -1 } },
        .{ .{ -1, -1 }, .{ -1, 1 } },
    };

    var count: usize = 0;

    for (0..num_rows) |row| {
        for (0..num_cols) |col| {
            for (starts) |start| {
                if (try match_special(lines.items, row, col, start, num_rows, num_cols)) {
                    count += 1;
                }
            }
        }
    }

    std.debug.print("Part 2: {d}\n", .{count});
}

fn match_special(grid: [][]const u8, start_row: usize, start_col: usize, starts: [2][2]i32, num_rows: usize, num_cols: usize) !bool {
    if (grid[start_row][start_col] != 'A') {
        return false;
    }

    const max_cols: i32 = @intCast(num_cols);
    const max_rows: i32 = @intCast(num_rows);

    const x1m: i32 = @as(i32, @intCast(start_col)) + starts[0][0];
    const y1m: i32 = @as(i32, @intCast(start_row)) + starts[0][1];
    const x1s: i32 = @as(i32, @intCast(start_col)) - starts[0][0];
    const y1s: i32 = @as(i32, @intCast(start_row)) - starts[0][1];
    const x2m: i32 = @as(i32, @intCast(start_col)) + starts[1][0];
    const y2m: i32 = @as(i32, @intCast(start_row)) + starts[1][1];
    const x2s: i32 = @as(i32, @intCast(start_col)) - starts[1][0];
    const y2s: i32 = @as(i32, @intCast(start_row)) - starts[1][1];

    if (y1m >= 0 and y1m < max_rows and x1m >= 0 and x1m < max_cols and grid[@intCast(y1m)][@intCast(x1m)] == 'M' and
        y1s >= 0 and y1s < max_rows and x1s >= 0 and x1s < max_cols and grid[@intCast(y1s)][@intCast(x1s)] == 'S' and
        y2m >= 0 and y2m < max_rows and x2m >= 0 and x2m < max_cols and grid[@intCast(y2m)][@intCast(x2m)] == 'M' and
        y2s >= 0 and y2s < max_rows and x2s >= 0 and x2s < max_cols and grid[@intCast(y2s)][@intCast(x2s)] == 'S')
    {
        return true;
    }

    return false;
}
