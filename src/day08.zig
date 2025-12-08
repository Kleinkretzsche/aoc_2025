const std = @import("std");

const Vec3 = struct {
    xyz: [3]u32,

    fn from_string(str: []u8) !Vec3 {
        var vec: Vec3 = undefined;
        var i: usize = 0;
        var it = std.mem.tokenizeScalar(u8, str, ',');
        while (it.next()) |num| {
            vec.xyz[i] = try std.fmt.parseInt(u32, num, 10);
            i += 1;
        }
        return vec;
    }

    fn distance(self: Vec3, other: Vec3) f32 {
        var acc: f32 = undefined;
        for (self.xyz, other.xyz) |s, o| {
            acc += (s - o) * (s - o);
        }
        return std.math.sqrt(acc);
    }
};

const UnionFind = struct {
    parent: []usize,

    fn init(buf: []usize, size: usize) !UnionFind {
        if (buf.len < size) return error.bufferTooSmall;
        var uf: UnionFind = .{ .parent = buf[0..size] };
        for (0..size) |i| {
            uf.parent[i] = i;
        }
        return uf;
    }

    fn find(self: UnionFind, i: usize) usize {
        if (self.parent[i] == i) return i;
        return find(self.parent[i]);
    }

    fn unite(self: *UnionFind, i: usize, j: usize) void {
        const irep = self.find(i);
        const jrep = self.find(j);
        self.parent[irep] = jrep;
    }

    fn is_disjoint(self: UnionFind, i: usize, j: usize) bool {
        const irep = self.find(i);
        const jrep = self.find(j);
        return irep != jrep;
    }

    fn is_atom(self: UnionFind, i: usize) bool {
        return self.find(i) == i;
    }
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
        if (argv.len < 2) "input/day08.txt" else argv[1],
        .{},
    );
    defer file.close(io);

    var reader_buf: [1024]u8 = undefined;
    var reader = file.reader(io, &reader_buf);

    var junctions: std.ArrayList(Vec3) = try .initCapacity(allocator, 10);
    defer junctions.deinit(allocator);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        try junctions.append(allocator, try Vec3.from_string(line));
    }

    var buf: [1024]usize = undefined;
    var uf: UnionFind = try .init(&buf, 100);
}
