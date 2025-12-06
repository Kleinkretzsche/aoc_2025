const std = @import("std");

fn part1(allocator: std.mem.Allocator, reader: *std.Io.Reader) !u64 {
    const buf = try reader.allocRemaining(allocator, std.Io.Limit.unlimited);
    defer allocator.free(buf);
    var ops_list: std.ArrayList(bool) = .empty;
    defer ops_list.deinit(allocator);

    var res_list: std.ArrayList(u64) = .empty;
    defer res_list.deinit(allocator);

    var it = std.mem.splitBackwardsScalar(u8, buf, '\n');
    while (it.next()) |last_line| {
        if (last_line.len <= 1) continue;
        var line_it = std.mem.splitScalar(u8, last_line, ' ');
        while (line_it.next()) |op| {
            if (op.len != 1) continue;
            const is_mul = op[0] == '*';
            try ops_list.append(allocator, is_mul);
            try res_list.append(allocator, if (is_mul) 1 else 0);
        }
        break;
    }

    const mul = ops_list.items;
    const res = res_list.items;

    while (it.next()) |line| {
        var line_it = std.mem.splitScalar(u8, line, ' ');
        var i: usize = 0;
        while (line_it.next()) |num| {
            if (num.len == 0) continue;
            if (mul[i]) {
                res[i] *= try std.fmt.parseInt(u64, num, 10);
            } else {
                res[i] += try std.fmt.parseInt(u64, num, 10);
            }
            i += 1;
        }
    }

    var acc: usize = 0;
    for (res) |n| {
        acc += n;
    }
    return acc;
}

fn calc_line(lines: [][]u8, idx: usize) u64 {
    var acc: u64 = 0;
    var power: u64 = 0;
    for (1..lines.len) |i| {
        acc += switch (lines[i][idx]) {
            '0'...'9' => (lines[i][idx] - '0') * (std.math.pow(u64, 10, power)),
            else => 0,
        };
        power += 1;
    }
    while (acc % 10 == 0) {
        acc /= 10;
    }
    return acc;
}

fn calc_problem(lines: [][]u8, idx: *usize) u64 {
    const mul: bool = lines[0][idx.*] == '*';
    var acc: u64 = if (mul) 1 else 0;
    while (true) {
        if (lines[0][idx.*] == '\n') break;
        if (idx.* + 1 < lines[0].len) {
            switch (lines[0][idx.* + 1]) {
                '*', '+' => break,
                else => {},
            }
        }

        const val = calc_line(lines, idx.*);
        if (mul) {
            acc *= val;
        } else {
            acc += val;
        }
        idx.* += 1;
    }
    return acc;
}

fn part2(allocator: std.mem.Allocator, reader: *std.Io.Reader) !u64 {
    var arena_alloc: std.heap.ArenaAllocator = .init(allocator);
    defer arena_alloc.deinit();
    var arena = arena_alloc.allocator();

    const first_line = try reader.peekDelimiterInclusive('\n');
    const length: usize = first_line.len;

    var lines_list: std.ArrayList([]u8) = try .initCapacity(arena, 5);

    while (try reader.takeDelimiter('\n')) |line| {
        if (line.len <= 1) continue;
        const item = try arena.alloc(u8, length);
        @memcpy(item[0 .. item.len - 1], line);
        item[item.len - 1] = '\n';
        try lines_list.append(arena, item);
    }

    const lines: [][]u8 = lines_list.items;
    std.mem.reverse([]u8, lines);

    var acc: u64 = 0;
    var i: usize = 0;
    while (i < lines[0].len - 1) {
        acc += calc_problem(lines, &i);
        i += 1;
    }
    return acc;
}

pub fn main() !void {
    const io = std.testing.io;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var arena: std.heap.ArenaAllocator = .init(allocator);
    defer arena.deinit();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const file = try std.Io.Dir.cwd().openFile(
        io,
        if (argv.len < 2) "input/day06.txt" else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [4098]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    std.debug.print("part 1: {}\n", .{try part1(allocator, &reader.interface)});

    try reader.seekTo(0);

    std.debug.print("part 2: {}\n", .{try part2(allocator, &reader.interface)});
}
