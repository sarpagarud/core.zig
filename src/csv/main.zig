const std = @import("std");

const Csv = struct {
  file: []const u8,
  allocator: std.mem.Allocator,
  headers: [][]const u8,
  rows: std.ArrayList(std.StringHashMap([]const u8)),

  fn get_csv_line(
    list: *std.ArrayList([]const u8),
    seperator: []const u8
  ) ![]const u8 {
    return try std.mem.join(self.allocator, seperator, list.items);
  }

  fn get_csv_lines(
    list: *std.ArrayList([]const u8),
    seperator: []const u8
  ) ![]const u8 {
    var csv_list: std.ArrayList([]const u8) = .empty;
    for(row.items) |h|{
      var it = self.rows.iterator();
      var l: std.ArrayList([]const u8) = .empty;
      while (it.next()) |e| {
        l.appendSlice(self.allocator, e.value_ptr.*);
      }
      var s = try self.get_csv_line(l, seperator);
      csv_list.appendSlice(self.allocator, s);
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
    var cols = std.mem.splitScalar(u8, line, seperator);
    while (cols.next()) |col| {
      try list.append(self.allocator, try a.dupe(
        u8, std.mem.trim(u8, col, " \r") 
      ));
    }
  }

  fn read_csv(self: *Csv) void {
    const text = try std.Io.Dir.cwd().readFileAlloc(
      io,
      self.file,
      self.allocator,
      .unlimited,
    );
    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |line| {
      try get_csv_line(self.allocator, &self.headers, line);
      break;
    }
    while (lines.next()) |line| {
      var row: std.ArrayList([]const u8) = .empty;
      defer row.deinit(self.allocator);
      var row_map = std.StringHashMap([]const u8).init(self.allocator);
      try get_csv_line(self.allocator, &row, line);
      for (row.items, 0..) |value, j| {
        try row_map.put(headers.items[j], value);
      }
      try rows.append(self.allocator, row_map);
    }
  }
  pub fn init(self: *Csv, file: []const u8) !void {
    self.file = try file.toOwnedSlice(self.allocator);
    self.read_csv();
  }
}
