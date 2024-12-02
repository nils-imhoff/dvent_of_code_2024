const std = @import("std");

fn is_safe(report: []const i32) bool {
    if (report.len <= 1) {
        return true;
    }

    var prev = report[0];
    var increasing = report[1] >= report[0];

    for (1..report.len) |i| {
        const curr = report[i];
        const diff = curr - prev;
        const abs_diff = @abs(diff);

        if (abs_diff < 1 or abs_diff > 3) {
            return false;
        }

        if ((increasing and diff < 0) or ((!increasing) and diff > 0)) {
            return false;
        }

        prev = curr;
        increasing = diff >= 0;
    }

    return true;
}

fn is_safe_with_removal(report: []const i32) bool {
    if (is_safe(report)) {
        return true;
    }

    if (report.len <= 1) {
        return true;
    }

    for (0..report.len) |skip_idx| {
        if (is_safe_skipping_index(report, skip_idx)) {
            return true;
        }
    }

    return false;
}

fn is_safe_skipping_index(report: []const i32, skip_idx: usize) bool {
    const len = report.len;

    var first_idx: ?usize = null;
    var second_idx: ?usize = null;

    // Find the first two indices not equal to skip_idx
    for (0..len) |i| {
        if (i == skip_idx) continue;
        if (first_idx == null) {
            first_idx = i;
        } else if (second_idx == null) {
            second_idx = i;
            break;
        }
    }

    if (first_idx == null) {
        // No elements left after skipping
        return true;
    } else if (second_idx == null) {
        // Only one element left after skipping
        return true;
    }

    var prev = report[first_idx.?];
    var curr = report[second_idx.?];
    var diff = curr - prev;
    var abs_diff = @abs(diff);

    if (abs_diff < 1 or abs_diff > 3) {
        return false;
    }

    const increasing = diff >= 0;
    prev = curr;

    var i = second_idx.? + 1;
    while (i < len) : (i += 1) {
        if (i == skip_idx) continue;
        curr = report[i];
        diff = curr - prev;
        abs_diff = @abs(diff);

        if (abs_diff < 1 or abs_diff > 3) {
            return false;
        }

        if ((increasing and diff < 0) or ((!increasing) and diff > 0)) {
            return false;
        }

        prev = curr;
    }

    return true;
}

pub fn main() !void {
    const input = @embedFile("input02.txt");
    const allocator = std.heap.page_allocator;

    var tokenizer = std.mem.tokenize(u8, input, "\n");
    var safe_count_part1: usize = 0;
    var safe_count_part2: usize = 0;

    while (tokenizer.next()) |line| {
        if (line.len == 0) {
            continue; // Skip empty lines
        }

        var report = std.ArrayList(i32).init(allocator);
        defer report.deinit();

        var numbers = std.mem.tokenize(u8, line, " ");
        while (numbers.next()) |num_str| {
            const num = try std.fmt.parseInt(i32, num_str, 10);
            try report.append(num);
        }

        if (is_safe(report.items)) {
            safe_count_part1 += 1;
            safe_count_part2 += 1; // Safe in both parts
        } else if (is_safe_with_removal(report.items)) {
            safe_count_part2 += 1; // Safe only in Part 2
        }
    }

    std.debug.print("Part 1 - Number of safe reports: {}\n", .{safe_count_part1});
    std.debug.print("Part 2 - Number of safe reports with Problem Dampener: {}\n", .{safe_count_part2});
}
