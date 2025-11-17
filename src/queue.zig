const std = @import("std");

// A generic function to create a Queue type with a specific capacity.
fn Queue(comptime capacity: usize) type {
    return struct {
        // The array that will store our queue's elements.
        data: [capacity]i32 = [_]i32{0} ** capacity,
        // 'front' is the index of the next element to be dequeued.
        front: usize = 0,
        // 'back' is the index where the next element will be enqueued.
        back: usize = 0,
        // 'count' tracks the current number of elements in the queue.
        count: usize = 0,

        // A constant to refer to the struct itself. A common Zig pattern.
        const Self = @This();

        // Adds an item to the back of the queue.
        pub fn enqueue(self: *Self, value: i32) !void {
            if (self.count >= capacity) {
                return error.QueueFull;
            }
            self.data[self.back] = value;
            self.back += 1;
            self.count += 1;
        }

        // Removes an item from the front of the queue.
        pub fn dequeue(self: *Self) !i32 {
            if (self.count == 0) {
                return error.QueueEmpty;
            }
            const value = self.data[self.front];
            self.front += 1;
            self.count -= 1;
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
