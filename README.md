# iNo Needle UI

ไลบรารี UI เขียนเองสำหรับ Roblox / Luau โทนดำ–เขียวตามแบบ iNo Needle รองรับเมาส์และสัมผัส ไม่โหลด Fluent หรือไลบรารี UI ภายนอก

```lua
local iNo = loadstring(game:HttpGet('https://raw.githubusercontent.com/xxxlog18/iNo-Needle-UI/main/main.lua'))()
local window = iNo:CreateWindow({MinimizeKey = Enum.KeyCode.RightControl})
local farm = window:AddTab({Title = 'เก็บฟาง'})
local auto = farm:AddToggle('Auto', {Title = 'เก็บฟางอัตโนมัติ', Default = false})
auto:OnChanged(function(value)
    -- เชื่อมกับระบบของคุณ
end)
window:SelectTab(farm)
```

ดูตัวอย่างเต็มที่ [example.luau](example.luau) ไลบรารีมี UI เท่านั้น การเก็บฟาง เป้าหมายด่าน และการต่อสู้เป็นงานของ Needle Helper

## ตัวควบคุม

- AddToggle, AddSlider, AddInput, AddDropdown (เลือกเดียว/หลายรายการ)
- AddColorpicker และ SetValueRGB
- AddButton, AddParagraph และ SetDesc
- Options[key].Value, SetValue, OnChanged
- CreateWindow, AddTab, SelectTab, Minimize, Notify, Destroy
- ค้นหาชื่อ/คำอธิบายฟังก์ชันทุกแท็บ เมนูเลื่อนและหน้าต่างปรับขนาดตามจอ
- ลากหน้าต่างจากแถบหัว ย่อด้วยปุ่มหรือ RightControl ปุ่มปิดถามก่อนทำงาน

OnChanged เรียกครั้งแรกด้วยค่าปัจจุบัน จากนั้นเรียกเมื่อค่าเปลี่ยน การเลือกหลายรายการใช้ตารางชื่อ=true ค่าของ dropdown ใช้ชื่อรายการ ส่วน Default แบบตัวเลขหมายถึงลำดับเริ่มต้น

## เชื่อมกับ Needle Helper

Helper v24 ฝังไลบรารีในไฟล์ติดตั้ง เพื่อโหลดต่อข้ามรอบได้แม้ลิงก์ UI เปลี่ยนหรือ GitHub ไม่พร้อม โดยใช้ option IDs เดิมทั้งหมดและตัวแปลภาษาไทยเดิม

หน้าภาพรวมแสดงเงิน เพชร กระเป๋า เป้าหมาย และข้อมูลบอสจากเกม ไม่มีค่าตัวอย่างแทรกแทนข้อมูลที่ขาด ถ้าไม่มีค่าเลือดสูงสุดจะไม่วาดแถบเปอร์เซ็นต์ ปุ่มพักเรียก pauseAll ของ helper และปุ่มดูบันทึกเปิดรายการเหตุการณ์ล่าสุด

## พัฒนา

ซอร์สอยู่ใน src/core.luau และ src/controls.luau สั่ง `node build.mjs` เพื่อสร้าง main.lua ไม่ต้องติดตั้ง dependencies เพื่อ build หรือใช้ไลบรารี

```text
node build.mjs
```

ชุดทดสอบรวมอยู่ใน workspace Needle Helper ต้นฉบับ แยกจากไลบรารีที่เผยแพร่ ใช้ Luau runtime กับโมเดล Roblox ในหน่วยความจำ ตรวจ callbacks, ค่าตัวเลือกภาษาไทย, หลายรายการ, lifecycle, popup, การค้นหา, touch input, การอ่านเป้าหมาย และการ compile Helper ชุดทดสอบนี้ไม่ได้ยืนยันหน้าตาหรือการสัมผัสใน Roblox จริง ต้องตรวจใน client เพิ่มเติม
