local locales = { "ptb", "ISO-8859-1", "pt_BR" }
local function trylocale (w)
  for _, l in ipairs(locales) do
    if os.setlocale(l, w) then return true end
  end
  return false
end

if not trylocale("collate")  then
  print("locale not supported")
else
  print ("alo" < "álo", "álo" < "amo")
  assert("alo" < "álo" and "álo" < "amo")
end