const std = @import("std");

const Csv = struct {
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
    for(row.items) |h|{
      var s = "";
      var it = self.rows.iterator();
      while (it.next()) |e| {
        s = try std.mem.join(self.allocator, seperator, e.value_ptr.*);
      }
      
    }
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

  pub fn read_csv(self: *Csv, file: []const u8) void {
    const text = try std.Io.Dir.cwd().readFileAlloc(
      io,
      file,
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
}
