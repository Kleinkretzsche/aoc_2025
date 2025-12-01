const std = @import("std");

fn part1(directions: std.ArrayList(bool), ammounts: std.ArrayList(i64)) u64 {
    var zeros: u64 = 0;
    var position: i64 = 50;
    for (directions.items, ammounts.items) |dir, ammount| {
        if (dir) {
            position += ammount;
        } else {
            position -= ammount;
        }
        if (@rem(position, 100) == 0) {
            zeros += 1;
        }
    }
    return zeros;
}

fn part2(directions: std.ArrayList(bool), ammounts: std.ArrayList(i64)) u64 {
    var zeros: u64 = 0;
    var position: i64 = 50;
    for (directions.items, ammounts.items) |dir, ammount| {
        if (!dir) {
            position = 100 - position;
        }
        zeros += @abs(@divTrunc(position + ammount, 100));
        position += ammount;
        position = @rem(position, 100);
    }
    return zeros;
}

pub fn main() !void {
    const io = std.testing.io;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.Io.Dir.cwd().openFile(io, "input/day01.txt", .{});
    defer file.close(io);

    var reader_buf: [1024]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    var directions: std.ArrayList(bool) = try .initCapacity(allocator, 64);
    defer directions.clearAndFree(allocator);

    var ammounts: std.ArrayList(i64) = try .initCapacity(allocator, 64);
    defer ammounts.clearAndFree(allocator);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        try directions.append(allocator, line[0] == 'R');
        try ammounts.append(allocator, try std.fmt.parseInt(i64, line[1..], 10));
    }
    std.debug.print("{}\n", .{part1(directions, ammounts)});
    std.debug.print("{}\n", .{part2(directions, ammounts)});
}
