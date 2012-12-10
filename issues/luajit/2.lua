-- testing access to function arguments

X = nil
a = {}
function a:f (a, b, ...) local c = 13 end
debug.sethook(function (e)
  assert(e == "call")
  dostring("XX = 12")  -- test dostring inside hooks
  -- testing errors inside hooks
  assert(not pcall(loadstring("a='joao'+1")))
  debug.sethook(function (e, l) 
    assert(debug.getinfo(2, "l").currentline == l)
    local f,m,c = debug.gethook()
    assert(e == "line")
    assert(m == 'l' and c == 0)
    debug.sethook(nil)  -- hook is called only once
    assert(not X)       -- check that
    X = {}; local i = 1
    local x,y
    while 1 do
      x,y = debug.getlocal(2, i)
      if x==nil then break end
      X[x] = y
      i = i+1
    end
  end, "l")
end, "c")

a:f(1,2,3,4,5)

for i,v in pairs(X)  do 
    print(i,v) 
end
-- LuaJIT is is not findind arg when looking up local variables
--assert(X.self == a and X.a == 1   and X.b == 2 and X.arg.n == 3 and X.c == nil)
assert(XX == 12)
assert(debug.gethook() == nil)