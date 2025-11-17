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

pub fn RingBufferQueue(comptime capacity: usize) type {
    return struct {
        data: [capacity + 1]i32 = [_]i32{0} ** (capacity + 1),
        front: usize = 0,
        back: usize = 0,

        const Self = @This();

        pub fn enqueue(self: *Self, value: i32) !void {
            const next_back = (self.back + 1) % (capacity + 1);
            if (next_back == self.front) {
                return error.QueueFull;
            }
            self.data[self.back] = value;
            self.back = next_back;
        }

        pub fn dequeue(self: *Self) !i32 {
            if (self.front == self.back) {
                return error.QueueEmpty;
            }
            const value = self.data[self.front];
            self.front = (self.front + 1) % (capacity + 1);
            return value;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.front == self.back;
        }

        pub fn isFull(self: *const Self) bool {
            return (self.back + 1) % (capacity + 1) == self.front;
        }
    };
}

test "RingBufferQueue - basic enqueue and dequeue" {
    var q = RingBufferQueue(3){};

    try q.enqueue(10);
    try std.testing.expectEqual(@as(i32, 10), try q.dequeue());
}

test "RingBufferQueue - isEmpty returns true when empty" {
    var q = RingBufferQueue(3){};
    try std.testing.expect(q.isEmpty());
}

test "RingBufferQueue - isEmpty returns false when not empty" {
    var q = RingBufferQueue(3){};
    try q.enqueue(5);
    try std.testing.expect(!q.isEmpty());
}

test "RingBufferQueue - isFull returns false when not full" {
    var q = RingBufferQueue(3){};
    try q.enqueue(1);
    try std.testing.expect(!q.isFull());
}

test "RingBufferQueue - isFull returns true when full" {
    var q = RingBufferQueue(3){};
    try q.enqueue(1);
    try q.enqueue(2);
    try q.enqueue(3);
    try std.testing.expect(q.isFull());
}

test "RingBufferQueue - error on enqueue when full" {
    var q = RingBufferQueue(2){};
    try q.enqueue(1);
    try q.enqueue(2);

    try std.testing.expectError(error.QueueFull, q.enqueue(3));
}

test "RingBufferQueue - error on dequeue when empty" {
    var q = RingBufferQueue(3){};
    try std.testing.expectError(error.QueueEmpty, q.dequeue());
}

test "RingBufferQueue - multiple enqueue and dequeue" {
    var q = RingBufferQueue(4){};

    try q.enqueue(10);
    try q.enqueue(20);
    try q.enqueue(30);

    try std.testing.expectEqual(@as(i32, 10), try q.dequeue());
    try std.testing.expectEqual(@as(i32, 20), try q.dequeue());
    try std.testing.expectEqual(@as(i32, 30), try q.dequeue());
}

test "RingBufferQueue - wrap around behavior" {
    var q = RingBufferQueue(3){};

    // Fill the queue
    try q.enqueue(1);
    try q.enqueue(2);
    try q.enqueue(3);

    // Remove some elements
    try std.testing.expectEqual(@as(i32, 1), try q.dequeue());
    try std.testing.expectEqual(@as(i32, 2), try q.dequeue());

    // Add more elements (should wrap around)
    try q.enqueue(4);
    try q.enqueue(5);

    // Verify order
    try std.testing.expectEqual(@as(i32, 3), try q.dequeue());
    try std.testing.expectEqual(@as(i32, 4), try q.dequeue());
    try std.testing.expectEqual(@as(i32, 5), try q.dequeue());
}

test "RingBufferQueue - fill to capacity then empty" {
    var q = RingBufferQueue(5){};

    // Fill to capacity
    try q.enqueue(1);
    try q.enqueue(2);
    try q.enqueue(3);
    try q.enqueue(4);
    try q.enqueue(5);

    try std.testing.expect(q.isFull());

    // Empty the queue
    _ = try q.dequeue();
    _ = try q.dequeue();
    _ = try q.dequeue();
    _ = try q.dequeue();
    _ = try q.dequeue();

    try std.testing.expect(q.isEmpty());
}

test "RingBufferQueue - multiple wrap cycles" {
    var q = RingBufferQueue(2){};

    for (0..10) |i| {
        try q.enqueue(@intCast(i));
        try std.testing.expectEqual(@as(i32, @intCast(i)), try q.dequeue());
    }

    try std.testing.expect(q.isEmpty());
}

test "RingBufferQueue - alternating enqueue and dequeue" {
    var q = RingBufferQueue(3){};

    try q.enqueue(1);
    try std.testing.expectEqual(@as(i32, 1), try q.dequeue());

    try q.enqueue(2);
    try q.enqueue(3);
    try std.testing.expectEqual(@as(i32, 2), try q.dequeue());

    try q.enqueue(4);
    try std.testing.expectEqual(@as(i32, 3), try q.dequeue());
    try std.testing.expectEqual(@as(i32, 4), try q.dequeue());

    try std.testing.expect(q.isEmpty());
}
