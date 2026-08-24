# core.zig

> [!NOTE]
> Originated from https://github.com/sarpagarud/unemployed-zig

Core zig library

## Installation

```bash
zig fetch --save git+https://github.com/sarpagarud/core.zig
```

`build.zig`:
```zig
const core_zig = b.dependency("core_zig", .{
    .target = target,
    .optimize = optimize,
});
mod.addImport("core.zig", zig_core.module("core_zig"));
exe.root_module.addImport("core.zig", zig_core.module("core_zig"));
```
