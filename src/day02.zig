const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

pub fn run(allocator: Allocator, reader: *std.Io.File.Reader) !void {
    var input = try readInput(allocator, reader);
    defer input.deinit(allocator);

    std.debug.print("part 1: {}\n", .{part1(input)});
    std.debug.print("part 2: {}\n", .{part2(input)});
}

const Range = struct { start: u64, end: u64 };

fn readInput(allocator: Allocator, reader: *std.Io.File.Reader) !std.ArrayList(Range) {
    var ranges: std.ArrayList(Range) = try .initCapacity(allocator, 10);
    while (try reader.interface.takeDelimiter(',')) |line| {
        if (line.len == 0) continue;

        var range: Range = .{ .start = 0, .end = 0 };
        var sep_i: u64 = 0;

        while (sep_i < line.len) : (sep_i += 1) {
            if (line[sep_i] == '-') {
                break;
            }
        }

        if (sep_i == line.len - 1) return error.NoSeperator;

        range.start = try std.fmt.parseInt(u64, line[0..sep_i], 10);

        const end = if (line[line.len - 1] == '\n') line.len - 1 else line.len;
        range.end = try std.fmt.parseInt(u64, line[sep_i + 1 .. end], 10);

        try ranges.append(allocator, range);
    }
    return ranges;
}

fn invalid1(id: u64) bool {
    const num_digits = (math.log(u64, 10, id)) + 1;

    if (num_digits % 2 == 1) {
        return false;
    }

    const upper = @divFloor(id, math.pow(u64, 10, num_digits / 2));
    const lower = @mod(id, math.pow(u64, 10, num_digits / 2));

    return upper == lower;
}

fn invalid2(id: u64) bool {
    var buf: [128]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buf);

    writer.print("{d}", .{id}) catch {
        return false;
    };

    const len: u64 = math.log(u64, 10, id) + 1;
    const str = buf[0 .. len + 1];

    for (2..len + 1) |num_chunks| {
        if (len % num_chunks != 0) {
            continue;
        }

        const chunksize = len / num_chunks;
        var flag = true;

        for (0..chunksize) |chunk_index| {
            if (!flag) break;
            for (1..num_chunks) |j| {
                flag &= str[chunk_index] == str[chunk_index + j * chunksize];
            }
        }

        if (flag) return true;
    }
    return false;
}

fn part1(ranges: std.ArrayList(Range)) u64 {
    var acc: u64 = 0;
    for (ranges.items) |range| {
        for (range.start..range.end + 1) |i| {
            if (invalid1(i)) acc += i;
        }
    }
    return acc;
}

fn part2(ranges: std.ArrayList(Range)) u64 {
    var acc: u64 = 0;
    for (ranges.items) |range| {
        for (range.start..range.end + 1) |i| {
            if (invalid2(i)) {
                acc += i;
            }
        }
    }
    return acc;
}
