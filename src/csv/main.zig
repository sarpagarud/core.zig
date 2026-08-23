const std = @import("std");

const Csv = struct {
  file: []const u8,
  arena: std.heap.ArenaAllocator,
  headers: [][]const u8 = .{},
  rows: std.ArrayList(std.StringHashMap([]const u8)) = .{},

  fn get_csv_line(
    list: *std.ArrayList([]const u8),
    seperator: []const u8
  ) ![]const u8 {
    const allocator = self.arena_allocator();
    return try std.mem.join(allocator, seperator, list.items);
  }

  fn get_csv_lines(
    list: *std.ArrayList([]const u8),
    seperator: []const u8
  ) ![]const u8 {
    const allocator = self.arena_allocator();
    var csv_list: std.ArrayList([]const u8) = .empty;
    for(row.items) |h|{
      var it = self.rows.iterator();
      var l: std.ArrayList([]const u8) = .empty;
      while (it.next()) |e| {
        l.appendSlice(allocator, e.value_ptr.*);
      }
      var s = try self.get_csv_line(l, seperator);
      csv_list.appendSlice(allocator, s);
      l.clearRetainingCapacity();
    }
    csv_list.clearRetainingCapacity();
    return self.get_csv_line(csv_list, "\n");
  }

  fn save_csv(
    file: []const u8,
    data: []const u8
  ) !void {
    const f = try std.fs.cwd().openFile(file, .{ .mode = .write_only });
    defer f.close();
    try f.writeAll(data);
  }

  fn get_csv_line(
    list: *std.ArrayList([]const u8), 
    line: []const u8,
    seperator: []const u8
  ) !void {
    if (line.len == 0) return;
    const allocator = self.arena_allocator();
    var cols = std.mem.splitScalar(u8, line, seperator);
    while (cols.next()) |col| {
      try list.append(allocator, try a.dupe(
        u8, std.mem.trim(u8, col, " \r") 
      ));
    }
  }

  fn read_csv(self: *Csv) void {
    const allocator = self.arena_allocator();
    const text = try std.Io.Dir.cwd().readFileAlloc(
      io,
      self.file,
      allocator,
      .unlimited,
    );
    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |line| {
      try get_csv_line(allocator, &self.headers, line);
      break;
    }
    while (lines.next()) |line| {
      var row: std.ArrayList([]const u8) = .empty;
      defer row.deinit(allocator);
      var row_map = std.StringHashMap([]const u8).init(allocator);
      try get_csv_line(allocator, &row, line);
      for (row.items, 0..) |value, j| {
        try row_map.put(headers.items[j], value);
      }
      try rows.append(allocator, row_map);
    }
  }

  fn arena_allocator(self: *Csv) std.mem.Allocator {
      return self.arena.allocator();
  }

  pub fn init(self: *Csv, allocator: std.mem.Allocator, file: []const u8) Csv {
    return .{
      .arena = std.heap.ArenaAllocator.init(allocator),
      .file: try file.toOwnedSlice(self.allocator);
    };
  }

  pub fn deinit(self: *Csv) !void {
    self.arena.deinit();
  }

}
