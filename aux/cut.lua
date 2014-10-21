local sw = false
local line

for line in io.lines() do
   if string.match(line, "^%-%-%[%[%-%-") then
      sw = true
   elseif string.match(line, "^%-%-%]%]%-%-") then
      sw = false
   elseif sw then
      print(line)
   end
end
