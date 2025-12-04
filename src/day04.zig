const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const dim = 137;

pub fn run(allocator: Allocator, reader: *std.Io.File.Reader) !void {
    const input = try readInput(allocator, reader);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{part1(input)});
    std.debug.print("part 2: {}\n", .{part2(input)});
}

fn readInput(allocator: Allocator, reader: *std.Io.File.Reader) ![][dim]u8 {
    var res = try allocator.alloc([dim]u8, dim);
    var i: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        @memcpy(&res[i], line);
        i += 1;
    }
    return res;
}

fn lookup(boxes: [][dim]u8, row: usize, col: usize) bool {
    return col < dim and row < dim and boxes[row][col] == '@';
}

fn count_neighbors(boxes: [][dim]u8, row: usize, col: usize) u8 {
    const start_row: usize = if (row == 0) 1 else 0;
    const start_col: usize = if (col == 0) 1 else 0;

    var count: u8 = 0;
    for (start_row..3) |i| {
        for (start_col..3) |j| {
            if (lookup(boxes, row + i - 1, col + j - 1)) {
                count += 1;
            }
        }
    }
    if (lookup(boxes, row, col)) {
        return count - 1;
    } else {
        return 9;
    }
}

fn part1(boxes: [][dim]u8) u64 {
    var acc: u64 = 0;
    for (0..dim) |i| {
        for (0..dim) |j| {
            const n = count_neighbors(boxes, i, j);
            if (n < 4) {
                acc += 1;
            } else {}
        }
    }
    return acc;
}

fn part2(boxes: [][dim]u8) u64 {
    _ = boxes;
    return 0;
}
