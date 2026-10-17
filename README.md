# iNo UI 2.0

ไลบรารี UI เปล่าสำหรับ Roblox / Luau ใช้กับหลายสคริปต์ โทนดำ–เขียว รองรับเมาส์และสัมผัส โหลดจาก main.lua เพียงไฟล์เดียว ไม่สร้างแท็บ สถิติ บันทึก หรือปุ่มเฉพาะเกมขึ้นมาเอง

## เริ่มแบบเปล่า

```lua
local UI = loadstring(game:HttpGet('https://raw.githubusercontent.com/xxxlog18/iNo-Needle-UI/refs/heads/main/main.lua'))()
local Window = UI:CreateWindow({
    Title = 'สคริปต์ของฉัน',
    SubTitle = 'เมนูส่วนตัว',
    Size = UDim2.fromOffset(700, 460),
    UIScale = 1,
})
```

ใช้ [empty.luau](empty.luau) เป็นแม่แบบหน้าต่างเปล่า หรือดู [example.luau](example.luau) สำหรับตัวอย่างตัวควบคุม แต่ละสคริปต์กำหนดชื่อเมนู คำอธิบาย และการทำงานเอง

## เพิ่มเมนูของสคริปต์

```lua
local General = Window:AddTab({Title = 'ทั่วไป', Icon = 'home'})
General:AddToggle('Enabled', {
    Title = 'เปิดใช้งาน',
    Description = 'คำอธิบายของฟังก์ชันในสคริปต์ของคุณ',
    Default = false,
}):OnChanged(function(enabled)
    -- เชื่อมกับการทำงานของคุณ
end)
```

OnChanged เรียกครั้งแรกด้วยค่าปัจจุบัน จากนั้นเรียกเมื่อค่าเปลี่ยน ใช้ ID ตัวเลือกที่ไม่ซ้ำกันในแต่ละหน้าต่าง

## API

- CreateWindow: Title, SubTitle, Name, LogoText, Icon (ภาพ), Size, UIScale, MinimizeKey, CloseMessage, Footer, StatusText
- AddTab: Title, Icon (ชื่อไอคอน), Order; ลำดับเริ่มต้นตามที่เพิ่ม
- AddToggle, AddSlider, AddInput, AddDropdown (เลือกเดียว/หลายรายการ), AddColorpicker, AddButton, AddParagraph
- UI.Options[id].Value, SetValue, OnChanged; paragraph:SetDesc(text); color:SetValueRGB(Color3)
- Window:SelectTab(tab), Minimize(), SetZoom(0.8–1.5), SetSize(UDim2), SetPosition(Vector2), ResetPosition(), SetBrandImage(image)
- Window.OnClose, OnResize, OnPositionChanged; UI:Notify({Title, Content}), UI:Destroy()
- เลือกเปิดแถบล่างด้วย Footer=true; Window:SetStatus(text, fault) เปลี่ยนข้อความ; Window:AddFooterButton({Title, Callback, Color}) เพิ่มปุ่มและเปิดแถบล่าง
- ไอคอนแท็บ: home, gem, wheat, wrench, shopping-cart, trending-up, flag, target, eye, repeat, settings, file-text

ค้นหาชื่อและคำอธิบายในทุกแท็บ ลากหน้าต่างจากแถบหัว ย่อ/แสดงด้วย RightControl ขนาดเริ่มต้น 100% และย่อให้พอดีเมื่อจอเล็ก เปลี่ยน Zoom โดยไม่ขยายขนาดหน้าต่างจริง UI ไม่บันทึกค่าหรือส่งบันทึกการทำงานเอง

## ส่วนเสริม Needle Helper

[extensions/needle.lua](extensions/needle.lua) โหลดแยกจาก main.lua เฉพาะเมื่อ Helper v24.3 เรียกใช้ มีตัวแปลภาษาไทยและหน้าภาพรวมข้อมูลจริงของเกม ไม่มีหน้าสถิติหรือบันทึก เมธอดของส่วนเสริมคือ InstallThaiDisplay(UI) และ AttachDashboard(UI, window, state, remotes, player, savedOptions)

สคริปต์อื่นไม่ต้องโหลดส่วนเสริมนี้ Helper รุ่นก่อน v24.3 ต้องอัปเดตตัวติดตั้งเพื่อใช้การแยกไฟล์รุ่นใหม่ หากโหลด UI หรือส่วนเสริมไม่สำเร็จ Helper ใหม่จะยังไม่หยุดตัวเก่าที่ทำงานอยู่

## Build

```text
node build.mjs
```

src/core.luau และ src/controls.luau สร้าง main.lua ส่วน src/localize.luau, src/thai.json และ src/dashboard.luau สร้าง extensions/needle.lua แยกกัน ไม่ต้องติดตั้ง dependencies เพื่อ build หรือใช้ UI
