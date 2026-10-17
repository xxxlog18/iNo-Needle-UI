-- Blank template. Add only the tabs and controls required by your script.
local UI=loadstring(game:HttpGet('https://raw.githubusercontent.com/xxxlog18/iNo-Needle-UI/refs/heads/main/main.lua'))()
local Window=UI:CreateWindow({
    Title='สคริปต์ของฉัน',
    SubTitle='เมนูส่วนตัว',
    Size=UDim2.fromOffset(700,460),
    UIScale=1,
    MinimizeKey=Enum.KeyCode.RightControl,
})

-- Example: local Tab=Window:AddTab({Title='ทั่วไป',Icon='home'})
-- Connect controls to your script through Callback or OnChanged.
