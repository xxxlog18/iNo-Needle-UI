-- Optional Needle Helper presentation. Not loaded by main.lua.
local installThaiDisplay=(function()
-- Display adapter: persisted option IDs and values stay unchanged.
return function(Fluent, dictionary)
    local reverse, replacements = {}, {}
    for key,label in pairs(dictionary.values) do reverse[label]=key end
    local display = table.clone(dictionary.values)
    for key,label in pairs(dictionary.labels) do display[key]=label end
    for key,label in pairs(display) do table.insert(replacements,{key=key,label=label}) end
    table.sort(replacements,function(a,b) return #a.key>#b.key end)
    local function text(value)
        if type(value)~='string' then return value end
        if display[value] then return display[value] end
        -- Protect translated spans from being translated a second time.
        local placeholders={}
        for _,entry in ipairs(replacements) do
            local pattern=entry.key:gsub('([^%w])','%%%1')
            value=value:gsub(pattern,function()
                table.insert(placeholders,entry.label)
                return string.char(1)..tostring(#placeholders)..string.char(2)
            end)
        end
        value=value:gsub(string.char(1)..'(%d+)'..string.char(2),function(index) return placeholders[tonumber(index)] end)
        return (value:gsub('(%d+%.?%d*)s',function(number) return number..' วินาที' end))
    end
    local function mapValue(value, mapping)
        if type(value)=='string' then return mapping[value] or value end
        if type(value)=='table' then
            local result={}
            for key,item in pairs(value) do
                if type(key)=='string' then result[mapping[key] or key]=item
                else result[key]=mapping[item] or item end
            end
            return result
        end
        return value
    end
    local function translateConfig(config,key)
        local result=table.clone(config)
        for _,field in ipairs({'Title','SubTitle','Description','Content','Placeholder'}) do
            if result[field] then result[field]=text(result[field]) end
        end
        local description=dictionary.descriptions[key or config.Title]
        if description then result.Description=description end
        if key and key:sub(1,7)=='NH_Buy_' then result.Description='ซื้อด้วยเงินในเกมเมื่อเปิดซื้ออัตโนมัติ และข้ามเมื่อมีสินค้านี้แล้ว' end
        return result
    end
    local function wrapTab(tab)
        for _,method in ipairs({'AddToggle','AddSlider','AddInput','AddButton','AddParagraph','AddColorpicker','AddDropdown'}) do
            local original=tab[method]
            tab[method]=function(self,key,config)
                local named=type(key)=='table'
                if named then config=key;key=nil end
                local translated=translateConfig(config,key)
                if method=='AddDropdown' then
                    translated.Values=mapValue(config.Values,dictionary.values)
                    translated.Default=mapValue(config.Default,dictionary.values)
                    if config.Callback then translated.Callback=function(value) config.Callback(mapValue(value,reverse)) end end
                end
                local option
                if named then option=original(self,translated) else option=original(self,key,translated) end
                if method=='AddParagraph' and option and option.SetDesc then
                    local setDesc=option.SetDesc
                    option.SetDesc=function(object,value) return setDesc(object,text(value)) end
                elseif method=='AddDropdown' then
                    local proxy={}
                    setmetatable(proxy,{
                        __index=function(_,property)
                            if property=='Value' then return mapValue(option.Value,reverse) end
                            if property=='SetValue' then return function(_,value) return option:SetValue(mapValue(value,dictionary.values)) end end
                            if property=='OnChanged' then return function(_,callback) return option:OnChanged(function(value) callback(mapValue(value,reverse)) end) end end
                            local item=option[property]
                            if type(item)=='function' then return function(_,...) return item(option,...) end end
                            return item
                        end,
                        __newindex=function(_,property,value) option[property]=value end
                    })
                    Fluent.Options[key]=proxy
                    return proxy
                end
                return option
            end
        end
        return tab
    end
    Fluent.Translate=text
    local createWindow=Fluent.CreateWindow
    Fluent.CreateWindow=function(self,config)
        local window=createWindow(self,translateConfig(config))
        local addTab=window.AddTab
        window.AddTab=function(object,tabConfig) return wrapTab(addTab(object,translateConfig(tabConfig))) end
        return window
    end
    local notify=Fluent.Notify
    Fluent.Notify=function(self,config) return notify(self,translateConfig(config)) end
end

end)()
local thaiDictionary={["labels"]={["Needle Helper"]="ผู้ช่วยค้นหาเข็ม",["MuMu / Delta"]="เมนูภาษาไทย",["Farm"]="เก็บฟาง",["ESP"]="ไฮไลต์",["Settings"]="ตั้งค่า",["Gems"]="เพชร",["Upgrades"]="อัปเกรด",["Tools"]="เครื่องมือ",["Shop"]="ร้านค้า",["Replay"]="เล่นใหม่",["Objective"]="เป้าหมายด่าน",["Live status"]="สถานะปัจจุบัน",["Collection mode"]="วิธีเก็บฟาง",["Collect nearby hay"]="เก็บฟางอัตโนมัติ",["Auto sell and return"]="ขายอัตโนมัติแล้วกลับจุดเดิม",["Temporarily moves to the sell point."]="เมื่อฟางถึงจำนวนที่ตั้งไว้ จะย้ายไปขายและกลับมาเก็บต่อ",["Collect radius"]="ระยะค้นหาฟางรอบตัว",["Collect interval (seconds)"]="ช่วงเวลาหยิบฟาง (วินาที)",["Game cooldown still applies."]="ค่าต่ำลงไม่ได้ข้ามเวลารอของเกม ใช้ค่านี้กับการเก็บด้วยมือ",["Sell at bag percentage"]="ขายเมื่อกระเป๋าถึงเปอร์เซ็นต์",["Sell bag now and return"]="ขายฟางตอนนี้แล้วกลับมา",["Revealed needle ESP"]="ไฮไลต์เข็มที่เกมเปิดเผยแล้ว",["Target availability"]="เงื่อนไขการแสดงเข็ม",["The server must reveal the needle target before it can be highlighted."]="แสดงตำแหน่งได้เมื่อเกมส่งเป้าหมายเข็มมาแล้ว ไม่สามารถเปิดเผยเข็มที่ยังซ่อนไว้ได้",["Needle color"]="สีไฮไลต์เข็ม",["Pause all automation"]="หยุดระบบอัตโนมัติทั้งหมด",["Unload helper"]="ปิดผู้ช่วยและล้างการทำงาน",["Reset launcher position"]="คืนตำแหน่งไอคอนเมนู",["Collect nearby revealed gems"]="เก็บเพชรที่ปรากฏใกล้ตัว",["Gem ESP and distance"]="แสดงเพชรและระยะห่าง",["Gem collect radius"]="ระยะเก็บเพชร",["Collection"]="วิธีเก็บเพชร",["Collects revealed gems in range; does not move your character."]="เก็บเพชรที่เกมสร้างแล้วและอยู่ในระยะ โดยไม่ย้ายตัวละครไปหาเพชร",["Auto upgrade (spends Cash)"]="อัปเกรดอัตโนมัติด้วยเงินในเกม",["Upgrade mode"]="รูปแบบอัปเกรด",["Included tracks"]="สายอัปเกรดที่อนุญาต",["All selected by default. Locked and maxed tracks are skipped."]="เลือกเฉพาะสายที่ต้องการซื้อ ระบบข้ามสายที่ยังล็อกหรืออัปเต็มแล้ว",["Select all tracks"]="เลือกทุกสาย",["Upgrade sequence"]="ลำดับอัปเกรด",["How the sequence works"]="การอัปตามลำดับ",["Buys one level per track, then repeats. Skips locked, maxed, and unaffordable tracks. Cash reserve always applies."]="อัปสายละหนึ่งขั้นแล้ววนรอบ ข้ามสายที่ล็อก เต็ม หรือเงินไม่พอ และไม่ใช้เงินส่วนที่ตั้งสำรองไว้",["Upgrade track"]="เลือกสายสำหรับโหมดสายเดียว",["Cash reserve"]="เงินที่ต้องเหลือหลังอัปเกรด",["Upgrade status"]="สถานะอัปเกรด",["Auto use equipped unlocked tool"]="เลือกและใช้เครื่องมืออัตโนมัติ",["Auto selection"]="เหตุผลที่เลือกเครื่องมือนี้",["Ownership"]="เครื่องมือที่ปลดล็อก",["Usage"]="วิธีใช้เครื่องมือ",["Notifications"]="แจ้งเตือนเหตุการณ์สำคัญ",["Auto buy selected tools (Cash)"]="ซื้อเครื่องมืออัตโนมัติด้วยเงินในเกม",["Purchase order"]="ลำดับซื้อเครื่องมือ",["Pitchfork > TNT > Drone > Vacuum. Buys each selected tool once when affordable. Ownership is checked after purchase."]="คราด → ระเบิด → โดรน → เครื่องดูด ซื้อเฉพาะที่เลือกและยังไม่มี เมื่อเงินพอ แล้วตรวจว่าซื้อสำเร็จจริง",["Shop Cash reserve"]="เงินที่ต้องเหลือหลังซื้อเครื่องมือ",["Scope"]="สินค้าที่ระบบซื้อได้",["Uses Cash / Coins options only. Infinite Bag has no Cash option and is excluded. Purchases may apply only to this round."]="ใช้เฉพาะเงินในเกม ไม่ซื้อด้วยโรบัค บางสินค้าใช้ได้เฉพาะรอบนี้ ถุงไม่จำกัดไม่มีราคาเงินในเกมจึงไม่อยู่ในรายการ",["Shop status"]="สถานะร้านค้า",["Collect gems before hay"]="เก็บเพชรก่อนฟาง",["Rare hay before normal hay"]="เก็บฟางหายากก่อนฟางธรรมดา",["Hay priority (within reach)"]="ลำดับชนิดฟางภายในระยะ",["Event-only types have no normal spawn probability and are listed first."]="ชนิดพิเศษจากกิจกรรมไม่มีโอกาสเกิดปกติ จึงอยู่ต้นรายการ",["Auto replay after round ends"]="เล่นใหม่อัตโนมัติเมื่อจบรอบ",["Replay status"]="สถานะเล่นใหม่",["Behavior"]="ขั้นตอนเล่นใหม่",["Votes REPLAY after the ending screen appears. Other players may also need to vote. Reloads the helper after teleport when executor file storage and teleport queue are available."]="รอหน้าจบรอบแล้วโหวตเล่นใหม่ หากมีผู้เล่นอื่นต้องรอโหวตตามเกม จะโหลดผู้ช่วยต่อเมื่อย้ายเซิร์ฟเวอร์หากเครื่องมือรันสคริปต์รองรับ",["Auto complete round objective"]="ทำเป้าหมายด่านอัตโนมัติ",["Round search progress"]="ความคืบหน้าค้นหาเข็ม",["Objective status"]="ขั้นตอนเป้าหมายปัจจุบัน",["Sequence"]="ขั้นตอนการผ่านด่าน",["Farm hay > collect revealed needle > equip needle > move to farmer > hand in > wait for round completion > Auto Replay. Uses temporary character movement. Does not reveal hidden server targets."]="ด่านบ้าน: เก็บฟาง → เก็บเข็มที่เปิดเผย → ถือเข็ม → ไปส่งชาวนา → รอเกมยืนยันจบรอบ → เล่นใหม่ ระบบย้ายตัวละครเพื่อทำงาน และไม่เปิดเผยเป้าหมายที่เกมยังซ่อนอยู่",["Vacuum diagnostics"]="สถานะเครื่องดูด",["360 + Tools"]="การเก็บรอบตัวร่วมกับเครื่องมือ",["360 mode supports unlocked tools. Pitchfork selects nearby hay without your aim. Vacuum and TNT aim automatically; the camera can turn. Tool range and heat still apply."]="โหมดรอบตัวเลือกเป้าหมายให้คราด เครื่องดูด และระเบิด โดยไม่ต้องเล็งเอง กล้องอาจหมุนตามเป้าหมาย และยังใช้ระยะ ความร้อน และเวลารอของเกม",["BASEMENT support"]="ขั้นตอนด่านชั้นใต้ดิน",["Levers > Color count > Rotate picture > Read posters and enter code > Find key > Trapdoor escape. Each action waits for server confirmation."]="คันโยก → นับสี → หมุนภาพ → อ่านกระดาษและใส่รหัส → หากุญแจ → เปิดทางออก แต่ละขั้นรอเกมยืนยันผล",["Anti-AFK (idle disconnect)"]="ป้องกันหลุดเพราะไม่มีการกด",["Anti-AFK status"]="สถานะป้องกันหลุด",["Disconnect protection"]="ข้อจำกัดการป้องกันหลุด",["Sends a brief right mouse input every 2 minutes and when Roblox signals idle. Does not prevent network loss or server removal. A disconnected game must reconnect first."]="ส่งอินพุตสั้น ๆ ทุกสองนาทีและเมื่อเกมแจ้งว่าไม่มีการกด ช่วยป้องกันหลุดจากการอยู่เฉย ไม่ป้องกันเน็ตหลุดหรือการเตะโดยเซิร์ฟเวอร์",["Auto skip game cutscenes"]="ข้ามคัตซีนอัตโนมัติ",["Skip delay (seconds)"]="รอก่อนกดข้าม (วินาที)",["Auto Skip status"]="สถานะข้ามคัตซีน",["Supported Skip controls"]="ฉากที่ข้ามได้",["Uses the game SkipCutsceneButton control shared by intro/end scenes and compatible puzzle cutscenes. Scenes without a game Skip button are left to finish normally. Does not change round completion or puzzle flags."]="กดเฉพาะปุ่มข้ามที่เกมมีในฉากเริ่ม ฉากจบ และฉากปริศนาที่รองรับ หากไม่มีปุ่มจะรอฉากจบ ไม่แก้สถานะปริศนาหรือบังคับจบรอบ",["Starting..."]="กำลังเริ่มทำงาน…",["Waiting..."]="กำลังรอ…",["Checking..."]="กำลังตรวจสอบ…",["Waiting for round end"]="รอจบรอบ",["Waiting for revealed needle"]="รอเกมเปิดเผยเข็ม",["Waiting for a game Skip button"]="รอปุ่มข้ามของเกม",["Waiting for a visible game Skip button"]="รอปุ่มข้ามปรากฏบนจอ",["Game Skip control acknowledged"]="ปุ่มข้ามตอบรับแล้ว",["Skip requested; waiting for game UI"]="กดข้ามแล้ว กำลังรอฉากเปลี่ยน",["Skip input failed:"]="กดข้ามไม่สำเร็จ:",["Waiting for vacuum"]="รอเครื่องดูด",["Checking hay remaining..."]="กำลังตรวจฟางที่เหลือ…",["Searching for revealed needle"]="ค้นหาเข็มที่เกมเปิดเผยแล้ว",["Auto buy disabled"]="ปิดการซื้ออัตโนมัติ",["Purchase not confirmed; auto buy paused"]="เกมยังไม่ยืนยันการซื้อ พักระบบซื้อแล้ว",["Paused: game input locked"]="พักชั่วคราวระหว่างเกมล็อกการควบคุม",["Waiting for current upgrade confirmation"]="รอเกมยืนยันอัปเกรดรายการปัจจุบัน",["Shop error; paused"]="ร้านค้าเกิดข้อผิดพลาด พักการซื้อแล้ว",["Waiting: selected tracks are locked, maxed, or need more Cash."]="รอเงินเพิ่ม หรือสายที่เลือกยังล็อก/อัปเต็มแล้ว",["Tool not unlocked"]="ยังไม่ปลดล็อกเครื่องมือนี้",["Maximum level"]="อัปเกรดเต็มแล้ว",["Next in sequence:"]="รายการถัดไป:",["Holding tool until action completes"]="ถือเครื่องมือนี้รอให้เริ่มทำงานก่อนสลับ",["Hand: collecting hay"]="ใช้มือเก็บฟาง",["Hand: gem priority"]="ใช้มือระหว่างเก็บเพชรก่อน",["Hand: bag full / sell"]="กระเป๋าเต็ม เตรียมขาย",["Drone: deploy then continue gathering"]="ปล่อยโดรนแล้วเก็บฟางต่อ",["Vacuum: using until cooling or no harvest"]="ใช้เครื่องดูดจนร้อนหรือไม่มีผลการเก็บ",["TNT: ready while vacuum unavailable"]="ใช้ระเบิดระหว่างพักเครื่องดูด",["Pitchfork: vacuum retry in "]="ใช้คราด ลองเครื่องดูดใหม่ใน ",["Pitchfork: vacuum cooling"]="ใช้คราดระหว่างเครื่องดูดลดความร้อน",["Pitchfork: waiting for dig cooldown"]="ถือคราดรอเวลาขุดครั้งถัดไป",["Pitchfork: ready; holding selected tool"]="คราดพร้อมใช้งาน ถือรอเป้าหมาย",["Drone > Vacuum > TNT during vacuum downtime > Pitchfork > Hand. Holds pitchfork through cooldown instead of switching to hand."]="เลือกโดรน → เครื่องดูด → ระเบิดเมื่อเครื่องดูดพัก → คราด → มือ และถือคราดรอเวลาขุดแทนสลับกลับมือ",["Equip pitchfork and aim at hay, vacuum, or drone. Locked tools are skipped. TNT lights and throws while aiming at hay; observes game cooldown."]="เลือกเครื่องมือที่ปลดล็อกให้เอง พร้อมขยับเข้าใกล้เป้าหมาย คราด เครื่องดูด และระเบิดใช้เวลารอตามเกม โหมดรอบตัวช่วยเล็งให้อัตโนมัติ",["No confirmed harvest; using hand/pitchfork for 8 seconds"]="ยังไม่พบผลการดูด ใช้มือหรือคราดแทนแปดวินาที",["Vacuum cooling; using another tool"]="เครื่องดูดกำลังลดความร้อน ใช้เครื่องมืออื่นก่อน",["Vacuum paused: no confirmed harvest. Retry in "]="พักเครื่องดูดเพราะยังเก็บไม่ได้ ลองใหม่ใน ",["Idle-prevention input sent successfully"]="ส่งอินพุตป้องกันหลุดสำเร็จ",["Executor rejected idle-prevention input; protection unverified"]="เครื่องมือรันสคริปต์ไม่รับอินพุต จึงยังยืนยันการป้องกันหลุดไม่ได้",["Enabled; waiting for first input check"]="เปิดแล้ว รอตรวจการส่งอินพุตครั้งแรก",["Replay vote supported; automatic helper reload unavailable"]="โหวตเล่นใหม่ได้ แต่เครื่องมือยังไม่รองรับโหลดผู้ช่วยต่ออัตโนมัติ",["Game is launching the next round"]="เกมกำลังเปิดรอบใหม่",["Round ended; waiting for replay screen"]="จบรอบแล้ว รอหน้าจอโหวตเล่นใหม่",["Replay vote confirmed:"]="ยืนยันโหวตเล่นใหม่แล้ว:",["Replay vote sent; waiting for confirmation"]="ส่งโหวตเล่นใหม่แล้ว รอเกมยืนยัน",["Vote unconfirmed after 3 attempts; use the game replay button"]="ลองสามครั้งแล้วยังไม่ยืนยัน กรุณาใช้ปุ่มเล่นใหม่ของเกม",["Round completed; waiting for Auto Replay"]="ผ่านด่านแล้ว รอระบบเล่นใหม่",["Another player has the objective; waiting for round end"]="ผู้เล่นอื่นถือเป้าหมายอยู่ รอจบรอบ",["Delivering needle"]="นำเข็มไปส่งชาวนา",["Waiting for completion cutscene"]="รอฉากจบด่าน",["Collecting revealed needle"]="กำลังเก็บเข็มที่ปรากฏ",["Searching: farming until needle is revealed"]="เก็บฟางต่อเพื่อค้นหาเข็ม",["No progress: searching a different part of the pile"]="ความคืบหน้าไม่เพิ่ม เปลี่ยนจุดค้นหา",["Moving closer to remaining hay"]="ขยับเข้าใกล้ฟางที่เหลือ",["Pulling three levers"]="ดึงคันโยกทั้งสามตัว",["Counting visible colored gems"]="นับและตั้งจำนวนชิ้นสีที่มองเห็น",["Rotating picture tiles upright"]="หมุนชิ้นภาพให้ถูกทิศ",["Entering discovered keypad code"]="กรอกรหัสที่ค้นพบ",["Searching numbered posters for the code"]="ค้นหารหัสจากกระดาษ",["Waiting for release sequence"]="รอฉากเปิดทางออก",["Puzzles solved; searching for key"]="ปริศนาครบแล้ว กำลังหากุญแจ",["Taking key to trapdoor"]="นำกุญแจไปเปิดทางออก",["BASEMENT:"]="ชั้นใต้ดิน:",["Requested:"]="กดข้ามแล้ว:",["acknowledged:"]="ปุ่มตอบรับแล้ว:",["Hay removed:"]="เก็บฟางแล้ว:",["remaining:"]="เหลือ:",["Needle:"]="เข็ม:",["no progress for"]="ความคืบหน้าไม่เพิ่มนาน",["not revealed by server"]="เกมยังไม่เปิดเผย",["revealed"]="เปิดเผยแล้ว",["State:"]="สถานะ:",["heat"]="ความร้อน",["Target:"]="เป้าหมาย:",["confirmed hay:"]="ยืนยันฟางที่ดูดได้:",["none nearby"]="ไม่มีในระยะ",["studs"]="หน่วย",["Cash:"]="เงินในเกม:",["Shop reserve:"]="เงินสำรองร้านค้า:",["Bag:"]="กระเป๋า:",["Needle target highlighted"]="แสดงไฮไลต์เข็มแล้ว",["ESP disabled"]="ปิดไฮไลต์แล้ว",["Collecting gem first"]="กำลังเก็บเพชรก่อนฟาง",["Finishing TNT sequence"]="รอจุดชนวนและโยนระเบิดให้เสร็จ",["Sell point unavailable"]="ยังไม่พบจุดขาย",["Selling..."]="กำลังขาย…",["Sold; returned"]="ขายแล้วและกลับจุดเดิม",["Sale not confirmed"]="ยังไม่ยืนยันการขาย",["Bag full"]="กระเป๋าเต็ม",["Picking nearby hay"]="กำลังเก็บฟางใกล้ตัว",["Move closer to hay"]="ต้องขยับเข้าใกล้ฟาง",["360 pickup:"]="เก็บรอบตัว:",["Picking "]="กำลังเก็บ ",["Unlocked"]="ปลดล็อกแล้ว",["Locked"]="ยังล็อก",["Owned"]="มีแล้ว",["Buying "]="กำลังซื้อ ",["needs $"]="ต้องการเงินเพิ่ม $",[" more"]="",["next $"]="ขั้นถัดไป $",["reserve $"]="เงินสำรอง $",["Waiting for Cash, or selected tools already owned"]="รอเงินเพิ่ม หรือมีสินค้าที่เลือกครบแล้ว",["Ready"]="พร้อม",["idle"]="พร้อม",["ready"]="พร้อมใช้",["lighting"]="กำลังจุดชนวน",["charging"]="กำลังเตรียมโยน",["spent"]="รอใช้ครั้งถัดไป",["Suction"]="กำลังดูด",["Overheated"]="ร้อนเกินไป กำลังพัก",["Normal"]="ธรรมดา",["Void"]="วอยด์",["Rainbow"]="สายรุ้ง",["Electric"]="ไฟฟ้า",["Gold"]="ทอง",["Burnt"]="ไหม้",["Glass"]="แก้ว",["Muddy"]="โคลน",["Grassy"]="หญ้า",["Damp"]="ชื้น",["Acid"]="กรด",["Pitchfork"]="คราด",["Vacuum"]="เครื่องดูด",["Drone"]="โดรน",["Tnt"]="ระเบิด",["TNT"]="ระเบิด",["Hand"]="มือ",["/min"]="/นาที",[" paused"]=" พักแล้ว",["; paused"]="; พักแล้ว"},["values"]={["Tools (normal)"]="ใช้เครื่องมือปกติ",["360 pickup (no aim)"]="เก็บรอบตัว ไม่ต้องเล็ง",["All tracks in order"]="ทุกสายตามลำดับ",["Single track"]="อัปเฉพาะสายที่เลือก",["Speed"]="ความเร็วเก็บด้วยมือ",["Grab"]="จำนวนฟางต่อการคว้า",["Capacity"]="ความจุกระเป๋า",["HandHold"]="กดค้างเก็บฟาง",["Pitchfork"]="พลังขุดของคราด",["PitchforkCooldown"]="เวลารอคราด",["PitchforkHold"]="กดค้างใช้คราด",["VacuumPower"]="พลังเครื่องดูด",["VacuumRuntime"]="ระยะเวลาที่ดูดได้",["VacuumCooling"]="เวลาพักเครื่องดูด",["DroneGrab"]="จำนวนฟางต่อรอบโดรน",["DroneSpeed"]="ความเร็วโดรน",["DroneCapacity"]="ความจุโดรน",["TntPower"]="พลังระเบิด",["TntCooldown"]="เวลารอระเบิด",["TntLuck"]="โอกาสระเบิดพิเศษ",["Value"]="มูลค่าฟาง"},["descriptions"]={["Sell bag now and return"]="สั่งขายฟางที่ถืออยู่ทันที ไม่ต้องรอเต็ม แล้วกลับตำแหน่งเดิม",["Pause all automation"]="หยุดเก็บ ขาย ซื้อ อัปเกรด เป้าหมาย และเล่นใหม่ การป้องกันหลุดกับข้ามฉากยังแยกเปิดปิดได้",["Unload helper"]="หยุดผู้ช่วยทั้งหมด ล้างตัวตรวจและปุ่มไอคอน หากต้องการใช้อีกให้รันสคริปต์ใหม่",["Reset launcher position"]="ย้ายไอคอนรูป iNo กลับมุมขวาบนเมื่อลากไปตำแหน่งที่ไม่สะดวก",["Select all tracks"]="เลือกสายอัปเกรดทุกสาย โดยยังข้ามสายที่ล็อกหรืออัปเต็มแล้ว",["NH_CollectMode"]="โหมดปกติใช้เครื่องมือตามที่ถือ โหมดรอบตัวค้นเป้าหมายให้และอาจขยับตัวละครหรือหมุนกล้อง",["NH_Auto"]="เก็บฟางที่โหลดอยู่ในระยะ หากเปิดเครื่องมืออัตโนมัติจะเลือกเครื่องมือที่มีให้ด้วย",["NH_Radius"]="ระยะค้นหาเป้าหมายรอบตัว ไม่ได้เพิ่มระยะที่เซิร์ฟเวอร์อนุญาตให้เครื่องมือเก็บได้",["NH_Threshold"]="ตั้ง 100 เพื่อขายเมื่อเต็ม หรือลดค่านี้เพื่อขายบ่อยขึ้น",["NH_ESP"]="ไฮไลต์เฉพาะเข็มที่เกมเปิดเผยแล้ว ไม่ทำให้พบเข็มก่อนเงื่อนไขเกม",["NH_Color"]="เปลี่ยนสีที่ใช้เน้นตำแหน่งเข็ม",["NH_Gems"]="เก็บเฉพาะเพชรที่ปรากฏจริงและอยู่ในระยะ ไม่สร้างเพชรเพิ่ม",["NH_GemESP"]="แสดงชื่อและระยะของเพชรที่โหลดอยู่",["NH_GemRadius"]="เก็บได้ไม่เกินระยะสูงสุดที่เกมกำหนด",["NH_GemPriority"]="พักเก็บฟางเมื่อมีเพชรในระยะ หากเก็บไม่สำเร็จจะพักลองชั่วคราวแล้วทำฟางต่อ",["NH_RareFirst"]="เลือกฟางหายากก่อนจากเป้าหมายในระยะ หากไม่พบจะเก็บชนิดธรรมดาต่อ",["NH_Upgrade"]="ใช้เงินจริงในรอบเกมตามสายที่เลือก โดยเหลือเงินสำรองและรอเกมยืนยันทุกครั้ง ไม่ใช้โรบัค",["NH_UpgradeMode"]="ทุกสาย: อัปทีละขั้นแล้ววนรอบ สายเดียว: ซื้อเฉพาะสายที่เลือกด้านล่าง",["NH_Track"]="มีผลเฉพาะเมื่อเลือกรูปแบบอัปเฉพาะสายที่เลือก",["NH_Reserve"]="ตัวอย่าง ตั้ง 10 จะไม่อัปเกรดหากซื้อแล้วเงินเหลือต่ำกว่า 10",["NH_Tools"]="เลือกโดรน เครื่องดูด ระเบิด คราด หรือมือ ตามความพร้อม ถือรอให้ทำงานก่อนสลับ และพักเมื่อขายหรือทำเป้าหมาย",["NH_Notify"]="แสดงข้อความเมื่อมีเหตุการณ์สำคัญ เช่น กระเป๋าเต็ม ซื้อสำเร็จ หรือระบบต้องหยุด",["NH_Shop"]="ซื้อเฉพาะรายการที่เลือกและยังไม่มีเมื่อเงินพอ ให้การซื้อเครื่องมือมาก่อนเริ่มอัปเกรดรายการใหม่",["NH_ShopReserve"]="เงินสำรองเฉพาะร้านค้า แยกจากเงินสำรองอัปเกรด",["NH_Replay"]="รอจบรอบแล้วโหวตเล่นใหม่ตามระบบเกม อาจต้องรอผู้เล่นอื่นโหวตด้วย",["NH_Objective"]="เก็บฟางและทำเป้าหมายตามด่าน รองรับบ้าน ชั้นใต้ดิน และฟาร์มปศุสัตว์ รอผลจากเกมก่อนเปลี่ยนขั้นตอน หากทำซ้ำไม่สำเร็จจะหยุดให้ตรวจสอบ",["NH_AntiAFK"]="ส่งอินพุตทุกสองนาทีเพื่อป้องกันการหลุดจากการไม่มีการกด ต้องให้เครื่องมือรันสคริปต์รองรับ",["NH_AutoSkip"]="กดเฉพาะปุ่มข้ามที่เกมแสดง ไม่บังคับผ่านฉากที่เกมไม่อนุญาต",["NH_SkipDelay"]="เวลารอหลังปุ่มข้ามปรากฏก่อนกด ช่วยให้ปุ่มพร้อมทำงาน"}}
local attachDashboard=(function()
-- UI reads confirmed game data and delegates controls to existing helper options.
return function(library,window,state,remotes,player,savedOptions)
    local ctx=window.Context
    local C,make,label=ctx.Colors,ctx.Make,ctx.Label
    local overview=window.Overview
    -- Dashboard metrics remain visible; each column owns its own scroll position.
    local oldLayout=overview.Content:FindFirstChildOfClass('UIListLayout')
    if oldLayout then oldLayout:Destroy() end
    overview.Page.AutomaticCanvasSize=Enum.AutomaticSize.None
    overview.Page.CanvasSize=UDim2.new()
    overview.Page.CanvasPosition=Vector2.new(0,0)
    overview.Page.ScrollingEnabled=false
    overview.Content.AutomaticSize=Enum.AutomaticSize.None
    overview.Content.Size=UDim2.new(1,-7,1,0)
    local function translate(value) return library.Translate and library.Translate(tostring(value or '')) or tostring(value or '') end
    local function number(value) return tonumber(value) end
    local function text(target,value) if target.Text~=value then target.Text=value end end
    local function card(parent,title)
        local frame=make('Frame',{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.Card},parent)
        ctx.Round(frame,9);ctx.Stroke(frame,C.Line);ctx.Padding(frame,14);ctx.List(frame,9)
        if title then local heading=label(frame,title,17,C.Text);heading.Font=Enum.Font.GothamBold end
        return frame
    end
    local metrics=make('Frame',{Name='ConfirmedMetrics',Size=UDim2.new(1,0,0,68),BackgroundTransparency=1,LayoutOrder=1},overview.Content)
    local values,metricTitles,metricIcons={},{},{}
    for index,item in ipairs({{'เงินสด','฿',Color3.fromRGB(158,219,96)},{'เพชร','◇',Color3.fromRGB(70,198,242)},{'กระเป๋า','▣',Color3.fromRGB(242,200,83)}}) do
        local frame=make('Frame',{Size=UDim2.new(1/3,-7,1,0),Position=UDim2.new((index-1)/3,(index-1)*3,0,0),BackgroundColor3=C.Card},metrics)
        ctx.Round(frame,9);ctx.Stroke(frame,C.Line)
        local icon=label(frame,item[2],25,item[3]);icon.Position=UDim2.fromOffset(12,23);icon.Size=UDim2.fromOffset(26,32)
        local title=label(frame,item[1],11,C.Muted);title.Position=UDim2.fromOffset(44,7);title.Size=UDim2.new(1,-50,0,20)
        local value=label(frame,'—',18,C.Text);value.Position=UDim2.fromOffset(44,30);value.Size=UDim2.new(1,-50,0,28);value.Font=Enum.Font.GothamBold
        values[index]=value
        metricTitles[index]=title;metricIcons[index]=icon
    end
    local segments=make('Frame',{Name='DashboardSections',Position=UDim2.fromOffset(0,74),Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Visible=false},overview.Content)
    local columns=make('Frame',{Name='DashboardColumns',Position=UDim2.fromOffset(0,80),Size=UDim2.new(1,0,1,-80),BackgroundTransparency=1},overview.Content)
    local function column(name)
        local scroll=make('ScrollingFrame',{Name=name..'Scroll',Size=UDim2.new(0.5,-7,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.Line,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},columns)
        local content=make('Frame',{Name=name,Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},scroll)
        return scroll,content
    end
    local leftScroll,left=column('Automation')
    ctx.List(left,10)
    local rightScroll,right=column('ObjectiveAndCombat')
    rightScroll.Position=UDim2.new(0.5,7,0,0)
    ctx.List(right,11)
    local leftTab={Content=left,Rows={}}
    local methods=window.ControlMethods
    local controlsHeading=label(left,'เก็บฟางอัตโนมัติ',17,C.Text)
    controlsHeading.Size=UDim2.new(1,0,0,28);controlsHeading.Font=Enum.Font.GothamBold
    local function linkToggle(key,title,description)
        local original=library.Options[key]
        if not original then return end
        local syncing=false
        local mirror=methods.AddToggle(leftTab,nil,{Title=title,Description=description,Compact=true,Default=original.Value,Callback=function(value)
            if not syncing then original:SetValue(value) end
        end})
        original:OnChanged(function(value) syncing=true;mirror:SetValue(value);syncing=false end)
    end
    linkToggle('NH_Auto','เก็บฟาง','เก็บเป้าหมายในระยะ')
    linkToggle('NH_Gems','เก็บเพชรอัตโนมัติ','เก็บเพชรที่ปรากฏแล้ว')
    linkToggle('NH_GemPriority','เก็บเพชรก่อน','พักฟางเพื่อเก็บเพชรในระยะ')
    linkToggle('NH_Sell','ขายเมื่อกระเป๋าเต็ม','ขายแล้วกลับจุดเดิม')
    linkToggle('NH_Tools','ใช้เครื่องมืออัตโนมัติ','เลือกเครื่องมือที่พร้อม')
    local radius=library.Options.NH_Radius
    if radius then
        local syncing=false
        local mirror=methods.AddSlider(leftTab,nil,{Title='ระยะค้นหา',Min=3,Max=25,Rounding=0,Default=radius.Value,Callback=function(value) if not syncing then radius:SetValue(value) end end})
        radius:OnChanged(function(value) syncing=true;mirror:SetValue(value);syncing=false end)
    end
    local priority=methods.AddParagraph(leftTab,{Title='ลำดับการเก็บ',Content='กำลังอ่านการตั้งค่า'})
    local goals=card(right,'◎  เป้าหมายด่าน')
    local objectiveState=label(goals,'กำลังอ่านข้อมูลจากเกม',12,C.Muted)
    objectiveState.Size=UDim2.new(1,0,0,0);objectiveState.AutomaticSize=Enum.AutomaticSize.Y;objectiveState.TextWrapped=true
    local checklist={}
    for index,title in ipairs({'ชิ้นส่วน UFO','ซ่อมยาน','กำจัดบอส','เก็บกุญแจ','ขับรถออก'}) do
        local row=make('Frame',{Size=UDim2.new(1,0,0,29),BackgroundTransparency=1},goals)
        local titleLabel=label(row,'○  '..title,13,C.Muted);titleLabel.Size=UDim2.new(1,-70,1,0)
        local result=label(row,'รอข้อมูล',11,C.Muted);result.Position=UDim2.new(1,-75,0,0);result.Size=UDim2.fromOffset(75,29);result.TextXAlignment=Enum.TextXAlignment.Right
        checklist[index]={Frame=row,Title=titleLabel,Result=result,Name=title}
    end
    local fight=card(right,'⚔  สถานะการต่อสู้')
    local health=label(fight,'รอข้อมูลบอส',15,C.Text)
    local rail=make('Frame',{Size=UDim2.new(1,0,0,8),BackgroundColor3=C.Inactive},fight);ctx.Round(rail,4)
    local bar=make('Frame',{Size=UDim2.fromScale(0,1),BackgroundColor3=C.Red},rail);ctx.Round(bar,4)
    local combat=label(fight,'ยังไม่มีการสั่งโจมตี',12,C.Muted);combat.Size=UDim2.new(1,0,0,0);combat.AutomaticSize=Enum.AutomaticSize.Y;combat.TextWrapped=true
    local attacks=label(fight,'สั่งโจมตี — ครั้ง • เลือดลด —',11,C.Muted);attacks.Size=UDim2.new(1,0,0,0);attacks.AutomaticSize=Enum.AutomaticSize.Y;attacks.TextWrapped=true
    local general=card(right,'สถานะการทำงาน')
    local generalStatus=label(general,'กำลังอ่านข้อมูลเกม',13,C.Muted)
    generalStatus.Size=UDim2.new(1,0,0,0);generalStatus.AutomaticSize=Enum.AutomaticSize.Y;generalStatus.TextWrapped=true
    local function shortcut(title,tabName)
        local button=make('TextButton',{Text=title,Size=UDim2.new(1,0,0,40),BackgroundColor3=C.Input,TextColor3=C.Text,Font=Enum.Font.Gotham,TextSize=13},general)
        ctx.Round(button,6)
        ctx.Bind(button.Activated,function() for _,tab in ipairs(window.Tabs) do if tab.Title==tabName then window:SelectTab(tab);break end end end)
    end
    shortcut('ตั้งค่าเป้าหมายด่าน  ›','เป้าหมายด่าน')
    shortcut('ดูสถานะเครื่องมือ  ›','เครื่องมือ')
    window.OnPause=function()
        if state.pauseAll then state.pauseAll();library:Notify({Title='พักทั้งหมดแล้ว',Content='เปิดฟังก์ชันที่ต้องการอีกครั้งจากเมนู',Duration=3}) end
    end
    window:AddFooterButton({Title='Ⅱ  พักทั้งหมด',Color=Color3.fromRGB(126,43,44),Callback=function() window.OnPause() end})
    window.OnClose=function() state.stop() end
    window.OnPositionChanged=function(position) state.windowPosition=position end
    local section='controls'
    local sectionButtons={}
    for index,item in ipairs({{'controls','การเก็บและเครื่องมือ'},{'objective','เป้าหมายและสถานะ'}}) do
        local button=make('TextButton',{Text=item[2],Size=UDim2.new(0.5,-4,1,0),Position=UDim2.new((index-1)*0.5,(index-1)*4,0,0),BackgroundColor3=index==1 and C.Selected or C.Card,TextColor3=index==1 and C.Lime or C.Muted,TextSize=12,Font=Enum.Font.Gotham},segments)
        ctx.Round(button,6);sectionButtons[item[1]]=button
    end
    local function reflow(width)
        local narrow=width<460
        local short=window.Height<380
        metrics.Visible=not short
        segments.Visible=narrow
        segments.Position=UDim2.fromOffset(0,short and 0 or 74)
        local top=short and (narrow and 40 or 0) or (narrow and 114 or 80)
        columns.Position=UDim2.fromOffset(0,top)
        columns.Size=UDim2.new(1,0,1,-top)
        if narrow then
            leftScroll.Size=UDim2.fromScale(1,1);rightScroll.Size=UDim2.fromScale(1,1)
            rightScroll.Position=UDim2.fromOffset(0,0)
            leftScroll.Visible=section=='controls';rightScroll.Visible=section=='objective'
        else
            leftScroll.Size=UDim2.new(0.5,-7,1,0);rightScroll.Size=UDim2.new(0.5,-7,1,0);rightScroll.Position=UDim2.new(0.5,7,0,0)
            leftScroll.Visible=true;rightScroll.Visible=true
        end
        for index,value in ipairs(values) do
            value.TextSize=narrow and 14 or 18
            value.Position=UDim2.fromOffset(narrow and 8 or 44,30);value.Size=UDim2.new(1,narrow and -16 or -50,0,28)
            metricTitles[index].Position=UDim2.fromOffset(narrow and 8 or 44,7)
            metricTitles[index].Size=UDim2.new(1,narrow and -16 or -50,0,20)
            metricIcons[index].Visible=not narrow
        end
    end
    window.OnResize=reflow
    for name,button in pairs(sectionButtons) do
        ctx.Bind(button.Activated,function()
            section=name
            for other,entry in pairs(sectionButtons) do entry.BackgroundColor3=other==name and C.Selected or C.Card;entry.TextColor3=other==name and C.Lime or C.Muted end
            window:Resize()
        end)
    end
    local zoom=savedOptions.__uiLayout==2 and tonumber(savedOptions.NH_UIScale) or 1
    state.uiLayoutVersion=2
    for _,tab in ipairs(window.Tabs) do
        if tab.Title=='ตั้งค่า' then
            tab:AddSlider('NH_UIScale',{Title='ขนาดเมนูและตัวอักษร',Description='เริ่มต้นที่ 100% ใช้ค่าต่ำลงเพื่อเห็นรายการมากขึ้น พื้นที่เลื่อนซ้ายและขวาแยกกัน',Min=0.8,Max=1.5,Rounding=2,Default=zoom or 1,Callback=function(value) window:SetZoom(value) end})
            tab:AddButton({Title='คืนขนาดตัวอักษรเริ่มต้น',Callback=function() library.Options.NH_UIScale:SetValue(1) end})
            tab:AddButton({Title='จัดหน้าต่างกลับกลางจอ',Callback=function() window:ResetPosition() end})
            break
        end
    end
    window:Resize()
    local position=savedOptions.__uiLayout==2 and (state.windowPosition or savedOptions.__window) or nil
    if type(position)=='table' and tonumber(position.x) and tonumber(position.y) then
        local viewport=workspace.CurrentCamera.ViewportSize
        window:SetPosition(Vector2.new(position.x*viewport.X,position.y*viewport.Y))
        state.windowPosition={x=window.Root.Position.X.Offset/viewport.X,y=window.Root.Position.Y.Offset/viewport.Y}
    else window:ResetPosition() end
    local function tick()
        local stats=player:FindFirstChild('leaderstats')
        local cash=stats and stats:FindFirstChild('Cash')
        text(values[1],cash and string.format('$%.2f',cash.Value) or '—')
        text(values[2],tostring(player:GetAttribute('Gems') or '—'))
        local held,capacity=player:GetAttribute('HayHeld'),player:GetAttribute('HayCapacity')
        text(values[3],held~=nil and capacity~=nil and (tostring(held)..' / '..tostring(capacity)) or '—')
        local map=remotes:GetAttribute('Map')
        text(window.SubTitleLabel,tostring(map or 'รอข้อมูล'))
        local phase=state.objectiveStatus and translate(state.objectiveStatus()) or 'รอข้อมูลเป้าหมาย'
        text(objectiveState,phase)
        local complete=player:GetAttribute('NeedleRoundComplete')==true
        text(generalStatus,complete and 'เกมยืนยันจบรอบแล้ว' or state.objectiveBusy and 'กำลังทำเป้าหมาย ระบบเก็บฟางพักชั่วคราว' or state.auto and 'กำลังเก็บฟางในระยะ' or 'ระบบเก็บฟางพักอยู่')
        general.Visible=map~='RANCH'
        local ranch=state.ranch
        for _,item in ipairs(checklist) do item.Frame.Visible=map=='RANCH' end
        if map=='RANCH' then
            local ufo=workspace:FindFirstChild('UfoSplitted')
            local boss=workspace:FindFirstChild('HayGolem_Rig')
            local finish=game:GetService('ReplicatedStorage'):FindFirstChild('TruckFinish')
            local returned=ufo and number(ufo:GetAttribute('PartsReturned'))
            local total=ufo and number(ufo:GetAttribute('PartsTotal'))
            local repaired=ufo and ufo:GetAttribute('Repaired')==true
            local defeated=boss and boss:GetAttribute('BossState')=='Defeated' or finish and finish:GetAttribute('BossDefeated')==true
            local finished=player:GetAttribute('NeedleRoundComplete')==true or finish and finish:GetAttribute('Finished')==true
            local completed={returned~=nil and total~=nil and returned>=total,repaired,defeated,player:GetAttribute('HasCarKey')==true,finished}
            for index,item in ipairs(checklist) do
                local done=completed[index]
                text(item.Title,(done and '✓  ' or '○  ')..item.Name);item.Title.TextColor3=done and C.Lime or C.Muted
                text(item.Result,index==1 and returned~=nil and total~=nil and (returned..'/'..total) or done and 'สำเร็จ' or 'รอ')
                item.Result.TextColor3=done and C.Lime or C.Muted
            end
            local hp=boss and number(boss:GetAttribute('BossHealth'))
            local maximum=boss and (number(boss:GetAttribute('BossMaxHealth')) or number(boss:GetAttribute('MaxHealth')))
            text(health,hp and (maximum and string.format('HP %d / %d',hp,maximum) or string.format('HP %d',hp)) or 'ยังไม่มีข้อมูลเลือดบอส')
            rail.Visible=hp~=nil and maximum~=nil and maximum>0
            if rail.Visible then bar.Size=UDim2.fromScale(math.clamp(hp/maximum,0,1),1) end
            text(combat,ranch and translate(ranch.attackReason or 'รอขั้นตอนต่อสู้') or 'รอเริ่มต่อสู้')
            text(attacks,ranch and string.format('สั่งโจมตี %d ครั้ง • ยืนยันเลือดลด %d ครั้ง\nความเสียหายรวม %d',ranch.attackRequests or 0,ranch.damageEvents or 0,ranch.damageTotal or 0) or 'ยังไม่มีข้อมูลการโจมตี')
        end
        fight.Visible=map=='RANCH'
        local options=library.Options
        local order={}
        if options.NH_Gems and options.NH_Gems.Value and options.NH_GemPriority and options.NH_GemPriority.Value then table.insert(order,'เพชร') end
        if options.NH_MissingIndex and options.NH_MissingIndex.Value then table.insert(order,'ดัชนีที่ยังขาด') end
        if options.NH_RareFirst and options.NH_RareFirst.Value then table.insert(order,'ฟางหายาก') end
        table.insert(order,'ฟางธรรมดา');priority:SetDesc(table.concat(order,' → '))
        local fault=state.objectiveFault or state.extrasFault or state.shopFault or state.replayFault
        window:SetStatus(fault and 'มีระบบหยุด ตรวจเมนูตั้งค่า' or state.objectiveBusy and 'กำลังทำเป้าหมาย' or state.auto and 'กำลังเก็บฟาง' or 'พร้อมทำงาน',fault~=nil and fault~=false)
    end
    state.uiDashboardUpdate=tick
    task.spawn(function()
        while state.alive and not library.Unloaded do
            local ok,err=pcall(tick)
            if not ok then state.diagnostics.uiError=tostring(err);window:SetStatus('แสดงข้อมูลไม่ครบ',true)
            else state.diagnostics.uiError=nil end
            task.wait(0.6)
        end
    end)
end

end)()
local NeedleUI={ApiVersion=1}
function NeedleUI:InstallThaiDisplay(library)
    if library.ThaiInstalled then return end
    installThaiDisplay(library,thaiDictionary)
    library.ThaiInstalled=true
end
function NeedleUI:AttachDashboard(library,window,state,remotes,player,savedOptions)
    return attachDashboard(library,window,state,remotes,player,savedOptions)
end
return NeedleUI
