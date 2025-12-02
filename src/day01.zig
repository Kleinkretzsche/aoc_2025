const std = @import("std");
const Allocator = std.mem.Allocator;

const Input = struct {
    directions: std.ArrayList(bool),
    ammounts: std.ArrayList(i64),
};

pub fn run(allocator: Allocator, reader: *std.Io.File.Reader) !void {
    var input = try readInput(allocator, reader);
    var directions = input.directions;
    var ammounts = input.ammounts;

    defer directions.deinit(allocator);
    defer ammounts.deinit(allocator);

    std.debug.print("part 1: {}\n", .{part1(directions, ammounts)});
    std.debug.print("part 2: {}\n", .{part2(directions, ammounts)});
}

fn readInput(allocator: Allocator, reader: *std.Io.File.Reader) !Input {
    var directions: std.ArrayList(bool) = try .initCapacity(allocator, 64);
    var ammounts: std.ArrayList(i64) = try .initCapacity(allocator, 64);
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        try directions.append(allocator, line[0] == 'R');
        try ammounts.append(allocator, try std.fmt.parseInt(i64, line[1..], 10));
    }
    return (Input){ .directions = directions, .ammounts = ammounts };
}

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
        var i: i64 = 0;
        while (i < ammount) : (i += 1) {
            if (dir) {
                position += 1;
            } else {
                position -= 1;
            }
            if (@rem(position, 100) == 0) {
                zeros += 1;
            }
        }
    }
    return zeros;
}

// pub fn part2_fast(directions: std.ArrayList(bool), ammounts: std.ArrayList(i64)) u64 {
//     var zeros: u64 = 0;
//     var position: i64 = 50;
//     for (directions.items, ammounts.items) |dir, ammount| {
//         const fine_tuning = @rem(ammount, 100);
//         zeros += @abs(@divTrunc(ammount, 100));
//         if (dir) {} else {}
//     }
// }
