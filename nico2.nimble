# Package

version       = "0.1.0"
author        = "HVukman"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["nico2"]


task emscripten, "Builds with emscripten":
  exec "nimble c -d:emscripten nico2.nim"
  
# Dependencies

requires "nim >= 2.0.0"
requires "nico"
