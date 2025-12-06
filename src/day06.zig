const std = @import("std");

fn part1(allocator: std.mem.Allocator, buf: []const u8) u64 {
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

fn part2(allocator: std.mem.Allocator, buf: []const u8) u64 {
    _ = allocator;
    _ = buf;
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

    const buf = try reader.interface.allocRemaining(allocator, std.Io.Limit.unlimited);
    defer allocator.free(buf);

    std.debug.print("part 1: {}\n", .{part1(allocator, buf)});
    std.debug.print("part 1: {}\n", .{part2(allocator, buf)});
}
