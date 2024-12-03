const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input03.txt");
    var sum_task1: i32 = 0; // Summe für die erste Aufgabe (alle gültigen mul-Anweisungen)
    var sum_task2: i32 = 0; // Summe für die zweite Aufgabe (aktivierte mul-Anweisungen)
    var mul_enabled = true; // Für die zweite Aufgabe, gibt an, ob mul-Anweisungen aktiviert sind

    var i: usize = 0;
    while (i < input.len) {
        if (i <= input.len - 4 and std.mem.eql(u8, input[i .. i + 4], "mul(")) {
            var j = i + 4;

            // Erste Zahl parsen (1-3 Ziffern)
            const num1_start = j;
            while (j < input.len and input[j] >= '0' and input[j] <= '9' and j - num1_start < 3) {
                j += 1;
            }
            if (j == num1_start or j - num1_start > 3) {
                i += 1;
                continue;
            }
            const num1_slice = input[num1_start .. j];
            const num1 = try parseInt(num1_slice);

            // Überprüfen auf das Komma
            if (j >= input.len or input[j] != ',') {
                i += 1;
                continue;
            }
            j += 1;

            // Zweite Zahl parsen (1-3 Ziffern)
            const num2_start = j;
            while (j < input.len and input[j] >= '0' and input[j] <= '9' and j - num2_start < 3) {
                j += 1;
            }
            if (j == num2_start or j - num2_start > 3) {
                i += 1;
                continue;
            }
            const num2_slice = input[num2_start .. j];
            const num2 = try parseInt(num2_slice);

            // Überprüfen auf die schließende Klammer ')'
            if (j >= input.len or input[j] != ')') {
                i += 1;
                continue;
            }
            j += 1;

            // Gültige mul-Anweisung gefunden
            // Zur Summe der ersten Aufgabe hinzufügen
            sum_task1 += num1 * num2;

            // Für die zweite Aufgabe nur hinzufügen, wenn mul aktiviert ist
            if (mul_enabled) {
                sum_task2 += num1 * num2;
            }

            // Fortfahren ab dem Ende der aktuellen Anweisung
            i = j;
        } else if (i <= input.len - 3 and std.mem.eql(u8, input[i .. i + 3], "do(")) {
            // do()-Anweisung gefunden
            const j = i + 3;
            // Überprüfen auf die schließende Klammer ')'
            if (j < input.len and input[j] == ')') {
                mul_enabled = true;
                i = j + 1; // Fortfahren nach ')'
            } else {
                i += 1;
            }
        } else if (i <= input.len - 6 and std.mem.eql(u8, input[i .. i + 6], "don't(")) {
            // don't()-Anweisung gefunden
            const j = i + 6;
            // Überprüfen auf die schließende Klammer ')'
            if (j < input.len and input[j] == ')') {
                mul_enabled = false;
                i = j + 1; // Fortfahren nach ')'
            } else {
                i += 1;
            }
        } else {
            i += 1;
        }
    }

    std.debug.print("Ergebnis der ersten Aufgabe (alle gültigen mul-Anweisungen): {}\n", .{sum_task1});
    std.debug.print("Ergebnis der zweiten Aufgabe (aktivierte mul-Anweisungen): {}\n", .{sum_task2});
}

fn parseInt(slice: []const u8) !i32 {
    var result: i32 = 0;
    for (slice) |c| {
        result = result * 10 + (@as(i32, c) - '0');
    }
    return result;
}
