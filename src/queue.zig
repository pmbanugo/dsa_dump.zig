const std = @import("std");

fn Queue(comptime capacity: usize) type {
    return struct {
        data: [capacity]i32 = [_]i32{0} ** capacity,
        front: usize = 0,
        back: usize = 0,

        const Self = @This();

        pub fn enqueue(self: *Self, value: i32) !void {
            if (self.back >= self.data.len) {
                return error.QueueFull;
            }
            self.data[self.back] = value;
            self.back += 1;
        }

        pub fn dequeue(self: *Self) !i32 {
            if (self.front >= self.back) {
                return error.QueueEmpty;
            }
            const value = self.data[self.front];
            self.front += 1;
            return value;
        }
    };
}

test "simple queue test" {
    var queue = Queue(4){};
    try queue.enqueue(42);
    try std.testing.expectEqual(@as(i32, 42), try queue.dequeue());
}

test "enqueue and dequeue multiple items" {
    var queue = Queue(4){};
    try queue.enqueue(10);
    try queue.enqueue(20);
    try queue.enqueue(30);

    try std.testing.expectEqual(@as(i32, 10), try queue.dequeue());
    try std.testing.expectEqual(@as(i32, 20), try queue.dequeue());
    try std.testing.expectEqual(@as(i32, 30), try queue.dequeue());
}
