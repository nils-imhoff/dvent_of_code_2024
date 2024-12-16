const std = @import("std");

const input = @embedFile("input10.txt");

pub fn main() !void {
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = gpa.deinit();

    const file_data = input;

    const w = std.mem.indexOf(u8, file_data, "\n").? + 1;

    const part1_result = part1(file_data, .{gpa.allocator()});
    const part2_result = part2(file_data, w, gpa.allocator());

    std.debug.print("Part 1 Result: {d}\n", .{part1_result});
    std.debug.print("Part 2 Result: {d}\n", .{part2_result});
}

fn part1(file_data: []const u8, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];

    const w = std.mem.indexOf(u8, file_data, "\n").? + 1;

    var total: u32 = 0;

    for (0..w - 1) |y| {
        for (0..w - 1) |x| {
            const i = index(x, y, w).?;
            if (file_data[i] == '0') {
                total += check_trail_score(file_data, w, @intCast(x), @intCast(y), alloc);
            }
        }
    }

    return total;
}

fn part2(file_data: []const u8, w: usize, alloc: std.mem.Allocator) u32 {
    var total: u32 = 0;

    for (0..w - 1) |y| {
        for (0..w - 1) |x| {
            const i = index(x, y, w).?;
            if (file_data[i] == '0') {
                const score = check_trail_rating(file_data, w, @intCast(x), @intCast(y), alloc);
                total += score;
            }
        }
    }

    return total;
}

const Pos = struct { i8, i8 };
const PosWithHeight = struct { i8, i8, u8 };
const Trail = std.BoundedArray(Pos, 10);

fn check_trail_score(file_data: []const u8, w: usize, sx: i8, sy: i8, alloc: std.mem.Allocator) u32 {
    var grid = alloc.dupe(u8, file_data) catch unreachable;
    defer alloc.free(grid);

    var next = std.ArrayList(PosWithHeight).initCapacity(alloc, 32) catch unreachable;
    defer next.deinit();
    next.append(.{ sx, sy, '0' }) catch unreachable;

    var score: u32 = 0;

    while (next.popOrNull()) |p| {
        const pi = index(p[0], p[1], w).?;
        const this_h = grid[pi];
        if (this_h == p[2]) {
            grid[pi] = '.';
            if (this_h == '9') {
                score += 1;
                continue;
            }
            const nh = this_h + 1;
            if (check_trail_pos(p[0] + 1, p[1], nh, w)) |n| next.append(n) catch unreachable;
            if (check_trail_pos(p[0] - 1, p[1], nh, w)) |n| next.append(n) catch unreachable;
            if (check_trail_pos(p[0], p[1] + 1, nh, w)) |n| next.append(n) catch unreachable;
            if (check_trail_pos(p[0], p[1] - 1, nh, w)) |n| next.append(n) catch unreachable;
        }
    }

    return score;
}

fn check_trail_rating(file_data: []const u8, w: usize, sx: i8, sy: i8, alloc: std.mem.Allocator) u32 {
    var next = std.ArrayList(Trail).initCapacity(alloc, 16) catch unreachable;
    defer next.deinit();
    var first_trail = Trail.init(1) catch unreachable;
    first_trail.set(0, .{ sx, sy });
    next.append(first_trail) catch unreachable;

    var score: u32 = 0;

    while (next.popOrNull()) |trail| {
        const ti = trail.len - 1;
        const th = '0' + @as(u8, @intCast(ti));
        const p = trail.get(ti);
        const this_h = file_data[index(p[0], p[1], w).?];
        if (this_h == th) {
            if (this_h == '9') {
                score += 1;
                continue;
            }
            if (check_trail_trail(p[0] + 1, p[1], w, trail)) |t| next.append(t) catch unreachable;
            if (check_trail_trail(p[0] - 1, p[1], w, trail)) |t| next.append(t) catch unreachable;
            if (check_trail_trail(p[0], p[1] + 1, w, trail)) |t| next.append(t) catch unreachable;
            if (check_trail_trail(p[0], p[1] - 1, w, trail)) |t| next.append(t) catch unreachable;
        }
    }

    return score;
}

fn check_trail_pos(x: i8, y: i8, h: u8, w: usize) ?PosWithHeight {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        return .{ x, y, h };
    } else return null;
}

fn check_trail_trail(x: i8, y: i8, w: usize, trail: Trail) ?Trail {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        var nt = trail;
        for (trail.slice()) |t| {
            if (t[0] == x and t[1] == y) return null;
        }
        nt.append(.{ x, y }) catch unreachable;
        return nt;
    } else return null;
}

fn index(x: anytype, y: anytype, w: usize) ?usize {
    if (x >= 0 and y >= 0 and x < w - 1 and y < w - 1) {
        return @as(usize, @intCast(x)) + @as(usize, @intCast(y)) * w;
    } else return null;
}
