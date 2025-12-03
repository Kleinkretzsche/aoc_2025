const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const inp_len = 100;
// const inp_len = 15;

pub fn run(allocator: Allocator, reader: *std.Io.File.Reader) !void {
    var input = try readInput(allocator, reader);
    defer input.deinit(allocator);

    std.debug.print("part 1: {}\n", .{part1(input)});
    std.debug.print("part 2: {}\n", .{part2(input)});
}

fn readInput(allocator: Allocator, reader: *std.Io.File.Reader) !std.ArrayList([inp_len]u8) {
    var res: std.ArrayList([inp_len]u8) = try .initCapacity(allocator, 10);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;

        var buf: [inp_len]u8 = undefined;
        @memset(buf[0..], 0);

        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            buf[i] = line[i];
        }

        try res.append(allocator, buf);
    }
    return res;
}

fn part1(packs: std.ArrayList([inp_len]u8)) u64 {
    var acc: u64 = 0;
    for (packs.items) |pack| {
        var first: usize = 0;
        for (1..pack.len) |i| {
            if (pack[i] > pack[first]) {
                first = i;
            }
        }
        var second: usize = 0;
        if (first == pack.len - 1) {
            for (0..pack.len - 1) |i| {
                if (pack[i] > pack[second]) {
                    second = i;
                }
            }
        } else {
            second = first + 1;
            for (second..pack.len) |i| {
                if (pack[i] > pack[second]) {
                    second = i;
                }
            }
        }

        if (first < second) {
            // std.debug.print("{s} {c} {s} {c} {s}\n", .{ pack[0..first], pack[first], pack[first + 1 .. second], pack[second], pack[second + 1 ..] });
            acc += 10 * (pack[first] - '0') + pack[second] - '0';
        } else if (first > second) {
            // std.debug.print("{s} {c} {s} {c} {s}\n", .{ pack[0..second], pack[second], pack[second + 1 .. first], pack[first], pack[first + 1 ..] });
            acc += 10 * (pack[second] - '0') + pack[first] - '0';
        } else {
            unreachable;
        }
    }
    return acc;
}

fn part2(packs: std.ArrayList([inp_len]u8)) u64 {
    _ = packs;
    return 0;
}
