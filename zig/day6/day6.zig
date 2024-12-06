const std = @import("std");
const ArrayList = std.ArrayList;

const input = @embedFile("./input06.txt");
const allocator = std.heap.page_allocator;
const Direction = enum { north, south, east, west };

const Point = struct {
    x: i32,
    y: i32,

    // Custom hash function for Point
    fn hash(self: Point) i32 {
        // XOR the x and y coordinates to create a hash value
        return self.x ^ self.y;
    }

    // Custom equality function for Point
    fn eq(self: Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }
};

const PointD = struct {
    x: i32,
    y: i32,
    direction: Direction,

    // Custom hash function for PointD
    fn hash(self: PointD) i32 {
        // XOR the x, y, and direction to create a hash value
        return @as(i32, @intCast(self.x)) ^ @as(i32, @intCast(self.y)) ^ @as(i32, @intCast(self.direction));
    }

    // Custom equality function for PointD
    fn eq(self: PointD, other: PointD) bool {
        return self.x == other.x and self.y == other.y and self.direction == other.direction;
    }
};

pub fn main() !void {
    const part1Answer = solvePartOne(input);
    std.debug.print("Part 1  = {any}.\n", .{part1Answer});
    const part2Answer = solvePartTwo(input);
    std.debug.print("Part 2  = {any}.\n", .{part2Answer});
}

pub fn solvePartOne(data: []const u8) !u32 {
    var lines = std.mem.split(u8, data, "\n");

    var currentPos = Point{ .x = 0, .y = 0 };

    var grid = ArrayList([]const u8).init(allocator);
    defer grid.deinit();
    var lineIndex: i32 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        try grid.append(line);
        var index: u32 = 0;
        while (index < line.len) : (index += 1) {
            if (line[index] == '^') {
                const xx: i32 = @intCast(index);
                const yy: i32 = @intCast(lineIndex);
                currentPos = Point{ .x = xx, .y = yy };
            }
        }
    }

    var unique_points = std.AutoHashMap(Point, u32).init(allocator);
    defer unique_points.deinit();

    var inGrid: bool = true;

    var direction = Direction.north;

    const totalRows: usize = grid.items.len;
    const totalCols: usize = grid.items[0].len;
    try unique_points.put(currentPos, 0);

    while (inGrid) {
        var nextPos = Point{ .x = 0, .y = 0 };
        switch (direction) {
            Direction.north => {
                nextPos = Point{ .x = currentPos.x, .y = currentPos.y - 1 };
            },
            Direction.east => {
                nextPos = Point{ .x = currentPos.x + 1, .y = currentPos.y };
            },
            Direction.south => {
                nextPos = Point{ .x = currentPos.x, .y = currentPos.y + 1 };
            },
            else => { // Direction.west
                nextPos = Point{ .x = currentPos.x - 1, .y = currentPos.y };
            },
        }

        // Check if the next position is within grid bounds
        if (nextPos.x < 0 or nextPos.x >= @as(i32, @intCast(totalCols)) or nextPos.y < 0 or nextPos.y >= @as(i32, @intCast(totalRows))) {
            inGrid = false;
            break;
        }

        const xx: usize = @intCast(nextPos.x);
        const yy: usize = @intCast(nextPos.y);
        const b = grid.items[yy][xx];

        if (b != '#') {
            currentPos = nextPos;
            try unique_points.put(nextPos, 0);
            continue;
        }

        // Change direction
        switch (direction) {
            Direction.north => {
                direction = Direction.east;
            },
            Direction.east => {
                direction = Direction.south;
            },
            Direction.south => {
                direction = Direction.west;
            },
            else => { // Direction.west
                direction = Direction.north;
            },
        }
    }

    return unique_points.count();
}

pub fn solvePartTwo(data: []const u8) !u32 {
    var lines = std.mem.split(u8, data, "\n");

    var currentPos = PointD{ .x = 0, .y = 0, .direction = Direction.north };
    var startPos = PointD{ .x = 0, .y = 0, .direction = Direction.north };

    var grid = ArrayList([]const u8).init(allocator);
    defer grid.deinit();
    var lineIndex: i32 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        try grid.append(line);
        var index: u32 = 0;
        while (index < line.len) : (index += 1) {
            if (line[index] == '^') {
                const xx: i32 = @intCast(index);
                const yy: i32 = @intCast(lineIndex);
                currentPos = PointD{ .x = xx, .y = yy, .direction = Direction.north };
                startPos = PointD{ .x = xx, .y = yy, .direction = Direction.north };
            }
        }
    }

    var unique_points = std.AutoHashMap(Point, u32).init(allocator);
    defer unique_points.deinit();

    var inGrid: bool = true;

    const totalRows: usize = grid.items.len;
    const totalCols: usize = grid.items[0].len;
    try unique_points.put(Point{ .x = currentPos.x, .y = currentPos.y }, 0);

    while (inGrid) {
        var nextPos = PointD{ .x = 0, .y = 0, .direction = Direction.north };
        switch (currentPos.direction) {
            Direction.north => {
                nextPos = PointD{ .x = currentPos.x, .y = currentPos.y - 1, .direction = Direction.north };
            },
            Direction.east => {
                nextPos = PointD{ .x = currentPos.x + 1, .y = currentPos.y, .direction = Direction.east };
            },
            Direction.south => {
                nextPos = PointD{ .x = currentPos.x, .y = currentPos.y + 1, .direction = Direction.south };
            },
            else => { // Direction.west
                nextPos = PointD{ .x = currentPos.x - 1, .y = currentPos.y, .direction = Direction.west };
            },
        }

        // Check if the next position is within grid bounds
        if (nextPos.x < 0 or nextPos.x >= @as(i32, @intCast(totalCols)) or nextPos.y < 0 or nextPos.y >= @as(i32, @intCast(totalRows))) {
            inGrid = false;
            break;
        }

        const xx: usize = @intCast(nextPos.x);
        const yy: usize = @intCast(nextPos.y);
        const b = grid.items[yy][xx];

        if (b != '#') {
            currentPos = nextPos;
            try unique_points.put(Point{ .x = currentPos.x, .y = currentPos.y }, unique_points.count() + 1);
            continue;
        }

        // Change direction
        switch (currentPos.direction) {
            Direction.north => {
                currentPos.direction = Direction.east;
            },
            Direction.east => {
                currentPos.direction = Direction.south;
            },
            Direction.south => {
                currentPos.direction = Direction.west;
            },
            else => { // Direction.west
                currentPos.direction = Direction.north;
            },
        }
        try unique_points.put(Point{ .x = currentPos.x, .y = currentPos.y }, unique_points.count() + 1);
    }

    var count: u32 = 0;

    // Iterate through unique points
    var iter = unique_points.iterator();
    var index: usize = 0;
    while (iter.next()) |entry| {
        defer index += 1;

        const point: Point = entry.key_ptr.*;
        if (point.x == startPos.x and point.y == startPos.y) {
            continue;
        }
        if (leavesGrid(grid, point, startPos, totalRows, totalCols)) {
            continue;
        }
        count += 1;
    }

    return count;
}

fn leavesGrid(grid: ArrayList([]const u8), pointToPutObstacle: Point, startPos: PointD, totalRows: usize, totalCols: usize) bool {
    var currentPos = startPos;

    var pathTaken = std.AutoHashMap(PointD, u32).init(allocator);
    defer pathTaken.deinit();
    pathTaken.put(currentPos, 0) catch |err| {
        std.debug.print("Failed to put into the map: {}\n", .{err});
        return false;
    };
    var inGrid = true;
    while (inGrid) {
        var nextPos = PointD{ .x = 0, .y = 0, .direction = Direction.north };
        switch (currentPos.direction) {
            Direction.north => {
                nextPos = PointD{ .x = currentPos.x, .y = currentPos.y - 1, .direction = Direction.north };
            },
            Direction.east => {
                nextPos = PointD{ .x = currentPos.x + 1, .y = currentPos.y, .direction = Direction.east };
            },
            Direction.south => {
                nextPos = PointD{ .x = currentPos.x, .y = currentPos.y + 1, .direction = Direction.south };
            },
            else => { // Direction.west
                nextPos = PointD{ .x = currentPos.x - 1, .y = currentPos.y, .direction = Direction.west };
            },
        }

        // Check if the next position is within grid bounds
        if (nextPos.x < 0 or nextPos.x >= @as(i32, @intCast(totalCols)) or nextPos.y < 0 or nextPos.y >= @as(i32, @intCast(totalRows))) {
            inGrid = false;
            break;
        }

        const xx: usize = @intCast(nextPos.x);
        const yy: usize = @intCast(nextPos.y);
        const b = grid.items[yy][xx];

        if (b == '#' or (nextPos.x == pointToPutObstacle.x and nextPos.y == pointToPutObstacle.y)) {
            // Change direction
            switch (currentPos.direction) {
                Direction.north => {
                    currentPos.direction = Direction.east;
                },
                Direction.east => {
                    currentPos.direction = Direction.south;
                },
                Direction.south => {
                    currentPos.direction = Direction.west;
                },
                else => { // Direction.west
                    currentPos.direction = Direction.north;
                },
            }
        } else {
            currentPos = nextPos;
        }

        if (pathTaken.contains(currentPos)) {
            return false;
        }

        pathTaken.put(currentPos, 0) catch |err| {
            std.debug.print("Failed to put into the map: {}\n", .{err});
            return true;
        };
    }
    return true;
}
