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

-----------------------------------------------------------------------------------------------------------------------

if SolutionName == "" then
  SolutionName = path.getname(os.getcwd())
end

-----------------------------------------------------------------------------------------------------------------------

-- Generate named project using defined params
function GenerateProject(params, name)
  print("Generating project: " .. name)
  
  function GetParam(key, default)
    local result = params[key]
    if result == nil then return default end
    return result
  end
  
  local _type = GetParam("type", "lib")
  local _language = GetParam("language", "C++")
  local _include_current = GetParam("include_current", false)
  local _name = GetParam("name", "")
  local _shared_macro = GetParam("shared_macro", string.upper(name) .. "_BUILDING")
  local _links = GetParam("links", { })
  local _windows_links = GetParam("windows_links", { })
  local _linux_links = GetParam("linux_links", { })
  local _include = GetParam("include", { })
  local _defines = GetParam("defines", { })
  local _configure_callback = GetParam("configure_callback", nil)

  language(_language)
  
  if _type == "lib" then
    filter { "configurations:Static*" }
      kind "StaticLib"
    filter { "configurations:DLL*" }
      kind "SharedLib"
      defines { _shared_macro }
    filter { }
  elseif _type == "console" then
    kind "ConsoleApp"
  elseif _type == "windowed" then
    kind "WindowedApp"
  elseif _type == "static" then
    kind "StaticLib"
  elseif _type == "dynamic" then
    kind "SharedLib"
    defines { _shared_macro }
  elseif _type == "app" then
    filter { "configurations:*Debug" }
      kind "ConsoleApp"
    filter { "configurations:*Release" }
      kind "WindowedApp"
    filter { }
  end
  
  files { "**.c", "**.cc", "**.cpp", "**.h", "**.hpp", "**.inl", "**.cs", "**.natvis" }
  
  if _name ~= "" then
    targetname(_name)
  end
  
  links(_links)
  includedirs(_include)
  defines(_defines)
  
  filter { "system:windows" }
    links(_windows_links)
    
  filter { "system:linux" }
    links(_linux_links)
    
  filter { }
  
  -- Enable precompiled headers, if they exist
  if os.isfile("StdAfx.h") and os.isfile("StdAfx.cpp") then
    filter { "action:vs*" }
      pchheader "StdAfx.h"
      pchsource "StdAfx.cpp"
      buildoptions { '/FI StdAfx.h' }
         
    filter { }
  end

  if _configure_callback ~= nil then
    _configure_callback(params)
  end
  
end

-----------------------------------------------------------------------------------------------------------------------

solution(SolutionName)
  configurations { "Debug", "Release" }
  platforms { "64-bit" }
  location(path.join(".build", _ACTION))

filter { "platforms:64*" }
  architecture "x86_64"
  
filter { "configurations:*Debug" }
  defines { "_DEBUG", "DEBUG" }
  flags { "Symbols" }
  
filter { "configurations:*Debug", "language:not C#" }  
  targetsuffix "_debug"
  
filter { "configurations:*Release" }
  defines { "_NDEBUG", "NDEBUG" }
  flags { "Symbols" }
  optimize "On"

filter { "system:windows", "platforms:64*" }
  defines { "_WIN64", "WIN64" }
  
filter { "system:windows", "language:not C#" }
  defines { "_WIN32", "WIN32", "_CRT_SECURE_NO_WARNINGS", "_WIN32_WINNT=0x0601", "WINVER=0x0601", "NTDDI_VERSION=0x06010000" }
  flags { "NoMinimalRebuild", "MultiProcessorCompile" }
  buildoptions { '/wd"4503"' }
  
  if _ACTION == "vs2015" then
    defines { "_MSC_VER=1900" }

    filter { "system:windows", "configurations:DLL Debug", "language:not C#" }
      links { "ucrtd.lib", "vcruntimed.lib", "msvcrtd.lib" }

    filter { "system:windows", "configurations:DLL Release", "language:not C#" }
      links { "ucrt.lib", "vcruntime.lib", "msvcrt.lib" }
      
    filter { }
  end
  
filter { "language:not C#" }
  characterset ("MBCS")
  buildoptions { "/std:c++latest" }
  
filter { }
  includedirs(IncludeDirs)
  libdirs(LibDirs)
  targetdir ".bin/%{cfg.buildcfg}"
  
-- Get current directory
cwd = os.getcwd()

-- Set default empty group
group ""
  
-- Enumerate all projects in global Projects table
for k, Project in pairs(Projects) do
  if Project.dir ~= nil then
    ok, err = os.chdir(Project.dir)
    
    if ok == true then
    
      -- Set project name
      local name = k
      
      if type(name) == "number" then
        name = Project.name
      end
      
      if name == nil then
        -- If name was not specified, create it from project directory name
        name = path.getname(Project.dir)
      end
      
      -- Set premake project context
      project(name)
      
      -- Generate project information
      GenerateProject(Project, name)
      
      -- Change directory back
      os.chdir(cwd)
      
    else
      print("Could not change directory to: " .. Project.dir)
    end
  else
    print("Project does not have a directory specified!")
  end
end

-----------------------------------------------------------------------------------------------------------------------

-- Restore old working directory
os.chdir(oldCWD)
