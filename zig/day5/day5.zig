const std = @import("std");

pub fn main() !void {
    const puzzle_input = @embedFile("input05.txt");
    try part1(puzzle_input);
    try part2(puzzle_input);
}

pub fn part1(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    // Split the input into rules and updates
    var split_input = std.mem.split(u8, input, "\n\n");
    const rules_input = split_input.next() orelse return error.InvalidInput;
    const updates_input = split_input.next() orelse return error.InvalidInput;

    // Parse rules
    var rules = std.ArrayList([2]u32).init(alloc);
    defer rules.deinit();
    var rules_iter = std.mem.split(u8, rules_input, "\n");
    while (rules_iter.next()) |line| {
        if (line.len == 0) continue;
        var parts = std.mem.split(u8, line, "|");
        const x = try std.fmt.parseInt(u32, parts.next() orelse continue, 10);
        const y = try std.fmt.parseInt(u32, parts.next() orelse continue, 10);
        try rules.append([2]u32{ x, y });
    }

    // Parse updates
    var updates = std.ArrayList([]u32).init(alloc);
    defer updates.deinit();
    var updates_iter = std.mem.split(u8, updates_input, "\n");
    while (updates_iter.next()) |line| {
        var update = std.ArrayList(u32).init(alloc);
        defer update.deinit();
        var nums_iter = std.mem.split(u8, line, ",");
        while (nums_iter.next()) |num| {
            const trimmed_num = std.mem.trim(u8, num, " \t\r\n");
            if (trimmed_num.len == 0) continue; // Skip empty entries
            try update.append(try std.fmt.parseInt(u32, trimmed_num, 10));
        }

        try updates.append(try update.toOwnedSlice());
    }

    // Check ordered updates and compute middle sum
    var total_middle_sum: u32 = 0;
    for (updates.items) |update| {
        if (is_ordered(update, rules.items)) {
            total_middle_sum += get_middle(update);
        }
    }

    std.debug.print("Part 1: Total middle sum is {d}\n", .{total_middle_sum});
}

pub fn part2(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    // Split the input into rules and updates
    var split_input = std.mem.split(u8, input, "\n\n");
    const rules_input = split_input.next() orelse return error.InvalidInput;
    const updates_input = split_input.next() orelse return error.InvalidInput;

    // Parse rules
    var rules = std.ArrayList([2]u32).init(alloc);
    defer rules.deinit();
    var rules_iter = std.mem.split(u8, rules_input, "\n");
    while (rules_iter.next()) |line| {
        if (line.len == 0) continue;
        var parts = std.mem.split(u8, line, "|");
        const x = try std.fmt.parseInt(u32, parts.next() orelse continue, 10);
        const y = try std.fmt.parseInt(u32, parts.next() orelse continue, 10);
        try rules.append([2]u32{ x, y });
    }

    // Parse updates
    var updates = std.ArrayList([]u32).init(alloc);
    defer updates.deinit();
    var updates_iter = std.mem.split(u8, updates_input, "\n");
    while (updates_iter.next()) |line| {
        var update = std.ArrayList(u32).init(alloc);
        defer update.deinit();
        var nums_iter = std.mem.split(u8, line, ",");
        while (nums_iter.next()) |num| {
            const trimmed_num = std.mem.trim(u8, num, " \t\r\n");
            if (trimmed_num.len == 0) continue; // Skip empty entries
            try update.append(try std.fmt.parseInt(u32, trimmed_num, 10));
        }

        try updates.append(try update.toOwnedSlice());
    }

    // Fix unordered updates and compute middle sum
    var total_middle_sum: u32 = 0;
    for (updates.items) |update| {
        if (!is_ordered(update, rules.items)) {
            const sorted_update = fix_order(update, rules.items, &alloc) catch continue;
            total_middle_sum += get_middle(sorted_update);
        }
    }

    std.debug.print("Part 2: Total middle sum is {d}\n", .{total_middle_sum});
}

// Check if an update is ordered correctly
fn is_ordered(update: []u32, rules: [][2]u32) bool {
    for (rules) |rule| {
        const x = rule[0];
        const y = rule[1];
        const x_index = find_index(update, x);
        const y_index = find_index(update, y);
        if (x_index != null and y_index != null and x_index.? > y_index.?) {
            return false;
        }
    }
    return true;
}

// Fix the order of an update using the rules
fn fix_order(update: []u32, rules: [][2]u32, alloc: *const std.mem.Allocator) ![]u32 {
    var graph = std.AutoHashMap(u32, std.AutoHashMap(u32, bool)).init(alloc.*);
    defer graph.deinit();

    var indegree = std.AutoHashMap(u32, usize).init(alloc.*);
    defer indegree.deinit();

    // Build graph and calculate indegrees
    for (rules) |rule| {
        const x = rule[0];
        const y = rule[1];
        if (!slice_contains(update, x) or !slice_contains(update, y)) continue;

        // Add edges
        if (!graph.contains(x)) {
            try graph.put(x, std.AutoHashMap(u32, bool).init(alloc.*));
        }
        const set_ptr = graph.getPtr(x) orelse return error.InvalidGraphAccess;
        try set_ptr.put(y, true);

        const y_entry = try indegree.getOrPut(y);
        if (!y_entry.found_existing) {
            y_entry.value_ptr.* = 1;
        } else {
            y_entry.value_ptr.* += 1;
        }

        const x_entry = try indegree.getOrPut(x);
        if (!x_entry.found_existing) {
            x_entry.value_ptr.* = 0;
        }
    }

    // Topological sort using Kahn's algorithm
    var queue = std.ArrayList(u32).init(alloc.*);
    defer queue.deinit();

    var iter = indegree.iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.* == 0) { // Dereference value_ptr
            try queue.append(entry.key_ptr.*); // Use key_ptr
        }
    }

    var result = std.ArrayList(u32).init(alloc.*);
    defer result.deinit();

    while (queue.items.len > 0) {
        const node = queue.pop();
        try result.append(node);

        if (graph.get(node)) |neighbors| {
            var neighbors_iter = neighbors.iterator();
            while (neighbors_iter.next()) |neighbor_entry| {
                const neighbor = neighbor_entry.key_ptr.*;
                const indegree_value = indegree.get(neighbor).?;
                if (indegree_value == 1) {
                    try queue.append(neighbor);
                } else {
                    const indegree_ptr = indegree.getPtr(neighbor) orelse return error.InvalidGraphAccess;
                    indegree_ptr.* -= 1;
                }
            }
        }
    }

    // Add remaining items from the update that are not in the graph
    for (update) |page| {
        if (!array_list_contains(result, page)) {
            try result.append(page);
        }
    }

    return result.toOwnedSlice();
}

fn array_list_contains(list: std.ArrayList(u32), value: u32) bool {
    for (list.items) |item| {
        if (item == value) {
            return true;
        }
    }
    return false;
}

fn slice_contains(slice: []u32, value: u32) bool {
    for (slice) |item| {
        if (item == value) return true;
    }
    return false;
}

fn initHashSet(alloc: *std.mem.Allocator) !std.AutoHashSet(u32) {
    return try std.AutoHashSet(u32).init(alloc);
}

// Get the middle page of an update
fn get_middle(update: []u32) u32 {
    if (update.len == 0) return 0;
    return update[update.len / 2];
}

// Find the index of a page in an update
fn find_index(array: []u32, value: u32) ?usize {
    var i: usize = 0;
    for (array) |item| {
        if (item == value) return i;
        i += 1;
    }

    return null;
}
