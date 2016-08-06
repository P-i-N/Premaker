newoption { trigger = "cwd", value = "path", description = "Working directory for solution setup" }

-- Remember CWD
local oldCWD = os.getcwd()

if _OPTIONS["cwd"] then
  os.chdir(_OPTIONS["cwd"])
else
  _OPTIONS["cwd"] = oldCWD
end

-- Set default globals
SolutionName = ""
IncludeDirs = { ".", "src" }
LibDirs = { }

-- Get solution setup
dofile("solution.lua")

-- If Premaker checkout exists in parent directory, use it instead, otherwise try to use CWD
if os.isfile("../Premaker/premaker.lua") then
  dofile("../Premaker/premaker.lua")
else
  dofile("premaker.lua")
end

-- Restore old working directory
os.chdir(oldCWD)
