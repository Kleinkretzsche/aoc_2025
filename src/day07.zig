const std = @import("std");

pub fn get_2d_array(reader: *std.Io.Reader, allocator: std.mem.Allocator) ![][]u8 {
    const first_line = try reader.peekDelimiterExclusive('\n');
    const length = first_line.len;

    var lines: std.ArrayList([]u8) = try .initCapacity(allocator, 16);

    while (try reader.takeDelimiter('\n')) |line| {
        if (line.len <= 1) continue;
        const mem = try allocator.alloc(u8, length);
        @memcpy(mem, line);
        try lines.append(allocator, mem);
    }
    return lines.items;
}

pub fn part2(buf: []u64, chars: [][]u8) u64 {
    @memset(buf, 0);
    var start: usize = std.math.maxInt(usize);
    if (std.mem.findScalar(u8, chars[0], 'S')) |idx| {
        std.debug.print("{s}: s_idx: {}\n", .{ chars[0], idx });
        start = idx;
    }
    buf[start] = 1;
    for (1..chars.len - 1) |row| {
        for (1..chars.len - 1) |col| {
            if (buf[col] > 0) {
                if (chars[row][col] == '^') {
                    buf[col - 1] += buf[col];
                    buf[col + 1] += buf[col];
                    buf[col] = 0;
                }
            }
        }
    }

    var acc: u64 = 0;
    for (buf) |count| {
        acc += count;
    }
    return acc;
}

pub fn part1(chars: [][]u8) u32 {
    var saved_idx: usize = undefined;
    for (0..chars[0].len) |i| {
        if (chars[0][i] == 'S') {
            chars[0][i] = '|';
            saved_idx = i;
        }
    }

    var splits: u32 = 0;

    for (1..chars.len - 1) |row| {
        for (1..chars.len - 1) |col| {
            if (chars[0][col] == '|') {
                if (chars[row][col] == '^') {
                    chars[0][col - 1] = '|';
                    chars[0][col] = '.';
                    chars[0][col + 1] = '|';
                    splits += 1;
                } else {
                    chars[row][col] = '|';
                }
            }
        }
    }

    @memset(chars[0], '.');
    chars[0][saved_idx] = 'S';
    return splits;
}

pub fn main() !void {
    const io = std.testing.io;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const file = try std.Io.Dir.cwd().openFile(
        io,
        if (argv.len < 2) "input/day07.txt" else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [1024]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    var arena_heap: std.heap.ArenaAllocator = .init(allocator);
    defer arena_heap.deinit();

    const arena = arena_heap.allocator();

    const char_matrix = try get_2d_array(&reader.interface, arena);
    const buf = try allocator.alloc(u64, char_matrix[0].len);
    defer allocator.free(buf);

    std.debug.print("part 1: {}\n", .{part1(char_matrix)});
    std.debug.print("part 2: {}\n", .{part2(buf, char_matrix)});
}
