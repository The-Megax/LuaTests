-- tests for tail calls
-- TAIL CALLS is not behaving the same way as Lua on LuaJIT
local function f (x)
  if x then
    assert(debug.getinfo(1, "S").what == "Lua")
    local tail = debug.getinfo(2)
    print (tail) for i,v in pairs (tail) do print (i, v) end
    -- assert(not pcall(getfenv, 3))
    --assert(tail.what == "tail" and tail.short_src == "(tail call)" and
    --       tail.linedefined == -1 and tail.func == nil)
    --print (debug.getinfo(3, "f").func, g1)
    --assert(debug.getinfo(3, "f").func == g1)
    assert(getfenv(3))
    -- assert(debug.getinfo(4, "S").what == "tail")
    --assert(not pcall(getfenv, 5))
    -- assert(debug.getinfo(5, "S").what == "main")
    --assert(getfenv(5))
    print"+"
    end
end

function g(x) return f(x) end

function g1(x) g(x) end

local function h (x) local f=g1; return f(x) end

h(true)

local b = {}
debug.sethook(function (e) table.insert(b, e) end, "cr")
h(false)
debug.sethook()
local res = {"return",   -- first return (from sethook)
  "call", "call", "call", "call",
  "return", "tail return", "return", "tail return",
  "call",    -- last call (to sethook)
}
-- for _, k in ipairs(res) do assert(k == table.remove(b, 1)) end


lim = 30000
local function foo (x)
  if x==0 then
    assert(debug.getinfo(lim+2).what == "main")
    for i=2,lim do assert(debug.getinfo(i, "S").what == "tail") end
  else return foo(x-1)
  end
end

foo(lim)
