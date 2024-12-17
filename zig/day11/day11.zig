const std = @import("std");

fn splitNumber(num: u64) [2]u64 {
    var digits: [20]u8 = undefined;
    var temp = num;
    var count: usize = 0;

    // Extract digits
    while (temp != 0) {
        digits[count] = @as(u8, @intCast(temp % 10));
        temp /= 10;
        count += 1;
    }

    // Rebuild left and right halves
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

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    // Read input
    const file = try std.fs.cwd().openFile("input11.txt", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var tokenizer = std.mem.tokenize(u8, buffer[0..try file.readAll(&buffer)], " \n\t");

    var stone_counts = std.AutoHashMap(u64, u64).init(allocator);
    defer stone_counts.deinit();

    while (tokenizer.next()) |token| {
        const value = try std.fmt.parseInt(u64, token, 10);
        try stone_counts.put(value, 1); // Initialize frequency map
    }

    // Perform transformations
    for (0..75) |blink| {
        var new_stone_counts = std.AutoHashMap(u64, u64).init(allocator);

        var iterator = stone_counts.iterator();
        while (iterator.next()) |entry| {
            const stone = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            if (stone == 0) {
                // Rule 1: 0 -> 1
                if (new_stone_counts.get(1)) |existing_count| {
                    try new_stone_counts.put(1, existing_count + count);
                } else {
                    try new_stone_counts.put(1, count);
                }
            } else if (numDigits(stone) % 2 == 0) {
                // Rule 2: Split into two stones
                const halves = splitNumber(stone);
                for (halves) |half| {
                    if (new_stone_counts.get(half)) |existing_count| {
                        try new_stone_counts.put(half, existing_count + count);
                    } else {
                        try new_stone_counts.put(half, count);
                    }
                }
            } else {
                // Rule 3: Multiply by 2024
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

        // Print result for 25 blinks
        if (blink == 24) {
            var total: u64 = 0;
            var temp_iterator = stone_counts.iterator();
            while (temp_iterator.next()) |entry| {
                total += entry.value_ptr.*;
            }
            try stdout.print("Number of stones after 25 blinks: {}\n", .{total});
        }
    }

    // Calculate total number of stones after 75 blinks
    var total: u64 = 0;
    var final_iterator = stone_counts.iterator();
    while (final_iterator.next()) |entry| {
        total += entry.value_ptr.*;
    }

    try stdout.print("Number of stones after 75 blinks: {}\n", .{total});
}
