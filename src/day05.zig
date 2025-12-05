const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,
};

pub fn main() !void {
    const io = std.testing.io;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const file = try std.Io.Dir.cwd().openFile(
        io,
        if (argv.len < 2) "input/day05.txt" else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [4098]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    var input: std.ArrayList(Range) = try .initCapacity(allocator, 100);
    defer input.deinit(allocator);

    var min: u64 = std.math.maxInt(u64);
    var max: u64 = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) break;
        const idx = std.mem.findScalar(u8, line, '-');
        var r: Range = .{ .start = 0, .end = 0 };
        if (idx) |i| {
            r.start = try std.fmt.parseInt(u64, line[0..i], 10);
            r.end = try std.fmt.parseInt(u64, line[i + 1 ..], 10);
            min = @min(min, r.start);
            max = @max(max, r.end);
        } else {
            continue;
        }
        try input.append(allocator, r);
    }

    var valid1: u64 = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        const id = try std.fmt.parseInt(u64, line, 10);
        for (input.items) |range| {
            if (id >= range.start and id <= range.end) {
                valid1 += 1;
                break;
            }
        }
    }

    var valid2: u64 = 0;
    var id: usize = min;
    var skipped: bool = undefined;
    while (id <= max) {
        skipped = false;
        for (input.items) |range| {
            if (id >= range.start and id <= range.end) {
                const to_rest = range.end - id + 1;
                // std.debug.print("{} in [{}..{}] skipping to end and adding {} id(s)\n", .{
                //     id,
                //     range.start,
                //     range.end,
                //     to_rest,
                // });
                id = range.end + 1;
                valid2 += to_rest;
                skipped = true;
                break;
            }
        }
        if (!skipped) {
            var min_gt_id: usize = std.math.maxInt(usize);
            for (input.items) |range| {
                if (id < range.start) {
                    min_gt_id = @min(min_gt_id, range.start);
                }
            }
            id = min_gt_id;
        }
    }
    std.debug.print("part 1: {}\n", .{valid1});
    std.debug.print("part 1: {}\n", .{valid2});
}
