const std = @import("std");

pub const Csv = struct {
  file: []const u8,
  arena: std.heap.ArenaAllocator,
  headers: [][]const u8 = &.{},
  rows: std.ArrayList(std.StringHashMap([]const u8)) = .empty,

  fn get_csv_line_str(
    self: *Csv,
    list: *std.ArrayList([]const u8),
    seperator: []const u8
  ) ![]const u8 {
    const allocator = self.arena_allocator();
    return try std.mem.join(allocator, seperator, list.items);
  }

  fn get_csv_lines_str(
    self: *Csv,
    list: *std.ArrayList([]const u8),
    seperator: []const u8
  ) ![]const u8 {
    const allocator = self.arena_allocator();
    var csv_list: std.ArrayList([]const u8) = .empty;
    for(list.items) |h|{
      var it = h.iterator();
      var l: std.ArrayList([]const u8) = .empty;
      while (it.next()) |e| {
        l.appendSlice(allocator, e.value_ptr.*);
      }
      const s = try self.get_csv_line_str(l, seperator);
      csv_list.appendSlice(allocator, s);
      l.clearRetainingCapacity();
    }
    csv_list.clearRetainingCapacity();
    return self.get_csv_line_str(csv_list, "\n");
  }

  fn save_csv(
    self: *Csv,
    file: []const u8,
    data: []const u8
  ) !void {
    _ = self;
    const f = try std.fs.cwd().openFile(file, .{ .mode = .write_only });
    defer f.close();
    try f.writeAll(data);
  }

  fn get_csv_line(
    self: *Csv,
    list: *std.ArrayList([]const u8), 
    line: []const u8,
    seperator: []const u8
  ) !void {
    if (line.len == 0) return;
    const allocator = self.arena_allocator();
    var cols = std.mem.splitSequence(u8, line, seperator); //splitScalar
    while (cols.next()) |col| {
      try list.append(allocator, try allocator.dupe(
        u8, std.mem.trim(u8, col, " \r") 
      ));
    }
  }

  fn read_csv(self: *Csv, io: std.Io,) !void {
    const allocator = self.arena_allocator();
    const text = try std.Io.Dir.cwd().readFileAlloc(
      io,
      self.file,
      allocator,
      .unlimited,
    );
    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |line| {
      var row: std.ArrayList([]const u8) = .empty;
      try self.get_csv_line(&row, line, ",");
      self.headers = try row.toOwnedSlice(allocator);
      break;
    }
    while (lines.next()) |line| {
      var row: std.ArrayList([]const u8) = .empty;
      defer row.deinit(allocator);
      var row_map = std.StringHashMap([]const u8).init(allocator);
      try self.get_csv_line(&row, line, ", ");
      for (row.items, 0..) |value, j| {
        try row_map.put(self.headers[j], value);
      }
      try self.rows.append(allocator, row_map);
    }
  }

  fn arena_allocator(self: *Csv) std.mem.Allocator {
      return self.arena.allocator();
  }

  pub fn init(io: std.Io, allocator: std.mem.Allocator, file: []const u8) !Csv {
    const arena = std.heap.ArenaAllocator.init(allocator);
    var csv = Csv{
      .arena = arena,
      .file = file,
    };
    try csv.read_csv(io);
    return csv;
  }

  pub fn deinit(self: *const Csv) void {
    self.arena.deinit();
  }

  pub fn print_headers(self: *const Csv) !void {
    for(self.headers) |h|{
      std.debug.print("{s} ", .{h});
    }
    std.debug.print("\n", .{});
  }

};

pub fn hello() !void {
  std.debug.print("{s}\n", .{"hello from csv!"});
}
