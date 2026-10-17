# iNo Needle UI

ไลบรารี UI เขียนเองสำหรับ Roblox / Luau โทนดำ–เขียวตามแบบ iNo Needle รองรับเมาส์และสัมผัส ไม่โหลด Fluent หรือไลบรารี UI ภายนอก

```lua
local iNo = loadstring(game:HttpGet('https://raw.githubusercontent.com/xxxlog18/iNo-Needle-UI/refs/heads/main/main.lua'))()
local window = iNo:CreateWindow({Size = UDim2.fromOffset(760, 480), UIScale = 1, MinimizeKey = Enum.KeyCode.RightControl})
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
- รุ่น 1.2 ใช้ขนาดตัวอักษรเริ่มต้น 100% ปรับได้ผ่าน window:SetZoom(value) โดยไม่เพิ่มขนาดหน้าต่าง
- ใช้ค่า Size ที่ส่งให้ CreateWindow จริง รองรับทั้ง Offset/Scale และย่อให้พอดีเมื่อ viewport เล็ก เปลี่ยนขนาดได้ผ่าน window:SetSize(UDim2)
- ภาพรวมใน Helper ตรึงเงิน/เพชร/กระเป๋า และแยกพื้นที่เลื่อนซ้ายกับขวา จอแคบมีปุ่มสลับส่วนควบคุมกับสถานะ
- ลากหน้าต่างจากแถบหัว ย่อด้วยปุ่มหรือ RightControl ปุ่มปิดถามก่อนทำงาน

OnChanged เรียกครั้งแรกด้วยค่าปัจจุบัน จากนั้นเรียกเมื่อค่าเปลี่ยน การเลือกหลายรายการใช้ตารางชื่อ=true ค่าของ dropdown ใช้ชื่อรายการ ส่วน Default แบบตัวเลขหมายถึงลำดับเริ่มต้น

## เชื่อมกับ Needle Helper

Helper v24.2 โหลดไลบรารีจากลิงก์ raw GitHub ด้านบน ใช้ option IDs เดิม ส่วน UI ภาษาไทยและหน้าภาพรวมอยู่ในไลบรารีนี้แล้ว ไม่ฝังซ้ำใน Helper ต้องเชื่อมต่อ GitHub ได้ตอนเริ่มหรือโหลดข้ามรอบ หากดาวน์โหลดหรือเวอร์ชัน API ไม่ผ่าน Helper จะไม่หยุดตัวเก่าที่ยังทำงานอยู่

เมธอด `iNo:InstallThaiDisplay()` ติดตั้งตัวแปลชื่อ/ค่าตัวเลือกภาษาไทย และ `iNo:AttachNeedleDashboard(window,state,remotes,player,savedOptions)` เชื่อมหน้าภาพรวมกับ Helper ที่เริ่มทำงานแล้ว ส่วนหลังอ่านข้อมูลจริงจากเกมและเรียกตัวเลือกเดิม ไม่ได้เพิ่มพลังหรือข้ามเงื่อนไขเกม

หน้าภาพรวมแสดงเงิน เพชร กระเป๋า เป้าหมาย และข้อมูลบอสจากเกม ไม่มีค่าตัวอย่างแทรกแทนข้อมูลที่ขาด ถ้าไม่มีค่าเลือดสูงสุดจะไม่วาดแถบเปอร์เซ็นต์ ปุ่มพักเรียก pauseAll ของ helper และปุ่มดูบันทึกเปิดรายการเหตุการณ์ล่าสุด

## พัฒนา

ซอร์สอยู่ใน src/core.luau, src/controls.luau, src/localize.luau, src/thai.json และ src/dashboard.luau สั่ง `node build.mjs` เพื่อสร้าง main.lua ไม่ต้องติดตั้ง dependencies เพื่อ build หรือใช้ไลบรารี

```text
node build.mjs
```

ชุดทดสอบรวมอยู่ใน workspace Needle Helper ต้นฉบับ แยกจากไลบรารีที่เผยแพร่ ใช้ Luau runtime กับโมเดล Roblox ในหน่วยความจำ ตรวจ callbacks, ค่าตัวเลือกภาษาไทย, หลายรายการ, lifecycle, popup, การค้นหา, touch input, การอ่านเป้าหมาย และการ compile Helper ชุดทดสอบนี้ไม่ได้ยืนยันหน้าตาหรือการสัมผัสใน Roblox จริง ต้องตรวจใน client เพิ่มเติม
