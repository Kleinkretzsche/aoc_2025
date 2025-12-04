const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

// const dim = 10;
const dim = 137;

pub fn main() !void {
    const io = std.testing.io;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const file = try std.Io.Dir.cwd().openFile(
        io,
        if (argv.len < 2) "input/day04.txt" else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [1024]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    var input = try allocator.alloc([dim]u8, dim);
    var i: usize = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        @memcpy(&input[i], line);
        i += 1;
    }

    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{part1(input)});
    std.debug.print("part 2: {}\n", .{part2(input)});
}

fn printBoxes(boxes: [][dim]u8) void {
    var buf: [(dim + 1) * dim]u8 = @splat(0);
    for (0..dim) |i| {
        for (0..dim) |j| {
            buf[(i + 1) * dim + j] = boxes[i][j];
        }
        buf[(i + 1) * dim] = '\n';
    }
    std.debug.print("{s}\n", .{buf});
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
    var changes: [dim][dim]bool = @splat(@splat(false));
    var changed: u64 = 1;
    var counter: u64 = 0;
    while (changed != 0) {
        // std.debug.print("\x1b[2J\x1b[H", .{});
        // printBoxes(boxes);
        for (0..dim) |i| {
            for (0..dim) |j| {
                if (changes[i][j]) {
                    boxes[i][j] = '.';
                }
            }
        }
        for (0..dim) |i| {
            @memset(&changes[i], false);
        }
        changed = 0;
        for (0..dim) |i| {
            for (0..dim) |j| {
                const n = count_neighbors(boxes, i, j);
                if (n < 4) {
                    changed += 1;
                    changes[i][j] = true;
                } else {}
            }
        }
        counter += changed;
    }
    return counter;
}
