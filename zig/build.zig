const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Liste der Tage, für die wir Programme haben
    const days = [_][]const u8{
        "day1",
        "day2",
        "day3",
        "day5",
        "day10",
        "day11",
        "day12",
        "day13",
    };

    // Erstellt einen "run-all" Step
    const run_all = b.step("run-all", "Führt alle Programme aus");

    // Erstellt für jeden Tag ein ausführbares Programm
    for (days) |day| {
        const exe = b.addExecutable(.{
            .name = day,
            .root_source_file = .{ .path = b.fmt("{s}/{s}.zig", .{ day, day }) },
            .target = target,
            .optimize = optimize,
        });

        // Installation des Programms
        b.installArtifact(exe);

        // Erstellt einen Run-Command für dieses Programm
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        // Fügt einen speziellen Run-Step für jeden Tag hinzu
        const run_step = b.step(
            b.fmt("run-{s}", .{day}),
            b.fmt("Führt das Programm für {s} aus", .{day}),
        );
        run_step.dependOn(&run_cmd.step);

        // Fügt diesen Run-Step zum run-all Step hinzu
        run_all.dependOn(run_step);
    }
} 