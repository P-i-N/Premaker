-- Set default globals
SolutionName = ""
IncludeDirs = { ".", "src" }
LibDirs = { }

-- Get solution setup
dofile("solution.lua")

-- Run main Premaker script
dofile("premaker.lua")
