const std = @import("std");

const Coords = packed struct { x: u8, y: u8 };
const Visited = u4;
const LEFT: Visited = 1;
const RIGHT: Visited = 2;
const UP: Visited = 4;
const DOWN: Visited = 8;

const VisitedEntry = struct { 
    pos: Coords, 
    dirs: Visited 
};

// Part 1
pub fn part1(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    const grid = try alloc.dupe(u8, input);
    defer alloc.free(grid);
    const w = std.mem.indexOfScalar(u8, grid, '\n').?;

    var total: u32 = 0;
    var visited = try std.ArrayList(u16).initCapacity(alloc, 256);
    defer visited.deinit();
    var nexts = try std.ArrayList(Coords).initCapacity(alloc, 128);
    defer nexts.deinit();

    for (0..w) |y| {
        for (0..w) |x| {
            const sx: u8 = @intCast(x);
            const sy: u8 = @intCast(y);
            if (index(Coords{ .x = sx, .y = sy }, w)) |i| {
                const plot_type = grid[i];
                if (plot_type == '.') continue;
                var perimeter: u32 = 0;
                visited.clearRetainingCapacity();
                nexts.clearRetainingCapacity();
                try nexts.append(.{ .x = sx, .y = sy });

                while (nexts.popOrNull()) |c| {
                    const cs: u16 = @bitCast(c);
                    if (std.mem.indexOfScalar(u16, visited.items, cs)) |_| continue;
                    try visited.append(cs);

                    if (check(c.x -% 1, c.y, w, grid, plot_type)) |p| try nexts.append(p) else perimeter += 1;
                    if (check(c.x + 1, c.y, w, grid, plot_type)) |p| try nexts.append(p) else perimeter += 1;
                    if (check(c.x, c.y -% 1, w, grid, plot_type)) |p| try nexts.append(p) else perimeter += 1;
                    if (check(c.x, c.y + 1, w, grid, plot_type)) |p| try nexts.append(p) else perimeter += 1;
                }

                const area = visited.items.len;
                const price = @as(u32, @intCast(area)) * perimeter;
                total += price;

                std.debug.print("Region {c}: Area={d}, Perimeter={d}, Price={d}\n", 
                    .{plot_type, area, perimeter, price});

                for (visited.items) |cs| {
                    const pos: Coords = @bitCast(cs);
                    if (index(pos, w)) |idx| {
                        grid[idx] = '.';
                    }
                }
            }
        }
    }

    std.debug.print("Total price: {d}\n", .{total});
}

// Part 2 Konstanten und Hilfsfunktionen
fn add(c: Coords, comptime dir: Visited) Coords {
    return switch (dir) {
        LEFT => .{ .x = c.x -% 1, .y = c.y },
        RIGHT => .{ .x = c.x + 1, .y = c.y },
        UP => .{ .x = c.x, .y = c.y -% 1 },
        DOWN => .{ .x = c.x, .y = c.y + 1 },
        else => unreachable,
    };
}

fn hat(comptime dir: Visited) Visited {
    return switch (dir) {
        RIGHT => UP,
        UP => LEFT,
        LEFT => DOWN,
        DOWN => RIGHT,
        else => unreachable,
    };
}

fn neg(comptime dir: Visited) Visited {
    return switch (dir) {
        LEFT => RIGHT,
        RIGHT => LEFT,
        UP => DOWN,
        DOWN => UP,
        else => unreachable,
    };
}

// Part 2
pub fn part2(input: []const u8) !void {
    const alloc = std.heap.page_allocator;

    const grid = try alloc.dupe(u8, input);
    defer alloc.free(grid);
    const w = std.mem.indexOfScalar(u8, grid, '\n').?;

    var total: u32 = 0;
    var visited = std.ArrayList(VisitedEntry).init(alloc);
    defer visited.deinit();
    try visited.ensureTotalCapacity(256);
    
    var nexts = std.ArrayList(Coords).init(alloc);
    defer nexts.deinit();
    try nexts.ensureTotalCapacity(128);

    for (0..w) |y| {
        for (0..w) |x| {
            const s = Coords{ .x = @intCast(x), .y = @intCast(y) };
            if (index(s, w)) |i| {
                const plot_type = grid[i];
                if (plot_type == '.') continue;
                var sides: u32 = 0;
                visited.clearRetainingCapacity();
                nexts.clearRetainingCapacity();
                try nexts.append(s);

                while (nexts.popOrNull()) |c| {
                    // Prüfe, ob Position bereits besucht
                    var found = false;
                    for (visited.items) |v| {
                        if (v.pos.x == c.x and v.pos.y == c.y) {
                            found = true;
                            break;
                        }
                    }
                    if (found) continue;

                    var v: Visited = 0;
                    // Prüfe jede Richtung einzeln
                    if (try check_dir(c, w, grid, plot_type, LEFT, &sides, &nexts, &visited)) {
                        v |= LEFT;
                    }
                    if (try check_dir(c, w, grid, plot_type, RIGHT, &sides, &nexts, &visited)) {
                        v |= RIGHT;
                    }
                    if (try check_dir(c, w, grid, plot_type, DOWN, &sides, &nexts, &visited)) {
                        v |= DOWN;
                    }
                    if (try check_dir(c, w, grid, plot_type, UP, &sides, &nexts, &visited)) {
                        v |= UP;
                    }
                    try visited.append(.{ .pos = c, .dirs = v });
                }

                const area = visited.items.len;
                const price = @as(u32, @intCast(area)) * sides;
                total += price;

                std.debug.print("Region {c}: Area={d}, Sides={d}, Price={d}\n", 
                    .{plot_type, area, sides, price});

                for (visited.items) |v| {
                    if (index(v.pos, w)) |idx| {
                        grid[idx] = '.';
                    }
                }
            }
        }
    }

    std.debug.print("Total price (sides): {d}\n", .{total});
}

// Gemeinsame Hilfsfunktionen
fn check(x: u8, y: u8, w: usize, grid: []const u8, c: u8) ?Coords {
    if (index(Coords{ .x = x, .y = y }, w)) |i| {
        if (grid[i] != c) return null;
        return .{ .x = x, .y = y };
    } else return null;
}

fn index(c: Coords, w: usize) ?usize {
    if (c.x < w and c.y < w) {
        return @as(usize, @intCast(c.x)) + @as(usize, @intCast(c.y)) * (w + 1);
    } else return null;
}

fn check_dir(c: Coords, w: usize, grid: []const u8, plot_type: u8, comptime dir: Visited, sides: *u32, nexts: *std.ArrayList(Coords), visited: *std.ArrayList(VisitedEntry)) !bool {
    const neighbour = add(c, dir);
    if (index(neighbour, w)) |ni| {
        if (grid[ni] == plot_type) {
            try nexts.append(neighbour);
            return false;
        }
    }

    var n: u2 = 0;
    for (visited.items) |entry| {
        const pos1 = add(c, hat(dir));
        const pos2 = add(c, neg(hat(dir)));
        if (std.meta.eql(entry.pos, pos1) and (entry.dirs & dir != 0)) n += 1;
        if (std.meta.eql(entry.pos, pos2) and (entry.dirs & dir != 0)) n += 1;
    }
    switch (n) {
        0 => sides.* += 1,
        2 => sides.* -= 1,
        else => {},
    }
    return true;
}

const puzzle_input = @embedFile("input12.txt");

pub fn main() !void {
    try part1(puzzle_input);
    try part2(puzzle_input);
}
