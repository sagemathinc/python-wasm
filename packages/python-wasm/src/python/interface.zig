const std = @import("std");
const python = @import("./python.zig");
const interface = @import("../interface.zig");

export fn init() void {
    python.init();
}

export fn exec(s: [*:0]const u8) void {
    python.exec(s) catch |err| {
        //todo
        std.debug.print("python error: '{}'\nwhen evaluating '{s}'", .{ err, s });
        return;
    };
}

export fn terminal(argc: i32, argv: [*c][*c]u8) void {
    python.terminal(argc, argv);
}

// this is not useful in any way, etc.
extern fn run_interactive_one() i32;
export fn pyrun_interactive_one() i32 {
    return run_interactive_one();
}

extern fn wasmSendString(ptr: [*]const u8, len: usize) void;

export fn eval(s: [*:0]const u8) void {
    const r = python.eval(interface.allocator(), s) catch |err| {
        //todo
        std.debug.print("python error: '{}'\nwhen evaluating '{s}'", .{ err, s });
        return;
    };
    defer interface.allocator().free(r);
    // Todo: this r[0..1] is a casting hack -- I think it's harmless
    // because r itself is null terminated (?).
    const ptr: [*]const u8 = r[0..1];
    wasmSendString(ptr, std.mem.len(r));
}

// export fn toJSON(s: [*:0]const u8) void {
//     const r = python.toJSON(interface.allocator(), s) catch |err| {
//         //todo
//         std.debug.print("python error: '{}'\nwhen exporting '{s}' to JSON", .{ err, s });
//         return;
//     };
//     defer interface.allocator().free(r);
//     const ptr: [*]const u8 = r[0..1];
//     wasmSendString(ptr, std.mem.len(r));
// }

export fn c_malloc(n: usize) ?*anyopaque {
    return std.c.malloc(n);
}

export fn c_free(ptr: ?*anyopaque) void {
    return std.c.free(ptr);
}
