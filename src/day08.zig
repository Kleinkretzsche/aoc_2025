const std = @import("std");

const Vec3 = struct {
    xyz: [3]isize,

    fn from_string(str: []u8) !Vec3 {
        var vec: Vec3 = undefined;
        var i: usize = 0;
        var it = std.mem.tokenizeScalar(u8, str, ',');
        while (it.next()) |num| {
            vec.xyz[i] = try std.fmt.parseInt(isize, num, 10);
            i += 1;
        }
        return vec;
    }

    fn distance(self: Vec3, other: Vec3) f64 {
        var acc: f64 = 0;

        if (std.mem.eql(isize, &self.xyz, &other.xyz)) return 0;

        for (self.xyz, other.xyz) |s, o| {
            const d: f64 = @floatFromInt((s - o));
            acc += d * d;
        }
        return std.math.sqrt(acc);
    }
};

const PairDistance = struct {
    idxs: [2]usize,
    distance: f64,

    fn make(vecs: []Vec3, i: usize, j: usize) PairDistance {
        return .{
            .idxs = .{ i, j },
            .distance = vecs[i].distance(vecs[j]),
        };
    }

    fn lt(_: void, a: PairDistance, b: PairDistance) bool {
        return a.distance < b.distance;
    }
};

const UnionFind = struct {
    parent: []usize,
    size: []usize,

    fn init(allocator: std.mem.Allocator, size: usize) !UnionFind {
        var uf: UnionFind = .{
            .parent = try allocator.alloc(usize, size),
            .size = try allocator.alloc(usize, size),
        };
        @memset(uf.size, 1);
        for (0..size) |i| {
            uf.parent[i] = i;
        }
        return uf;
    }

    fn deinit(self: *UnionFind, allocator: std.mem.Allocator) void {
        allocator.free(self.parent);
        allocator.free(self.size);
    }

    fn find(self: *UnionFind, i: usize) usize {
        if (self.parent[i] != i)
            self.parent[i] = self.find(self.parent[i]);
        return self.parent[i];
    }

    fn unite(self: *UnionFind, i: usize, j: usize) bool {
        const ri = self.find(i);
        const rj = self.find(j);
        if (ri == rj) return false;

        if (self.size[ri] < self.size[rj]) {
            self.parent[ri] = rj;
            self.size[rj] += self.size[ri];
            self.size[ri] = 0;
        } else {
            self.parent[rj] = ri;
            self.size[ri] += self.size[rj];
            self.size[rj] = 0;
        }

        return true;
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

fn part1(arena: std.mem.Allocator, junctions: []Vec3) !u64 {
    const length = junctions.len;

    var pairs = try arena.alloc(PairDistance, length * length);

    for (0..length) |i| {
        for (0..length) |j| {
            pairs[i * length + j] = PairDistance.make(junctions, i, j);
        }
    }

    std.mem.sort(PairDistance, pairs, {}, PairDistance.lt);

    var uf: UnionFind = try .init(arena, length);

    var connections_left: u64 = 10;

    for (pairs) |pair| {
        if (pair.distance == 0) continue;
        if (connections_left == 1) break;
        if (uf.unite(pair.idxs[0], pair.idxs[1])) {
            std.debug.print("{} united with {}, cost={}\n", .{ junctions[pair.idxs[0]], junctions[pair.idxs[1]], pair.distance });
            connections_left -= 1;
        }
    }

    const size_copy = try arena.dupe(usize, uf.size);

    std.mem.sort(usize, size_copy, {}, comptime std.sort.desc(usize));

    var acc: u64 = 1;

    for (size_copy[0..3]) |size| {
        acc *= size;
    }

    return acc;
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

    var junction_list: std.ArrayList(Vec3) = try .initCapacity(allocator, 10);
    defer junction_list.deinit(allocator);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        try junction_list.append(allocator, try Vec3.from_string(line));
    }

    const junctions = junction_list.items;

    var arena_alloc: std.heap.ArenaAllocator = .init(allocator);
    defer arena_alloc.deinit();
    const arena = arena_alloc.allocator();

    std.debug.print("part1: {}\n", .{try part1(arena, junctions)});
}
