-- Independent library example. No gameplay automation is started here.
local iNo=loadstring(game:HttpGet('https://raw.githubusercontent.com/xxxlog18/iNo-Needle-UI/main/main.lua'))()
local window=iNo:CreateWindow({MinimizeKey=Enum.KeyCode.RightControl})
local farm=window:AddTab({Title='เก็บฟาง'})
farm:AddToggle('ExampleAuto',{Title='ตัวอย่างสวิตช์',Description='ตัวอย่างนี้แจ้งค่าอย่างเดียว ไม่ได้เริ่มเก็บฟาง',Default=false}):OnChanged(function(value)
    print('Example toggle:',value)
end)
farm:AddSlider('ExampleRadius',{Title='ระยะค้นหา',Min=3,Max=25,Rounding=0,Default=18})
farm:AddDropdown('ExamplePriority',{Title='ลำดับการเก็บ',Values={'เพชร → หายาก → ธรรมดา','หายาก → ธรรมดา'},Default=1})
local settings=window:AddTab({Title='ตั้งค่า'})
settings:AddInput('ExampleName',{Title='ชื่อโปรไฟล์',Default='ส่วนตัว',Finished=true})
settings:AddColorpicker('ExampleColor',{Title='สีไฮไลต์',Default=Color3.fromRGB(177,236,79)})
window.OnPause=function() iNo.Options.ExampleAuto:SetValue(false) end
window:SelectTab(farm)
-- RightControl toggles the window. The full helper also includes its draggable iNo icon.
