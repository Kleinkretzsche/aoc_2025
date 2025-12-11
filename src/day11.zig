const std = @import("std");

const Node = struct {
    name: [3]u8,
    refs: [][3]u8,
};

const NodeContext = struct {
    pub fn hash(_: NodeContext, o: [3]u8) u64 {
        return std.hash.Wyhash.hash(0, o);
    }
    pub fn eql(_: NodeContext, a: [3]u8, b: [3]u8) bool {
        return std.mem.eql(u8, a, b);
    }
};

const NodeStore = std.HashMapUnmanaged([3]u8, [][3]u8, {}, 80);

pub fn main() !void {
    const io = std.testing.io;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const file = try std.Io.Dir.cwd().openFile(
        io,
        if (argv.len < 2) "input/day11.txt" else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [1024]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        while (it.next()) |block| {}
    }
}
