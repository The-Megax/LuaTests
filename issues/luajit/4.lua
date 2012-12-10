local function f (n)
  if n > 0 then return f(n-1)
  else coroutine.yield() end
end

local co = coroutine.create(f)
coroutine.resume(co, 3)
checktraceback(co, {"yield", "db.lua", "tail", "tail", "tail"})



co = coroutine.create(function (x)
       local a = 1
       coroutine.yield(debug.getinfo(1, "l"))
       coroutine.yield(debug.getinfo(1, "l").currentline)
       return a
     end)

local tr = {}
local foo = function (e, l) table.insert(tr, l) end
debug.sethook(co, foo, "l")

local _, l = coroutine.resume(co, 10)
local x = debug.getinfo(co, 1, "lfLS")
assert(x.currentline == l.currentline and x.activelines[x.currentline])
assert(type(x.func) == "function")
for i=x.linedefined + 1, x.lastlinedefined do
  assert(x.activelines[i])
  x.activelines[i] = nil
end
assert(next(x.activelines) == nil)   -- no 'extra' elements
assert(debug.getinfo(co, 2) == nil)
local a,b = debug.getlocal(co, 1, 1)
assert(a == "x" and b == 10)
a,b = debug.getlocal(co, 1, 2)
assert(a == "a" and b == 1)
debug.setlocal(co, 1, 2, "hi")
assert(debug.gethook(co) == foo)
assert(table.getn(tr) == 2 and
       tr[1] == l.currentline-1 and tr[2] == l.currentline)

a,b,c = pcall(coroutine.resume, co)
assert(a and b and c == l.currentline+1)

checktraceback(co, {"yield", "in function <"})

a,b = coroutine.resume(co)
assert(a and b == "hi")
assert(table.getn(tr) == 4 and tr[4] == l.currentline+2)
assert(debug.gethook(co) == foo)
assert(debug.gethook() == nil)
checktraceback(co, {})


-- check traceback of suspended (or dead with error) coroutines

function f(i) if i==0 then error(i) else coroutine.yield(); f(i-1) end end

co = coroutine.create(function (x) f(x) end)
a, b = coroutine.resume(co, 3)
t = {"'yield'", "'f'", "in function <"}
while coroutine.status(co) == "suspended" do
  checktraceback(co, t)
  a, b = coroutine.resume(co)
  table.insert(t, 2, "'f'")   -- one more recursive call to 'f'
end
t[1] = "'error'"
checktraceback(co, t)
