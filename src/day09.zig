const std = @import("std");

fn calc_sides(c1: [2]i64, c2: [2]i64) [2]u64 {
    return .{ @abs(c1[0] - c2[0]) + 1, @abs(c1[1] - c2[1]) + 1 };
}

fn calc_area(c1: [2]i64, c2: [2]i64) u64 {
    const sides = calc_sides(c1, c2);
    return sides[0] * sides[1];
}

fn part1(tiles: [][2]i64) u64 {
    var max: u64 = 0;
    for (0..tiles.len) |i| {
        for (i..tiles.len) |j| {
            max = @max(calc_area(tiles[i], tiles[j]), max);
        }
    }
    return max;
}

fn inside_rect(rect: [2][2]i64, point: [2]i64) bool {
    const min_x = @min(rect[0][0], rect[1][0]);
    const max_x = @max(rect[0][0], rect[1][0]);
    const min_y = @min(rect[0][1], rect[1][1]);
    const max_y = @max(rect[0][1], rect[1][1]);
    return point[0] > min_x and point[0] < max_x and point[1] > min_y and point[1] < max_y;
}

fn part2(tiles: [][2]i64) u64 {
    var max: u64 = 0;
    for (0..tiles.len) |i| {
        for (i..tiles.len) |j| blk: {
            for (0..tiles.len) |k| {
                if (inside_rect(.{ tiles[i], tiles[j] }, tiles[k])) {
                    break :blk;
                }
            }
            max = @max(calc_area(tiles[i], tiles[j]), max);
        }
    }
    return max;
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
        if (argv.len < 2) "input/day08.txt" else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [1024]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    var tile_list: std.ArrayList([2]i64) = try .initCapacity(allocator, 10);
    defer tile_list.deinit(allocator);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        var it = std.mem.tokenizeScalar(u8, line, ',');
        try tile_list.append(allocator, .{
            try std.fmt.parseInt(i64, it.next().?, 10),
            try std.fmt.parseInt(i64, it.next().?, 10),
        });
    }
    std.debug.print("part1: {}\n", .{part1(tile_list.items)});
    std.debug.print("part2: {}\n", .{part2(tile_list.items)});
}
