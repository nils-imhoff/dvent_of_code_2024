const std = @import("std");

fn splitNumber(num: u64) [2]u64 {
    var digits: [20]u8 = undefined;
    var temp = num;
    var count: usize = 0;

    while (temp != 0) {
        digits[count] = @as(u8, @intCast(temp % 10));
        temp /= 10;
        count += 1;
    }

    const half = count / 2;
    var left: u64 = 0;
    var right: u64 = 0;

    for (0..half) |i| {
        left = left * 10 + digits[count - i - 1];
    }
    for (half..count) |i| {
        right = right * 10 + digits[count - i - 1];
    }

    return .{ left, right };
}

fn numDigits(num: u64) u8 {
    if (num == 0) return 1;
    var temp = num;
    var count: u8 = 0;
    while (temp != 0) {
        temp /= 10;
        count += 1;
    }
    return count;
}

pub fn part1(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    var stone_counts = std.AutoHashMap(u64, u64).init(alloc);
    defer stone_counts.deinit();

    // Parse input
    var tokenizer = std.mem.tokenize(u8, input, " \n\t");
    while (tokenizer.next()) |token| {
        const value = try std.fmt.parseInt(u64, token, 10);
        try stone_counts.put(value, 1);
    }

    // Perform 25 transformations
    for (0..25) |_| {
        var new_stone_counts = std.AutoHashMap(u64, u64).init(alloc);

        var iterator = stone_counts.iterator();
        while (iterator.next()) |entry| {
            const stone = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            if (stone == 0) {
                if (new_stone_counts.get(1)) |existing_count| {
                    try new_stone_counts.put(1, existing_count + count);
                } else {
                    try new_stone_counts.put(1, count);
                }
            } else if (numDigits(stone) % 2 == 0) {
                const halves = splitNumber(stone);
                for (halves) |half| {
                    if (new_stone_counts.get(half)) |existing_count| {
                        try new_stone_counts.put(half, existing_count + count);
                    } else {
                        try new_stone_counts.put(half, count);
                    }
                }
            } else {
                const new_stone = try std.math.mul(u64, stone, 2024);
                if (new_stone_counts.get(new_stone)) |existing_count| {
                    try new_stone_counts.put(new_stone, existing_count + count);
                } else {
                    try new_stone_counts.put(new_stone, count);
                }
            }
        }

        stone_counts.deinit();
        stone_counts = new_stone_counts;
    }

    var total: u64 = 0;
    var final_iterator = stone_counts.iterator();
    while (final_iterator.next()) |entry| {
        total += entry.value_ptr.*;
    }

    std.debug.print("Number of stones after 25 blinks: {}\n", .{total});
}

pub fn part2(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    var stone_counts = std.AutoHashMap(u64, u64).init(alloc);
    defer stone_counts.deinit();

    // Parse input
    var tokenizer = std.mem.tokenize(u8, input, " \n\t");
    while (tokenizer.next()) |token| {
        const value = try std.fmt.parseInt(u64, token, 10);
        try stone_counts.put(value, 1);
    }

    // Perform 75 transformations
    for (0..75) |_| {
        var new_stone_counts = std.AutoHashMap(u64, u64).init(alloc);

        var iterator = stone_counts.iterator();
        while (iterator.next()) |entry| {
            const stone = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            if (stone == 0) {
                if (new_stone_counts.get(1)) |existing_count| {
                    try new_stone_counts.put(1, existing_count + count);
                } else {
                    try new_stone_counts.put(1, count);
                }
            } else if (numDigits(stone) % 2 == 0) {
                const halves = splitNumber(stone);
                for (halves) |half| {
                    if (new_stone_counts.get(half)) |existing_count| {
                        try new_stone_counts.put(half, existing_count + count);
                    } else {
                        try new_stone_counts.put(half, count);
                    }
                }
            } else {
                const new_stone = try std.math.mul(u64, stone, 2024);
                if (new_stone_counts.get(new_stone)) |existing_count| {
                    try new_stone_counts.put(new_stone, existing_count + count);
                } else {
                    try new_stone_counts.put(new_stone, count);
                }
            }
        }

        stone_counts.deinit();
        stone_counts = new_stone_counts;
    }

    var total: u64 = 0;
    var final_iterator = stone_counts.iterator();
    while (final_iterator.next()) |entry| {
        total += entry.value_ptr.*;
    }

    std.debug.print("Number of stones after 75 blinks: {}\n", .{total});
}

const puzzle_input = @embedFile("input11.txt");

pub fn main() !void {
    try part1(puzzle_input);
    try part2(puzzle_input);
}
