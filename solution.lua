-- Define list of projects in this solution. Supported parameters and default values:
--
--     dir - required parameter, directory containing source files
--
--     type ("lib") - console application ("console")
--                  - windowed application ("windowed")
--                  - console/windowed in debug/release ("app")
--                  - library or DLL, depends on selected configuration ("lib")
--                  - static library ("static")
--                  - dynamic library ("dynamic")
--
--     language ("C++") - project language
--
--     name ("") - optional project name
--
--     shared_macro ("BUILDING") - macro defined when building shared library
--
--     links ({ }) - linked libraries, projects
--
--     windows_links ({ }) - linked libraries on Windows platform
--
--     linux_links ({ }) - linked libraries on Linux platform
--
--     include ({ }) - include directories
--
--     defines ({ }) - project specific defines
--
--     configure_callback (nil) - function called when this project is being configured
--
-----------------------------------------------------------------------------------------------------------------------
Projects =
{
  -- gl3d
  {
    dir = "src/gl3d",
    type = "static",
    defines = { "GL3D_IMPLEMENTATION" }
  },

  -- test
  {
    dir = "src/test",
    type = "console",
  }
}
