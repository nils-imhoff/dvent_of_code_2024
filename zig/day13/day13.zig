const std = @import("std");

const Machine = struct {
    button_a: struct { x: i64, y: i64 },
    button_b: struct { x: i64, y: i64 },
    prize: struct { x: i64, y: i64 },
};

fn parseInput(input: []const u8, allocator: std.mem.Allocator) !std.ArrayList(Machine) {
    var machines = std.ArrayList(Machine).init(allocator);
    var lines = std.mem.tokenize(u8, input, "\r\n");

    while (lines.next()) |line| {
        // Button A
        if (!std.mem.startsWith(u8, line, "Button A: X+")) continue;
        const a_x_str = line["Button A: X+".len..];
        const a_comma = std.mem.indexOf(u8, a_x_str, ", Y+") orelse return error.InvalidInput;
        const ax = try std.fmt.parseInt(i64, a_x_str[0..a_comma], 10);
        const ay = try std.fmt.parseInt(i64, a_x_str[a_comma + ", Y+".len..], 10);

        // Button B
        const b_line = lines.next() orelse return error.InvalidInput;
        if (!std.mem.startsWith(u8, b_line, "Button B: X+")) return error.InvalidInput;
        const b_x_str = b_line["Button B: X+".len..];
        const b_comma = std.mem.indexOf(u8, b_x_str, ", Y+") orelse return error.InvalidInput;
        const bx = try std.fmt.parseInt(i64, b_x_str[0..b_comma], 10);
        const by = try std.fmt.parseInt(i64, b_x_str[b_comma + ", Y+".len..], 10);

        // Prize
        const p_line = lines.next() orelse return error.InvalidInput;
        if (!std.mem.startsWith(u8, p_line, "Prize: X=")) return error.InvalidInput;
        const p_x_str = p_line["Prize: X=".len..];
        const p_comma = std.mem.indexOf(u8, p_x_str, ", Y=") orelse return error.InvalidInput;
        const px = try std.fmt.parseInt(i64, p_x_str[0..p_comma], 10);
        const py = try std.fmt.parseInt(i64, p_x_str[p_comma + ", Y=".len..], 10);

        try machines.append(.{
            .button_a = .{ .x = ax, .y = ay },
            .button_b = .{ .x = bx, .y = by },
            .prize = .{ .x = px, .y = py },
        });
    }
    return machines;
}

fn solveMachinePart1(machine: Machine) ?u32 {
    const max_presses = 100;
    
    for (0..max_presses + 1) |a| {
        for (0..max_presses + 1) |b| {
            const x = @as(i64, @intCast(a)) * machine.button_a.x + @as(i64, @intCast(b)) * machine.button_b.x;
            const y = @as(i64, @intCast(a)) * machine.button_a.y + @as(i64, @intCast(b)) * machine.button_b.y;
            
            if (x == machine.prize.x and y == machine.prize.y) {
                return @as(u32, @intCast(a)) * 3 + @as(u32, @intCast(b));
            }
        }
    }
    return null;
}

fn solveMachinePart2(machine: Machine) ?u64 {
    const det = @as(i64, machine.button_a.x) * @as(i64, machine.button_b.y) - 
                @as(i64, machine.button_a.y) * @as(i64, machine.button_b.x);
    
    if (det == 0) return null;

    const det_a = @as(i64, machine.prize.x) * @as(i64, machine.button_b.y) - 
                  @as(i64, machine.button_b.x) * @as(i64, machine.prize.y);
    const det_b = @as(i64, machine.button_a.x) * @as(i64, machine.prize.y) - 
                  @as(i64, machine.prize.x) * @as(i64, machine.button_a.y);

    if (@rem(det_a, det) != 0 or @rem(det_b, det) != 0) return null;
    
    const a = @divExact(det_a, det);
    const b = @divExact(det_b, det);

    if (a < 0 or b < 0) return null;

    return @as(u64, @intCast(a)) * 3 + @as(u64, @intCast(b));
}

pub fn part1(input: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var machines = try parseInput(input, allocator);
    defer machines.deinit();

    var total_tokens: u32 = 0;
    var winnable_prizes: u32 = 0;

    for (machines.items) |machine| {
        if (solveMachinePart1(machine)) |tokens| {
            total_tokens += tokens;
            winnable_prizes += 1;
        }
    }

    std.debug.print("Teil 1:\n", .{});
    std.debug.print("Gewinnbare Preise: {d}\n", .{winnable_prizes});
    std.debug.print("Benötigte Token insgesamt: {d}\n\n", .{total_tokens});
}

pub fn part2(input: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var machines = try parseInput(input, allocator);
    defer machines.deinit();

    const offset: i64 = 10000000000000;
    for (machines.items) |*machine| {
        machine.prize.x += offset;
        machine.prize.y += offset;
    }

    var total_tokens: u64 = 0;
    var winnable_prizes: u32 = 0;

    for (machines.items) |machine| {
        if (solveMachinePart2(machine)) |tokens| {
            total_tokens += tokens;
            winnable_prizes += 1;
        }
    }

    std.debug.print("Teil 2:\n", .{});
    std.debug.print("Gewinnbare Preise: {d}\n", .{winnable_prizes});
    std.debug.print("Benötigte Token insgesamt: {d}\n", .{total_tokens});
}

pub fn main() !void {
    try part1(puzzle_input);
    try part2(puzzle_input);
}

const puzzle_input = @embedFile("input13.txt"); 