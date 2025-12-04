const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const inp_len = 100;
// const inp_len = 15;

const pack_len = 12;

const default_path = "input/day03.txt";

pub fn main() !void {
    const io = std.testing.io;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const file = try std.Io.Dir.cwd().openFile(
        io,
        if (argv.len < 2) default_path else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [1024]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    var input: std.ArrayList([inp_len]u8) = try .initCapacity(allocator, inp_len);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        var buf: [inp_len]u8 = undefined;
        @memset(buf[0..], 0);
        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            buf[i] = line[i];
        }
        try input.append(allocator, buf);
    }

    defer input.deinit(allocator);

    std.debug.print("part 1: {}\n", .{part1(input)});
    std.debug.print("part 2: {}\n", .{part2(input)});
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
            acc += 10 * (pack[first] - '0') + pack[second] - '0';
        } else if (first > second) {
            acc += 10 * (pack[second] - '0') + pack[first] - '0';
        } else {
            unreachable;
        }
    }
    return acc;
}

fn max_pack_value(numbers: [inp_len]u8) u64 {
    var max_pack = [_]u8{0} ** pack_len;
    var prev_max_index: usize = 0;
    var current_max_index: usize = 0;
    for (0..pack_len) |pack_index| {
        for ((prev_max_index + 1)..(numbers.len - (pack_len - pack_index - 1))) |i| {
            if (numbers[current_max_index] < numbers[i]) {
                current_max_index = i;
            }
        }
        max_pack[pack_index] = numbers[current_max_index];
        prev_max_index = current_max_index;
        current_max_index += 1;
    }
    return std.fmt.parseInt(u64, &max_pack, 10) catch 0;
}

fn part2(packs: std.ArrayList([inp_len]u8)) u64 {
    var acc: u64 = 0;
    for (packs.items) |pack| {
        acc += max_pack_value(pack);
    }
    return acc;
}
