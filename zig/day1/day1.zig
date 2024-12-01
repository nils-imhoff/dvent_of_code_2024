const std = @import("std");

pub fn part1(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    var left = std.ArrayList(u32).init(alloc);
    defer left.deinit();

    var right = std.ArrayList(u32).init(alloc);
    defer right.deinit();

    var tokenizer = std.mem.tokenize(u8, input, "\n");
    while (tokenizer.next()) |line| {
        if (line.len == 0) continue; // Skip empty lines

        var numbers = std.mem.tokenize(u8, line, " ");
        const lnum_str = numbers.next() orelse continue;
        const rnum_str = numbers.next() orelse continue;

        const l_num = try std.fmt.parseInt(u32, lnum_str, 10);
        const r_num = try std.fmt.parseInt(u32, rnum_str, 10);

        try left.append(l_num);
        try right.append(r_num);
    }

    std.mem.sort(u32, left.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, comptime std.sort.asc(u32));

    var sum: u64 = 0;
    const len = left.items.len;
    for (0..len) |i| {
        const diff: i64 = @as(i64, left.items[i]) - @as(i64, right.items[i]);
        sum += @as(u64, @abs(diff));
    }

    std.debug.print("sum1:{d}\n", .{sum});
}

pub fn part2(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    var left = std.ArrayList(u32).init(alloc);
    defer left.deinit();

    var num_count = std.AutoHashMap(u32, u32).init(alloc);
    defer num_count.deinit();

    var tokenizer = std.mem.tokenize(u8, input, "\n");
    while (tokenizer.next()) |line| {
        if (line.len == 0) continue; // Skip empty lines

        var numbers = std.mem.tokenize(u8, line, " ");
        const lnum_str = numbers.next() orelse continue;
        const rnum_str = numbers.next() orelse continue;

        const l_num = try std.fmt.parseInt(u32, lnum_str, 10);
        const r_num = try std.fmt.parseInt(u32, rnum_str, 10);

        try left.append(l_num);

        const curr_count = num_count.get(r_num);
        if (curr_count) |count| {
            // If the number exists, increment its count
            try num_count.put(r_num, count + 1);
        } else {
            // If it's a new number, initialize its count to 1
            try num_count.put(r_num, 1);
        }
    }

    var sum: u64 = 0;
    for (left.items) |l_num| {
        if (num_count.get(l_num)) |count| {
            sum += @as(u64, l_num) * @as(u64, count);
        }
    }

    std.debug.print("sum2:{d}\n", .{sum});
}

const puzzle_input = @embedFile("input01.txt");

pub fn main() !void {
    try part1(puzzle_input);
    try part2(puzzle_input);
}
