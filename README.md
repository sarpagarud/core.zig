# core.zig
Core zig library

## Installation

```bash
zig fetch --save https://github.com/sarpagarud/core.zig
```

`build.zig`:
```zig
    const core_zig = b.dependency("core_zig", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("core.zig", zig_core.module("core_zig"));
```
