const std = @import("std");

fn par1(directions: std.ArrayList(bool), ammounts: std.ArrayList(i64)) u64 {
    var zeros: u64 = 0;
    var position: i64 = 50;
    for (directions.itmes, ammounts.items) |dir, ammount| {
        if (dir) {
            position += ammount;
        } else {
            position -= ammount;
        }
        if (position % 100 == 0) {
            zeros += 1;
        }
    }
    return zeros;
}

pub fn main() !void {
    return error.ImplementParsing;
}
