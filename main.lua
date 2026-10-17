-- iNo Needle UI | Custom dark/lime interface
local buildControls=(function()
-- Fluent-compatible controls. The application owns every gameplay callback.
return function(ctx)
    local C, make, label, bind = ctx.Colors, ctx.Make, ctx.Label, ctx.Bind
    local library = ctx.Library
    local function copy(value) return type(value)=='table' and table.clone(value) or value end
    local function equal(a,b)
        if type(a)~='table' or type(b)~='table' then return a==b end
        for key,value in pairs(a) do if b[key]~=value then return false end end
        for key,value in pairs(b) do if a[key]~=value then return false end end
        return true
    end
    local function option(key,config,normalize,render)
        local object={Value=nil,Type=config.Type,Callbacks={}}
        function object:SetValue(value)
            value=normalize(value)
            if value==nil then return end
            local changed=not equal(self.Value,value)
            self.Value=copy(value)
            render(self.Value)
            if changed then
                if config.Callback then ctx.Call(config.Callback,copy(self.Value)) end
                for _,callback in ipairs(self.Callbacks) do ctx.Call(callback,copy(self.Value)) end
            end
        end
        function object:OnChanged(callback)
            table.insert(self.Callbacks,callback)
            ctx.Call(callback,copy(self.Value))
            return self
        end
        object:SetValue(config.Default)
        if key then library.Options[key]=object end
        return object
    end
    local function row(tab,config,reserve)
        local frame=make('Frame',{Name='Control',Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.Card},tab.Content)
        ctx.Round(frame,9);ctx.Stroke(frame,C.Line)
        ctx.Padding(frame,config.Compact and 8 or 14)
        ctx.List(frame,config.Compact and 4 or 7)
        local heading=make('Frame',{Size=UDim2.new(1,0,0,reserve and reserve>0 and 44 or 30),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=1},frame)
        local title=label(heading,config.Title or '',15,C.Text)
        title.Size=UDim2.new(1,-(reserve or 0),0,30);title.AutomaticSize=Enum.AutomaticSize.Y
        title.TextWrapped=true;title.Font=Enum.Font.GothamMedium
        local description=label(frame,config.Description or config.Content or '',12,C.Muted)
        description.Size=UDim2.new(1,0,0,0);description.AutomaticSize=Enum.AutomaticSize.Y
        description.TextWrapped=true;description.LayoutOrder=2;description.Visible=description.Text~=''
        local item={Frame=frame,Heading=heading,Title=title,Description=description}
        function item:SetDesc(value)
            self.Description.Text=tostring(value or '');self.Description.Visible=self.Description.Text~=''
        end
        function item:SetTitle(value) self.Title.Text=tostring(value or '') end
        function item:SetVisible(value) self.Frame.Visible=value==true end
        table.insert(tab.Rows,{Frame=frame,Search=string.lower((config.Title or '')..' '..(config.Description or config.Content or ''))})
        return item
    end
    local function action(parent,text,width)
        local button=make('TextButton',{Text=text,Size=UDim2.fromOffset(width or 92,30),Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),BackgroundColor3=C.Input,TextColor3=C.Text,TextSize=12,Font=Enum.Font.Gotham,AutoButtonColor=true},parent)
        ctx.Round(button,6);ctx.Stroke(button,C.Line)
        return button
    end
    local function field(parent,width)
        local input=make('TextBox',{Size=UDim2.fromOffset(width or 96,30),Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),BackgroundColor3=C.Input,TextColor3=C.Text,TextSize=13,Font=Enum.Font.Gotham,Text='',ClearTextOnFocus=false},parent)
        ctx.Round(input,6);ctx.Stroke(input,C.Line)
        return input
    end
    local methods={}
    function methods:AddParagraph(config)
        return row(self,config,0)
    end
    function methods:AddButton(config)
        local item=row(self,config,40)
        local button=action(item.Heading,'›',30)
        button.TextSize=24;button.TextColor3=C.Lime
        bind(button.Activated,function() ctx.Call(config.Callback) end)
        local hit=make('TextButton',{Text='',BackgroundTransparency=1,Size=UDim2.new(1,-45,1,0)},item.Heading)
        bind(hit.Activated,function() ctx.Call(config.Callback) end)
        return item
    end
    function methods:AddToggle(key,config)
        config.Type='Toggle'
        local item=row(self,config,68)
        local button=make('TextButton',{Text='',Size=UDim2.fromOffset(54,44),Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),BackgroundTransparency=1},item.Heading)
        local track=make('Frame',{Size=UDim2.fromOffset(54,28),Position=UDim2.fromOffset(0,8),BackgroundColor3=C.Inactive},button);ctx.Round(track,14)
        local knob=make('Frame',{Size=UDim2.fromOffset(22,22),Position=UDim2.fromOffset(3,3),BackgroundColor3=C.White},track)
        ctx.Round(knob,11)
        local object=option(key,config,function(v) return v==true end,function(v)
            track.BackgroundColor3=v and C.Lime or C.Inactive
            knob.Position=UDim2.fromOffset(v and 29 or 3,3)
        end)
        bind(button.Activated,function() object:SetValue(not object.Value) end)
        object.Frame=item.Frame
        return object
    end
    function methods:AddSlider(key,config)
        config.Type='Slider'
        local item=row(self,config,100)
        local input=field(item.Heading,82)
        local track=make('TextButton',{Text='',Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,LayoutOrder=3},item.Frame)
        local rail=make('Frame',{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0.5,-2),BackgroundColor3=C.Inactive},track)
        ctx.Round(rail,3)
        local fill=make('Frame',{Size=UDim2.fromScale(0,1),BackgroundColor3=C.Lime},rail);ctx.Round(fill,3)
        local knob=make('Frame',{Size=UDim2.fromOffset(16,16),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),BackgroundColor3=C.Lime},rail);ctx.Round(knob,8)
        local minimum,maximum=config.Min or 0,config.Max or 100
        local precision=10^(config.Rounding or 0)
        local object=option(key,config,function(v)
            local number=tonumber(v);if not number then return nil end
            return math.clamp(math.floor(number*precision+0.5)/precision,minimum,maximum)
        end,function(v)
            local fraction=maximum==minimum and 0 or (v-minimum)/(maximum-minimum)
            fill.Size=UDim2.fromScale(fraction,1);knob.Position=UDim2.fromScale(fraction,0.5);input.Text=tostring(v)
        end)
        local function change(x)
            object:SetValue(minimum+math.clamp((x-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)*(maximum-minimum))
        end
        bind(track.InputBegan,function(event)
            if ctx.IsPointer(event) then ctx.Window.SliderDrag={Input=event,Change=change};change(event.Position.X) end
        end)
        bind(input.FocusLost,function() object:SetValue(input.Text);input.Text=tostring(object.Value) end)
        object.Frame=item.Frame
        return object
    end
    function methods:AddInput(key,config)
        config.Type='Input'
        local item=row(self,config,140)
        local input=field(item.Heading,125)
        input.PlaceholderText=config.Placeholder or ''
        local object=option(key,config,function(v)
            if v==nil then return '' end
            if config.Numeric and not tonumber(v) then return nil end
            return tostring(v)
        end,function(v) input.Text=v end)
        local function update()
            if config.Numeric and not tonumber(input.Text) then input.Text=object.Value or '';return end
            object:SetValue(input.Text)
        end
        bind(input.FocusLost,update)
        if not config.Finished then bind(input:GetPropertyChangedSignal('Text'),function() if input.Text~=object.Value then update() end end) end
        object.Frame=item.Frame
        return object
    end
    function methods:AddDropdown(key,config)
        config.Type='Dropdown'
        local item=row(self,config,0)
        local button=make('TextButton',{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.Input,TextColor3=C.Text,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text='',LayoutOrder=3},item.Frame)
        ctx.Round(button,6);ctx.Stroke(button,C.Line);ctx.Padding(button,10)
        local values=table.clone(config.Values or {})
        local object=option(key,config,function(v)
            if config.Multi then
                local selected={}
                if type(v)=='table' then
                    for k,value in pairs(v) do
                        local name=type(k)=='number' and value or k
                        if table.find(values,name) and (type(k)=='number' or value==true) then selected[name]=true end
                    end
                end
                return selected
            end
            if type(v)=='number' then v=values[v] end
            if table.find(values,v) then return v end
            return values[1] or ''
        end,function(v)
            if config.Multi then
                local count=0;for _ in pairs(v) do count+=1 end
                button.Text='เลือกแล้ว '..count..' รายการ   ⌄'
            else button.Text=tostring(v)..'   ⌄' end
        end)
        bind(button.Activated,function()
            ctx.OpenPopup(button,function(container)
                for _,name in ipairs(values) do
                    local selected=config.Multi and object.Value[name] or object.Value==name
                    local choice=make('TextButton',{Size=UDim2.new(1,0,0,38),BackgroundColor3=selected and C.Selected or C.Card,TextColor3=selected and C.Lime or C.Text,Text=(selected and '✓  ' or '    ')..name,TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,Font=Enum.Font.Gotham,ZIndex=54},container)
                    ctx.Round(choice,5);ctx.Padding(choice,10)
                    bind(choice.Activated,function()
                        if config.Multi then
                            local nextValue=copy(object.Value);nextValue[name]=not nextValue[name] or nil;object:SetValue(nextValue)
                            local on=object.Value[name];choice.Text=(on and '✓  ' or '    ')..name;choice.BackgroundColor3=on and C.Selected or C.Card;choice.TextColor3=on and C.Lime or C.Text
                        else object:SetValue(name);ctx.ClosePopup() end
                    end,true)
                end
            end,math.min(284,#values*42+16))
        end)
        object.Frame=item.Frame
        return object
    end
    function methods:AddColorpicker(key,config)
        config.Type='Colorpicker'
        local item=row(self,config,75)
        local swatch=action(item.Heading,'',54)
        local object=option(key,config,function(v) return typeof(v)=='Color3' and v or nil end,function(v) swatch.BackgroundColor3=v end)
        object.SetValueRGB=object.SetValue
        bind(swatch.Activated,function()
            ctx.OpenPopup(swatch,function(container)
                local channels={math.round(object.Value.R*255),math.round(object.Value.G*255),math.round(object.Value.B*255)}
                for index,name in ipairs({'แดง (R)','เขียว (G)','น้ำเงิน (B)'}) do
                    local line=make('Frame',{Size=UDim2.new(1,0,0,48),BackgroundTransparency=1,ZIndex=54},container)
                    local caption=label(line,name,13,C.Text);caption.Size=UDim2.new(1,-85,1,0);caption.ZIndex=54
                    local input=field(line,75);input.Text=tostring(channels[index]);input.ZIndex=55
                    bind(input.FocusLost,function()
                        channels[index]=math.clamp(math.round(tonumber(input.Text) or channels[index]),0,255);input.Text=tostring(channels[index])
                        object:SetValue(Color3.fromRGB(channels[1],channels[2],channels[3]))
                    end,true)
                end
            end,172)
        end)
        object.Frame=item.Frame
        return object
    end
    ctx.Window.ControlMethods=methods
    return function(tab)
        for name,method in pairs(methods) do tab[name]=method end
        return tab
    end
end

end)()
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
local thaiDictionary={["labels"]={["Needle Helper"]="ผู้ช่วยค้นหาเข็ม",["MuMu / Delta"]="เมนูภาษาไทย",["Farm"]="เก็บฟาง",["ESP"]="ไฮไลต์",["Settings"]="ตั้งค่า",["Gems"]="เพชร",["Upgrades"]="อัปเกรด",["Tools"]="เครื่องมือ",["Statistics"]="สถิติ",["Shop"]="ร้านค้า",["Replay"]="เล่นใหม่",["Objective"]="เป้าหมายด่าน",["Live status"]="สถานะปัจจุบัน",["Collection mode"]="วิธีเก็บฟาง",["Collect nearby hay"]="เก็บฟางอัตโนมัติ",["Auto sell and return"]="ขายอัตโนมัติแล้วกลับจุดเดิม",["Temporarily moves to the sell point."]="เมื่อฟางถึงจำนวนที่ตั้งไว้ จะย้ายไปขายและกลับมาเก็บต่อ",["Collect radius"]="ระยะค้นหาฟางรอบตัว",["Collect interval (seconds)"]="ช่วงเวลาหยิบฟาง (วินาที)",["Game cooldown still applies."]="ค่าต่ำลงไม่ได้ข้ามเวลารอของเกม ใช้ค่านี้กับการเก็บด้วยมือ",["Sell at bag percentage"]="ขายเมื่อกระเป๋าถึงเปอร์เซ็นต์",["Sell bag now and return"]="ขายฟางตอนนี้แล้วกลับมา",["Revealed needle ESP"]="ไฮไลต์เข็มที่เกมเปิดเผยแล้ว",["Target availability"]="เงื่อนไขการแสดงเข็ม",["The server must reveal the needle target before it can be highlighted."]="แสดงตำแหน่งได้เมื่อเกมส่งเป้าหมายเข็มมาแล้ว ไม่สามารถเปิดเผยเข็มที่ยังซ่อนไว้ได้",["Needle color"]="สีไฮไลต์เข็ม",["Pause all automation"]="หยุดระบบอัตโนมัติทั้งหมด",["Unload helper"]="ปิดผู้ช่วยและล้างการทำงาน",["Reset launcher position"]="คืนตำแหน่งไอคอนเมนู",["Collect nearby revealed gems"]="เก็บเพชรที่ปรากฏใกล้ตัว",["Gem ESP and distance"]="แสดงเพชรและระยะห่าง",["Gem collect radius"]="ระยะเก็บเพชร",["Collection"]="วิธีเก็บเพชร",["Collects revealed gems in range; does not move your character."]="เก็บเพชรที่เกมสร้างแล้วและอยู่ในระยะ โดยไม่ย้ายตัวละครไปหาเพชร",["Auto upgrade (spends Cash)"]="อัปเกรดอัตโนมัติด้วยเงินในเกม",["Upgrade mode"]="รูปแบบอัปเกรด",["Included tracks"]="สายอัปเกรดที่อนุญาต",["All selected by default. Locked and maxed tracks are skipped."]="เลือกเฉพาะสายที่ต้องการซื้อ ระบบข้ามสายที่ยังล็อกหรืออัปเต็มแล้ว",["Select all tracks"]="เลือกทุกสาย",["Upgrade sequence"]="ลำดับอัปเกรด",["How the sequence works"]="การอัปตามลำดับ",["Buys one level per track, then repeats. Skips locked, maxed, and unaffordable tracks. Cash reserve always applies."]="อัปสายละหนึ่งขั้นแล้ววนรอบ ข้ามสายที่ล็อก เต็ม หรือเงินไม่พอ และไม่ใช้เงินส่วนที่ตั้งสำรองไว้",["Upgrade track"]="เลือกสายสำหรับโหมดสายเดียว",["Cash reserve"]="เงินที่ต้องเหลือหลังอัปเกรด",["Upgrade status"]="สถานะอัปเกรด",["Auto use equipped unlocked tool"]="เลือกและใช้เครื่องมืออัตโนมัติ",["Auto selection"]="เหตุผลที่เลือกเครื่องมือนี้",["Ownership"]="เครื่องมือที่ปลดล็อก",["Usage"]="วิธีใช้เครื่องมือ",["Session statistics"]="สถิติการทำงานรอบนี้",["Reset session statistics"]="เริ่มนับสถิติใหม่",["Notifications"]="แจ้งเตือนเหตุการณ์สำคัญ",["Auto buy selected tools (Cash)"]="ซื้อเครื่องมืออัตโนมัติด้วยเงินในเกม",["Purchase order"]="ลำดับซื้อเครื่องมือ",["Pitchfork > TNT > Drone > Vacuum. Buys each selected tool once when affordable. Ownership is checked after purchase."]="คราด → ระเบิด → โดรน → เครื่องดูด ซื้อเฉพาะที่เลือกและยังไม่มี เมื่อเงินพอ แล้วตรวจว่าซื้อสำเร็จจริง",["Shop Cash reserve"]="เงินที่ต้องเหลือหลังซื้อเครื่องมือ",["Scope"]="สินค้าที่ระบบซื้อได้",["Uses Cash / Coins options only. Infinite Bag has no Cash option and is excluded. Purchases may apply only to this round."]="ใช้เฉพาะเงินในเกม ไม่ซื้อด้วยโรบัค บางสินค้าใช้ได้เฉพาะรอบนี้ ถุงไม่จำกัดไม่มีราคาเงินในเกมจึงไม่อยู่ในรายการ",["Shop status"]="สถานะร้านค้า",["Collect gems before hay"]="เก็บเพชรก่อนฟาง",["Rare hay before normal hay"]="เก็บฟางหายากก่อนฟางธรรมดา",["Hay priority (within reach)"]="ลำดับชนิดฟางภายในระยะ",["Event-only types have no normal spawn probability and are listed first."]="ชนิดพิเศษจากกิจกรรมไม่มีโอกาสเกิดปกติ จึงอยู่ต้นรายการ",["Auto replay after round ends"]="เล่นใหม่อัตโนมัติเมื่อจบรอบ",["Replay status"]="สถานะเล่นใหม่",["Behavior"]="ขั้นตอนเล่นใหม่",["Votes REPLAY after the ending screen appears. Other players may also need to vote. Reloads the helper after teleport when executor file storage and teleport queue are available."]="รอหน้าจบรอบแล้วโหวตเล่นใหม่ หากมีผู้เล่นอื่นต้องรอโหวตตามเกม จะโหลดผู้ช่วยต่อเมื่อย้ายเซิร์ฟเวอร์หากเครื่องมือรันสคริปต์รองรับ",["Auto complete round objective"]="ทำเป้าหมายด่านอัตโนมัติ",["Round search progress"]="ความคืบหน้าค้นหาเข็ม",["Objective status"]="ขั้นตอนเป้าหมายปัจจุบัน",["Sequence"]="ขั้นตอนการผ่านด่าน",["Farm hay > collect revealed needle > equip needle > move to farmer > hand in > wait for round completion > Auto Replay. Uses temporary character movement. Does not reveal hidden server targets."]="ด่านบ้าน: เก็บฟาง → เก็บเข็มที่เปิดเผย → ถือเข็ม → ไปส่งชาวนา → รอเกมยืนยันจบรอบ → เล่นใหม่ ระบบย้ายตัวละครเพื่อทำงาน และไม่เปิดเผยเป้าหมายที่เกมยังซ่อนอยู่",["Vacuum diagnostics"]="สถานะเครื่องดูด",["360 + Tools"]="การเก็บรอบตัวร่วมกับเครื่องมือ",["360 mode supports unlocked tools. Pitchfork selects nearby hay without your aim. Vacuum and TNT aim automatically; the camera can turn. Tool range and heat still apply."]="โหมดรอบตัวเลือกเป้าหมายให้คราด เครื่องดูด และระเบิด โดยไม่ต้องเล็งเอง กล้องอาจหมุนตามเป้าหมาย และยังใช้ระยะ ความร้อน และเวลารอของเกม",["BASEMENT support"]="ขั้นตอนด่านชั้นใต้ดิน",["Levers > Color count > Rotate picture > Read posters and enter code > Find key > Trapdoor escape. Each action waits for server confirmation."]="คันโยก → นับสี → หมุนภาพ → อ่านกระดาษและใส่รหัส → หากุญแจ → เปิดทางออก แต่ละขั้นรอเกมยืนยันผล",["Anti-AFK (idle disconnect)"]="ป้องกันหลุดเพราะไม่มีการกด",["Anti-AFK status"]="สถานะป้องกันหลุด",["Disconnect protection"]="ข้อจำกัดการป้องกันหลุด",["Sends a brief right mouse input every 2 minutes and when Roblox signals idle. Does not prevent network loss or server removal. A disconnected game must reconnect first."]="ส่งอินพุตสั้น ๆ ทุกสองนาทีและเมื่อเกมแจ้งว่าไม่มีการกด ช่วยป้องกันหลุดจากการอยู่เฉย ไม่ป้องกันเน็ตหลุดหรือการเตะโดยเซิร์ฟเวอร์",["Auto skip game cutscenes"]="ข้ามคัตซีนอัตโนมัติ",["Skip delay (seconds)"]="รอก่อนกดข้าม (วินาที)",["Auto Skip status"]="สถานะข้ามคัตซีน",["Supported Skip controls"]="ฉากที่ข้ามได้",["Uses the game SkipCutsceneButton control shared by intro/end scenes and compatible puzzle cutscenes. Scenes without a game Skip button are left to finish normally. Does not change round completion or puzzle flags."]="กดเฉพาะปุ่มข้ามที่เกมมีในฉากเริ่ม ฉากจบ และฉากปริศนาที่รองรับ หากไม่มีปุ่มจะรอฉากจบ ไม่แก้สถานะปริศนาหรือบังคับจบรอบ",["Starting..."]="กำลังเริ่มทำงาน…",["Waiting..."]="กำลังรอ…",["Checking..."]="กำลังตรวจสอบ…",["Waiting for round end"]="รอจบรอบ",["Waiting for revealed needle"]="รอเกมเปิดเผยเข็ม",["Waiting for a game Skip button"]="รอปุ่มข้ามของเกม",["Waiting for a visible game Skip button"]="รอปุ่มข้ามปรากฏบนจอ",["Game Skip control acknowledged"]="ปุ่มข้ามตอบรับแล้ว",["Skip requested; waiting for game UI"]="กดข้ามแล้ว กำลังรอฉากเปลี่ยน",["Skip input failed:"]="กดข้ามไม่สำเร็จ:",["Waiting for vacuum"]="รอเครื่องดูด",["Checking hay remaining..."]="กำลังตรวจฟางที่เหลือ…",["Searching for revealed needle"]="ค้นหาเข็มที่เกมเปิดเผยแล้ว",["Auto buy disabled"]="ปิดการซื้ออัตโนมัติ",["Purchase not confirmed; auto buy paused"]="เกมยังไม่ยืนยันการซื้อ พักระบบซื้อแล้ว",["Paused: game input locked"]="พักชั่วคราวระหว่างเกมล็อกการควบคุม",["Waiting for current upgrade confirmation"]="รอเกมยืนยันอัปเกรดรายการปัจจุบัน",["Shop error; paused"]="ร้านค้าเกิดข้อผิดพลาด พักการซื้อแล้ว",["Waiting: selected tracks are locked, maxed, or need more Cash."]="รอเงินเพิ่ม หรือสายที่เลือกยังล็อก/อัปเต็มแล้ว",["Tool not unlocked"]="ยังไม่ปลดล็อกเครื่องมือนี้",["Maximum level"]="อัปเกรดเต็มแล้ว",["Next in sequence:"]="รายการถัดไป:",["Holding tool until action completes"]="ถือเครื่องมือนี้รอให้เริ่มทำงานก่อนสลับ",["Hand: collecting hay"]="ใช้มือเก็บฟาง",["Hand: gem priority"]="ใช้มือระหว่างเก็บเพชรก่อน",["Hand: bag full / sell"]="กระเป๋าเต็ม เตรียมขาย",["Drone: deploy then continue gathering"]="ปล่อยโดรนแล้วเก็บฟางต่อ",["Vacuum: using until cooling or no harvest"]="ใช้เครื่องดูดจนร้อนหรือไม่มีผลการเก็บ",["TNT: ready while vacuum unavailable"]="ใช้ระเบิดระหว่างพักเครื่องดูด",["Pitchfork: vacuum retry in "]="ใช้คราด ลองเครื่องดูดใหม่ใน ",["Pitchfork: vacuum cooling"]="ใช้คราดระหว่างเครื่องดูดลดความร้อน",["Pitchfork: waiting for dig cooldown"]="ถือคราดรอเวลาขุดครั้งถัดไป",["Pitchfork: ready; holding selected tool"]="คราดพร้อมใช้งาน ถือรอเป้าหมาย",["Drone > Vacuum > TNT during vacuum downtime > Pitchfork > Hand. Holds pitchfork through cooldown instead of switching to hand."]="เลือกโดรน → เครื่องดูด → ระเบิดเมื่อเครื่องดูดพัก → คราด → มือ และถือคราดรอเวลาขุดแทนสลับกลับมือ",["Equip pitchfork and aim at hay, vacuum, or drone. Locked tools are skipped. TNT lights and throws while aiming at hay; observes game cooldown."]="เลือกเครื่องมือที่ปลดล็อกให้เอง พร้อมขยับเข้าใกล้เป้าหมาย คราด เครื่องดูด และระเบิดใช้เวลารอตามเกม โหมดรอบตัวช่วยเล็งให้อัตโนมัติ",["No confirmed harvest; using hand/pitchfork for 8 seconds"]="ยังไม่พบผลการดูด ใช้มือหรือคราดแทนแปดวินาที",["Vacuum cooling; using another tool"]="เครื่องดูดกำลังลดความร้อน ใช้เครื่องมืออื่นก่อน",["Vacuum paused: no confirmed harvest. Retry in "]="พักเครื่องดูดเพราะยังเก็บไม่ได้ ลองใหม่ใน ",["Idle-prevention input sent successfully"]="ส่งอินพุตป้องกันหลุดสำเร็จ",["Executor rejected idle-prevention input; protection unverified"]="เครื่องมือรันสคริปต์ไม่รับอินพุต จึงยังยืนยันการป้องกันหลุดไม่ได้",["Enabled; waiting for first input check"]="เปิดแล้ว รอตรวจการส่งอินพุตครั้งแรก",["Replay vote supported; automatic helper reload unavailable"]="โหวตเล่นใหม่ได้ แต่เครื่องมือยังไม่รองรับโหลดผู้ช่วยต่ออัตโนมัติ",["Game is launching the next round"]="เกมกำลังเปิดรอบใหม่",["Round ended; waiting for replay screen"]="จบรอบแล้ว รอหน้าจอโหวตเล่นใหม่",["Replay vote confirmed:"]="ยืนยันโหวตเล่นใหม่แล้ว:",["Replay vote sent; waiting for confirmation"]="ส่งโหวตเล่นใหม่แล้ว รอเกมยืนยัน",["Vote unconfirmed after 3 attempts; use the game replay button"]="ลองสามครั้งแล้วยังไม่ยืนยัน กรุณาใช้ปุ่มเล่นใหม่ของเกม",["Round completed; waiting for Auto Replay"]="ผ่านด่านแล้ว รอระบบเล่นใหม่",["Another player has the objective; waiting for round end"]="ผู้เล่นอื่นถือเป้าหมายอยู่ รอจบรอบ",["Delivering needle"]="นำเข็มไปส่งชาวนา",["Waiting for completion cutscene"]="รอฉากจบด่าน",["Collecting revealed needle"]="กำลังเก็บเข็มที่ปรากฏ",["Searching: farming until needle is revealed"]="เก็บฟางต่อเพื่อค้นหาเข็ม",["No progress: searching a different part of the pile"]="ความคืบหน้าไม่เพิ่ม เปลี่ยนจุดค้นหา",["Moving closer to remaining hay"]="ขยับเข้าใกล้ฟางที่เหลือ",["Pulling three levers"]="ดึงคันโยกทั้งสามตัว",["Counting visible colored gems"]="นับและตั้งจำนวนชิ้นสีที่มองเห็น",["Rotating picture tiles upright"]="หมุนชิ้นภาพให้ถูกทิศ",["Entering discovered keypad code"]="กรอกรหัสที่ค้นพบ",["Searching numbered posters for the code"]="ค้นหารหัสจากกระดาษ",["Waiting for release sequence"]="รอฉากเปิดทางออก",["Puzzles solved; searching for key"]="ปริศนาครบแล้ว กำลังหากุญแจ",["Taking key to trapdoor"]="นำกุญแจไปเปิดทางออก",["BASEMENT:"]="ชั้นใต้ดิน:",["Requested:"]="กดข้ามแล้ว:",["acknowledged:"]="ปุ่มตอบรับแล้ว:",["Hay removed:"]="เก็บฟางแล้ว:",["remaining:"]="เหลือ:",["Needle:"]="เข็ม:",["no progress for"]="ความคืบหน้าไม่เพิ่มนาน",["not revealed by server"]="เกมยังไม่เปิดเผย",["revealed"]="เปิดเผยแล้ว",["State:"]="สถานะ:",["heat"]="ความร้อน",["Target:"]="เป้าหมาย:",["confirmed hay:"]="ยืนยันฟางที่ดูดได้:",["none nearby"]="ไม่มีในระยะ",["studs"]="หน่วย",["Time:"]="เวลา:",["Hay collected:"]="ฟางที่เก็บ:",["Gems gained:"]="เพชรที่เพิ่ม:",["Cash earned:"]="เงินที่ได้รับ:",["Hay sold this session:"]="ฟางที่ขายรอบนี้:",["Hay sold:"]="ฟางที่ขาย:",["Cash:"]="เงินในเกม:",["Shop reserve:"]="เงินสำรองร้านค้า:",["Bag:"]="กระเป๋า:",["Needle target highlighted"]="แสดงไฮไลต์เข็มแล้ว",["ESP disabled"]="ปิดไฮไลต์แล้ว",["Collecting gem first"]="กำลังเก็บเพชรก่อนฟาง",["Finishing TNT sequence"]="รอจุดชนวนและโยนระเบิดให้เสร็จ",["Sell point unavailable"]="ยังไม่พบจุดขาย",["Selling..."]="กำลังขาย…",["Sold; returned"]="ขายแล้วและกลับจุดเดิม",["Sale not confirmed"]="ยังไม่ยืนยันการขาย",["Bag full"]="กระเป๋าเต็ม",["Picking nearby hay"]="กำลังเก็บฟางใกล้ตัว",["Move closer to hay"]="ต้องขยับเข้าใกล้ฟาง",["360 pickup:"]="เก็บรอบตัว:",["Picking "]="กำลังเก็บ ",["Unlocked"]="ปลดล็อกแล้ว",["Locked"]="ยังล็อก",["Owned"]="มีแล้ว",["Buying "]="กำลังซื้อ ",["needs $"]="ต้องการเงินเพิ่ม $",[" more"]="",["next $"]="ขั้นถัดไป $",["reserve $"]="เงินสำรอง $",["Waiting for Cash, or selected tools already owned"]="รอเงินเพิ่ม หรือมีสินค้าที่เลือกครบแล้ว",["Ready"]="พร้อม",["idle"]="พร้อม",["ready"]="พร้อมใช้",["lighting"]="กำลังจุดชนวน",["charging"]="กำลังเตรียมโยน",["spent"]="รอใช้ครั้งถัดไป",["Suction"]="กำลังดูด",["Overheated"]="ร้อนเกินไป กำลังพัก",["Normal"]="ธรรมดา",["Void"]="วอยด์",["Rainbow"]="สายรุ้ง",["Electric"]="ไฟฟ้า",["Gold"]="ทอง",["Burnt"]="ไหม้",["Glass"]="แก้ว",["Muddy"]="โคลน",["Grassy"]="หญ้า",["Damp"]="ชื้น",["Acid"]="กรด",["Pitchfork"]="คราด",["Vacuum"]="เครื่องดูด",["Drone"]="โดรน",["Tnt"]="ระเบิด",["TNT"]="ระเบิด",["Hand"]="มือ",["/min"]="/นาที",[" paused"]=" พักแล้ว",["; paused"]="; พักแล้ว"},["values"]={["Tools (normal)"]="ใช้เครื่องมือปกติ",["360 pickup (no aim)"]="เก็บรอบตัว ไม่ต้องเล็ง",["All tracks in order"]="ทุกสายตามลำดับ",["Single track"]="อัปเฉพาะสายที่เลือก",["Speed"]="ความเร็วเก็บด้วยมือ",["Grab"]="จำนวนฟางต่อการคว้า",["Capacity"]="ความจุกระเป๋า",["HandHold"]="กดค้างเก็บฟาง",["Pitchfork"]="พลังขุดของคราด",["PitchforkCooldown"]="เวลารอคราด",["PitchforkHold"]="กดค้างใช้คราด",["VacuumPower"]="พลังเครื่องดูด",["VacuumRuntime"]="ระยะเวลาที่ดูดได้",["VacuumCooling"]="เวลาพักเครื่องดูด",["DroneGrab"]="จำนวนฟางต่อรอบโดรน",["DroneSpeed"]="ความเร็วโดรน",["DroneCapacity"]="ความจุโดรน",["TntPower"]="พลังระเบิด",["TntCooldown"]="เวลารอระเบิด",["TntLuck"]="โอกาสระเบิดพิเศษ",["Value"]="มูลค่าฟาง"},["descriptions"]={["Sell bag now and return"]="สั่งขายฟางที่ถืออยู่ทันที ไม่ต้องรอเต็ม แล้วกลับตำแหน่งเดิม",["Pause all automation"]="หยุดเก็บ ขาย ซื้อ อัปเกรด เป้าหมาย และเล่นใหม่ การป้องกันหลุดกับข้ามฉากยังแยกเปิดปิดได้",["Unload helper"]="หยุดผู้ช่วยทั้งหมด ล้างตัวตรวจและปุ่มไอคอน หากต้องการใช้อีกให้รันสคริปต์ใหม่",["Reset launcher position"]="ย้ายไอคอนรูป iNo กลับมุมขวาบนเมื่อลากไปตำแหน่งที่ไม่สะดวก",["Select all tracks"]="เลือกสายอัปเกรดทุกสาย โดยยังข้ามสายที่ล็อกหรืออัปเต็มแล้ว",["Reset session statistics"]="เริ่มนับฟาง เงิน และเพชรของผู้ช่วยใหม่ ไม่ลบเงินหรือของจริงในเกม",["NH_CollectMode"]="โหมดปกติใช้เครื่องมือตามที่ถือ โหมดรอบตัวค้นเป้าหมายให้และอาจขยับตัวละครหรือหมุนกล้อง",["NH_Auto"]="เก็บฟางที่โหลดอยู่ในระยะ หากเปิดเครื่องมืออัตโนมัติจะเลือกเครื่องมือที่มีให้ด้วย",["NH_Radius"]="ระยะค้นหาเป้าหมายรอบตัว ไม่ได้เพิ่มระยะที่เซิร์ฟเวอร์อนุญาตให้เครื่องมือเก็บได้",["NH_Threshold"]="ตั้ง 100 เพื่อขายเมื่อเต็ม หรือลดค่านี้เพื่อขายบ่อยขึ้น",["NH_ESP"]="ไฮไลต์เฉพาะเข็มที่เกมเปิดเผยแล้ว ไม่ทำให้พบเข็มก่อนเงื่อนไขเกม",["NH_Color"]="เปลี่ยนสีที่ใช้เน้นตำแหน่งเข็ม",["NH_Gems"]="เก็บเฉพาะเพชรที่ปรากฏจริงและอยู่ในระยะ ไม่สร้างเพชรเพิ่ม",["NH_GemESP"]="แสดงชื่อและระยะของเพชรที่โหลดอยู่",["NH_GemRadius"]="เก็บได้ไม่เกินระยะสูงสุดที่เกมกำหนด",["NH_GemPriority"]="พักเก็บฟางเมื่อมีเพชรในระยะ หากเก็บไม่สำเร็จจะพักลองชั่วคราวแล้วทำฟางต่อ",["NH_RareFirst"]="เลือกฟางหายากก่อนจากเป้าหมายในระยะ หากไม่พบจะเก็บชนิดธรรมดาต่อ",["NH_Upgrade"]="ใช้เงินจริงในรอบเกมตามสายที่เลือก โดยเหลือเงินสำรองและรอเกมยืนยันทุกครั้ง ไม่ใช้โรบัค",["NH_UpgradeMode"]="ทุกสาย: อัปทีละขั้นแล้ววนรอบ สายเดียว: ซื้อเฉพาะสายที่เลือกด้านล่าง",["NH_Track"]="มีผลเฉพาะเมื่อเลือกรูปแบบอัปเฉพาะสายที่เลือก",["NH_Reserve"]="ตัวอย่าง ตั้ง 10 จะไม่อัปเกรดหากซื้อแล้วเงินเหลือต่ำกว่า 10",["NH_Tools"]="เลือกโดรน เครื่องดูด ระเบิด คราด หรือมือ ตามความพร้อม ถือรอให้ทำงานก่อนสลับ และพักเมื่อขายหรือทำเป้าหมาย",["NH_Notify"]="แสดงข้อความเมื่อมีเหตุการณ์สำคัญ เช่น กระเป๋าเต็ม ซื้อสำเร็จ หรือระบบต้องหยุด",["NH_Shop"]="ซื้อเฉพาะรายการที่เลือกและยังไม่มีเมื่อเงินพอ ให้การซื้อเครื่องมือมาก่อนเริ่มอัปเกรดรายการใหม่",["NH_ShopReserve"]="เงินสำรองเฉพาะร้านค้า แยกจากเงินสำรองอัปเกรด",["NH_Replay"]="รอจบรอบแล้วโหวตเล่นใหม่ตามระบบเกม อาจต้องรอผู้เล่นอื่นโหวตด้วย",["NH_Objective"]="เก็บฟางและทำเป้าหมายตามด่าน รองรับบ้าน ชั้นใต้ดิน และฟาร์มปศุสัตว์ รอผลจากเกมก่อนเปลี่ยนขั้นตอน หากทำซ้ำไม่สำเร็จจะหยุดให้ตรวจสอบ",["NH_AntiAFK"]="ส่งอินพุตทุกสองนาทีเพื่อป้องกันการหลุดจากการไม่มีการกด ต้องให้เครื่องมือรันสคริปต์รองรับ",["NH_AutoSkip"]="กดเฉพาะปุ่มข้ามที่เกมแสดง ไม่บังคับผ่านฉากที่เกมไม่อนุญาต",["NH_SkipDelay"]="เวลารอหลังปุ่มข้ามปรากฏก่อนกด ช่วยให้ปุ่มพร้อมทำงาน"}}
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
    local values={}
    for index,item in ipairs({{'เงินสด','฿',Color3.fromRGB(158,219,96)},{'เพชร','◇',Color3.fromRGB(70,198,242)},{'กระเป๋า','▣',Color3.fromRGB(242,200,83)}}) do
        local frame=make('Frame',{Size=UDim2.new(1/3,-7,1,0),Position=UDim2.new((index-1)/3,(index-1)*3,0,0),BackgroundColor3=C.Card},metrics)
        ctx.Round(frame,9);ctx.Stroke(frame,C.Line)
        local icon=label(frame,item[2],25,item[3]);icon.Position=UDim2.fromOffset(12,23);icon.Size=UDim2.fromOffset(26,32)
        local title=label(frame,item[1],11,C.Muted);title.Position=UDim2.fromOffset(44,7);title.Size=UDim2.new(1,-50,0,20)
        local value=label(frame,'—',18,C.Text);value.Position=UDim2.fromOffset(44,30);value.Size=UDim2.new(1,-50,0,28);value.Font=Enum.Font.GothamBold
        values[index]=value
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
    local logsTab=window:AddTab({Title='บันทึก',Icon='file-text'})
    local logsInfo=logsTab:AddParagraph({Title='เหตุการณ์ล่าสุด',Content='รอบันทึกการทำงานจริง'})
    logsTab:AddParagraph({Title='เกี่ยวกับบันทึก',Content='แสดง 10 รายการล่าสุดของผู้ช่วย แยกคำขอทำงานออกจากผลที่ยืนยันแล้ว รายละเอียดเพิ่มเติมยังดูได้จาก Needle Live'})
    window.OnLogs=function() window:SelectTab(logsTab) end
    window.OnPause=function()
        if state.pauseAll then state.pauseAll();library:Notify({Title='พักทั้งหมดแล้ว',Content='เปิดฟังก์ชันที่ต้องการอีกครั้งจากเมนู',Duration=3}) end
    end
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
        segments.Visible=narrow
        columns.Position=UDim2.fromOffset(0,narrow and 114 or 80)
        columns.Size=UDim2.new(1,0,1,narrow and -114 or -80)
        if narrow then
            leftScroll.Size=UDim2.fromScale(1,1);rightScroll.Size=UDim2.fromScale(1,1)
            rightScroll.Position=UDim2.fromOffset(0,0)
            leftScroll.Visible=section=='controls';rightScroll.Visible=section=='objective'
        else
            leftScroll.Size=UDim2.new(0.5,-7,1,0);rightScroll.Size=UDim2.new(0.5,-7,1,0);rightScroll.Position=UDim2.new(0.5,7,0,0)
            leftScroll.Visible=true;rightScroll.Visible=true
        end
        for _,value in ipairs(values) do value.TextSize=width<460 and 14 or 18 end
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
    local lastLogSequence
    local function tick()
        local stats=player:FindFirstChild('leaderstats')
        local cash=stats and stats:FindFirstChild('Cash')
        text(values[1],cash and string.format('$%.2f',cash.Value) or '—')
        text(values[2],tostring(player:GetAttribute('Gems') or '—'))
        local held,capacity=player:GetAttribute('HayHeld'),player:GetAttribute('HayCapacity')
        text(values[3],held~=nil and capacity~=nil and (tostring(held)..' / '..tostring(capacity)) or '—')
        local map=remotes:GetAttribute('Map')
        text(window.MapLabel,tostring(map or 'รอข้อมูล'))
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
        local logs=state.logs or {}
        local latest=logs[#logs]
        if latest and lastLogSequence~=latest.seq then
            lastLogSequence=latest.seq
            local lines={}
            for index=math.max(1,#logs-9),#logs do
                local entry=logs[index]
                local kind=({confirmed='ยืนยัน',request='สั่งงาน',state='สถานะ',error='ผิดพลาด'})[entry.kind] or entry.kind
                table.insert(lines,'['..tostring(kind)..'] '..translate(entry.message))
            end
            logsInfo:SetDesc(table.concat(lines,'\n\n'))
        end
    end
    state.uiDashboardUpdate=tick
    task.spawn(function()
        while state.alive and not library.Unloaded do
            local ok,err=pcall(tick)
            if not ok then state.diagnostics.uiError=tostring(err);window:SetStatus('แสดงข้อมูลไม่ครบ ตรวจบันทึก',true)
            else state.diagnostics.uiError=nil end
            task.wait(0.6)
        end
    end)
end

end)()
local Library={Options={},Unloaded=false,Version='iNo UI 1.2',Connections={}}
local C={Background=Color3.fromRGB(15,20,22),Sidebar=Color3.fromRGB(16,23,25),Card=Color3.fromRGB(23,31,33),Input=Color3.fromRGB(17,24,26),Line=Color3.fromRGB(48,62,65),Text=Color3.fromRGB(231,239,232),Muted=Color3.fromRGB(155,175,168),Lime=Color3.fromRGB(177,236,79),Selected=Color3.fromRGB(38,54,34),Inactive=Color3.fromRGB(65,77,80),White=Color3.new(1,1,1),Red=Color3.fromRGB(235,87,85)}
local input=game:GetService('UserInputService')
local function make(class,properties,parent)
    local object=Instance.new(class)
    for key,value in pairs(properties or {}) do object[key]=value end
    object.Parent=parent
    return object
end
local function round(parent,radius) return make('UICorner',{CornerRadius=UDim.new(0,radius)},parent) end
local function stroke(parent,color) return make('UIStroke',{Color=color,Thickness=1,Transparency=0.12},parent) end
local function label(parent,text,size,color)
    return make('TextLabel',{Text=text,Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,TextColor3=color or C.Text,TextSize=size or 14,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center},parent)
end
local function padding(parent,amount) return make('UIPadding',{PaddingLeft=UDim.new(0,amount),PaddingRight=UDim.new(0,amount),PaddingTop=UDim.new(0,amount),PaddingBottom=UDim.new(0,amount)},parent) end
local function list(parent,gap) return make('UIListLayout',{Padding=UDim.new(0,gap or 8),SortOrder=Enum.SortOrder.LayoutOrder},parent) end
local function isPointer(event) return event.UserInputType==Enum.UserInputType.MouseButton1 or event.UserInputType==Enum.UserInputType.Touch end
local function bind(signal,callback,temporary)
    local connection=signal:Connect(callback)
    table.insert(temporary and Library.PopupConnections or Library.Connections,connection)
    return connection
end
local function call(callback,...)
    if type(callback)~='function' then return end
    local ok,err=pcall(callback,...)
    if not ok then warn('[iNo UI] '..tostring(err));Library:Notify({Title='ทำงานไม่สำเร็จ',Content=tostring(err),Duration=5}) end
end
local priorities={['ภาพรวม']=0,['เก็บฟาง']=1,['เพชร']=2,['เครื่องมือ']=3,['ร้านค้า']=4,['อัปเกรด']=5,['เป้าหมายด่าน']=6,['ไฮไลต์']=7,['เล่นใหม่']=8,['สถิติ']=9,['ตั้งค่า']=10}
local function icon(parent,title)
    local holder=make('Frame',{Size=UDim2.fromOffset(24,24),Position=UDim2.fromOffset(7,10),BackgroundTransparency=1},parent)
    local parts={}
    local function line(x1,y1,x2,y2)
        local dx,dy=x2-x1,y2-y1
        local part=make('Frame',{Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),1.5),Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2),AnchorPoint=Vector2.new(0.5,0.5),Rotation=math.deg(math.atan2(dy,dx)),BackgroundColor3=C.Muted,BorderSizePixel=0},holder)
        round(part,1);table.insert(parts,{part,'BackgroundColor3'})
    end
    local function circle(x,y,r)
        local part=make('Frame',{Size=UDim2.fromOffset(r*2,r*2),Position=UDim2.fromOffset(x-r,y-r),BackgroundTransparency=1,BorderSizePixel=0},holder)
        round(part,r);local edge=stroke(part,C.Muted);table.insert(parts,{edge,'Color'})
    end
    if title=='ภาพรวม' then
        line(3,11,12,3);line(12,3,21,11);line(6,9,6,21);line(6,21,18,21);line(18,21,18,9);line(10,21,10,14);line(10,14,14,14);line(14,14,14,21)
    elseif title=='เพชร' then
        line(3,8,8,3);line(8,3,16,3);line(16,3,21,8);line(21,8,12,21);line(12,21,3,8);line(3,8,21,8);line(8,3,8,8);line(16,3,16,8);line(8,8,12,21);line(16,8,12,21)
    elseif title=='เก็บฟาง' then
        line(6,22,17,3);for i=0,2 do line(9+i*3,17-i*5,4+i*3,12-i*5);line(9+i*3,17-i*5,16+i*2,15-i*5) end
    elseif title=='เครื่องมือ' then
        line(5,20,16,9);line(5,20,3,18);line(3,18,14,7);line(14,7,14,2);line(14,2,18,6);line(18,6,22,6);line(22,6,20,10);line(20,10,16,9)
    elseif title=='ร้านค้า' then
        line(2,4,5,4);line(5,4,8,16);line(6,7,22,7);line(22,7,19,14);line(19,14,8,14);circle(9,20,1.8);circle(18,20,1.8)
    elseif title=='อัปเกรด' or title=='สถิติ' then
        line(4,21,4,15);line(10,21,10,11);line(16,21,16,6);line(3,10,18,2);line(18,2,18,7);line(18,2,13,2)
    elseif title=='เป้าหมายด่าน' then
        circle(12,12,9);circle(12,12,5);line(12,12,22,2);line(18,2,22,2);line(22,2,22,6)
    elseif title=='ไฮไลต์' then
        line(2,12,7,6);line(7,6,17,6);line(17,6,22,12);line(22,12,17,18);line(17,18,7,18);line(7,18,2,12);circle(12,12,3)
    elseif title=='เล่นใหม่' then
        line(5,8,5,4);line(5,4,18,4);line(18,4,21,11);line(21,11,18,20);line(18,20,5,20);line(5,20,2,14);line(5,8,10,8)
    elseif title=='ตั้งค่า' then
        circle(12,12,7);circle(12,12,2.5)
        for i=0,7 do local a=math.pi*i/4;line(12+math.cos(a)*8,12+math.sin(a)*8,12+math.cos(a)*11,12+math.sin(a)*11) end
    else
        line(5,2,19,2);line(19,2,19,22);line(19,22,5,22);line(5,22,5,2);line(8,8,16,8);line(8,12,16,12);line(8,16,14,16)
    end
    return {SetColor=function(_,color) for _,item in ipairs(parts) do item[1][item[2]]=color end end}
end

function Library:Notify(config)
    if self.Unloaded or not self.Gui then return end
    local toast=make('Frame',{Name='Notification',Size=UDim2.fromOffset(320,94),Position=UDim2.new(1,-336,0,18),BackgroundColor3=C.Card,ZIndex=110},self.Gui)
    round(toast,10);stroke(toast,C.Lime);padding(toast,14)
    local title=label(toast,config.Title or 'iNo Needle',15,C.Lime);title.ZIndex=111
    local content=label(toast,config.Content or '',12,C.Text);content.Position=UDim2.fromOffset(0,27);content.Size=UDim2.new(1,0,0,43);content.TextWrapped=true;content.ZIndex=111
    if self.Toast then self.Toast:Destroy() end
    self.Toast=toast
    task.delay(tonumber(config.Duration) or 4,function() if toast.Parent then toast:Destroy() end end)
end

function Library:Destroy()
    if self.Unloaded then return end
    self.Unloaded=true
    if self.Window then self.Window:ClosePopup() end
    for _,connection in ipairs(self.Connections) do connection:Disconnect() end
    table.clear(self.Connections)
    for _,option in pairs(self.Options) do if option.Callbacks then table.clear(option.Callbacks) end end
    if self.Gui then self.Gui:Destroy() end
end

function Library:CreateWindow(config)
    assert(not self.Gui,'Create one window per iNo UI library instance')
    self.PopupConnections={}
    local player=game:GetService('Players').LocalPlayer
    local parent=player:WaitForChild('PlayerGui')
    if type(gethui)=='function' then local ok,value=pcall(gethui);if ok and value then parent=value end end
    local gui=make('ScreenGui',{Name='iNoNeedleUI',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
    self.Gui=gui
    local window={Tabs={},Rows={},Selected=nil,Scale=1,Visible=true,Zoom=math.clamp(tonumber(config.UIScale) or 1,0.8,1.5),RequestedSize=config.Size or UDim2.fromOffset(760,480)}
    self.Window=window
    local frame=make('Frame',{Name='Window',Size=UDim2.fromOffset(1000,650),BackgroundColor3=C.Background,ClipsDescendants=false,Active=true},gui)
    window.Root=frame;round(frame,12);stroke(frame,C.Line)
    local scale=make('UIScale',{Scale=1},frame)
    local header=make('Frame',{Name='Header',Size=UDim2.new(1,0,0,56),BackgroundTransparency=1},frame)
    make('Frame',{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=C.Line,BorderSizePixel=0},header)
    local dragHandle=make('TextButton',{Name='DragWindow',Text='',Size=UDim2.new(1,-105,1,0),BackgroundTransparency=1},header)
    local logo=make('ImageLabel',{Name='BrandIcon',Size=UDim2.fromOffset(39,39),Position=UDim2.fromOffset(18,8),BackgroundColor3=C.Selected,Image='',ScaleType=Enum.ScaleType.Fit},header);round(logo,9)
    local fallback=label(logo,'iNo',16,C.Lime);fallback.TextXAlignment=Enum.TextXAlignment.Center;fallback.Size=UDim2.fromScale(1,1)
    window.BrandIcon=logo;window.BrandFallback=fallback
    local title=label(header,'iNo',25,C.White);title.Position=UDim2.fromOffset(68,15);title.Size=UDim2.fromOffset(46,32);title.Font=Enum.Font.GothamBold
    local name=label(header,'Needle',25,C.Lime);name.Position=UDim2.fromOffset(117,15);name.Size=UDim2.fromOffset(110,32);name.Font=Enum.Font.GothamBold
    local map=label(header,'กำลังโหลด',11,C.Lime);map.Position=UDim2.fromOffset(240,23);map.Size=UDim2.fromOffset(106,24);map.TextXAlignment=Enum.TextXAlignment.Center;map.BackgroundColor3=C.Selected;round(map,5)
    window.MapLabel=map
    local function topButton(text,x,color)
        local button=make('TextButton',{Text=text,Size=UDim2.fromOffset(42,42),Position=UDim2.new(1,x,0,10),BackgroundTransparency=1,TextColor3=color,TextSize=27,Font=Enum.Font.Gotham},header)
        return button
    end
    local minimize=topButton('−',-95,C.Text)
    local close=topButton('×',-49,C.Red)
    local sidebar=make('Frame',{Name='Sidebar',Position=UDim2.fromOffset(0,56),Size=UDim2.new(0,176,1,-100),BackgroundColor3=C.Sidebar,BorderSizePixel=0},frame)
    local nav=make('ScrollingFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Line,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},sidebar)
    padding(nav,10);list(nav,5)
    local content=make('Frame',{Name='Main',Position=UDim2.fromOffset(176,56),Size=UDim2.new(1,-176,1,-100),BackgroundTransparency=1},frame)
    local pageTitle=label(content,'ภาพรวม',24,C.Text);pageTitle.Position=UDim2.fromOffset(23,16);pageTitle.Size=UDim2.new(1,-320,0,36);pageTitle.Font=Enum.Font.GothamBold
    local search=make('TextBox',{Name='Search',Text='',PlaceholderText='ค้นหาฟังก์ชัน...',Size=UDim2.fromOffset(245,36),Position=UDim2.new(1,-267,0,16),BackgroundColor3=C.Input,TextColor3=C.Text,PlaceholderColor3=C.Muted,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false},content)
    padding(search,11);round(search,7);stroke(search,C.Line)
    local pages=make('Frame',{Name='Pages',Position=UDim2.fromOffset(22,65),Size=UDim2.new(1,-44,1,-80),BackgroundTransparency=1},content)
    local empty=label(pages,'ไม่พบฟังก์ชันที่ค้นหา',14,C.Muted);empty.Size=UDim2.new(1,0,0,60);empty.Visible=false
    local footer=make('Frame',{Name='Footer',Position=UDim2.new(0,0,1,-44),Size=UDim2.new(1,0,0,44),BackgroundTransparency=1},frame)
    make('Frame',{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Line,BorderSizePixel=0},footer)
    local ready=label(footer,'●  กำลังเชื่อมข้อมูล',12,C.Muted);ready.Position=UDim2.fromOffset(18,14);ready.Size=UDim2.new(1,-320,0,24)
    window.StatusLabel=ready
    local function footerButton(text,x,width,color)
        local button=make('TextButton',{Text=text,Position=UDim2.new(1,x,0,5),Size=UDim2.fromOffset(width,34),BackgroundColor3=color,TextColor3=C.Text,TextSize=12,Font=Enum.Font.Gotham},footer)
        round(button,6);stroke(button,C.Line);return button
    end
    local logs=footerButton('ดูบันทึก',-292,117,C.Card)
    local pause=footerButton('Ⅱ  พักทั้งหมด',-165,147,Color3.fromRGB(126,43,44))
    bind(logs.Activated,function() if window.OnLogs then call(window.OnLogs) end end)
    bind(pause.Activated,function() call(window.OnPause) end)
    window.FooterPause=pause
    function window:ClosePopup()
        self.SliderDrag=nil
        for _,connection in ipairs(Library.PopupConnections) do connection:Disconnect() end
        table.clear(Library.PopupConnections)
        if self.Popup then self.Popup:Destroy();self.Popup=nil end
    end
    local function popup(anchor,builder,height)
        window:ClosePopup()
        height=math.min(height,window.Height-24)
        local overlay=make('TextButton',{Name='PopupLayer',Size=UDim2.fromScale(1,1),Text='',BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.4,ZIndex=50},frame)
        window.Popup=overlay
        local width=math.min(340,window.Width-32)
        local anchorPosition=(anchor.AbsolutePosition-frame.AbsolutePosition)/window.Scale
        local x=math.clamp(anchorPosition.X,12,math.max(12,window.Width-width-12))
        local y=math.clamp(anchorPosition.Y+anchor.AbsoluteSize.Y/window.Scale+6,12,math.max(12,window.Height-height-12))
        local holder=make('Frame',{Size=UDim2.fromOffset(width,height),Position=UDim2.fromOffset(x,y),BackgroundColor3=C.Card,ZIndex=52},overlay)
        round(holder,8);stroke(holder,C.Line)
        local scroll=make('ScrollingFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=53},holder)
        padding(scroll,8);list(scroll,4)
        bind(overlay.Activated,function() window:ClosePopup() end,true)
        builder(scroll)
    end
    local ctx={Colors=C,Make=make,Label=label,Bind=bind,Library=self,Window=window,Round=round,Stroke=stroke,Padding=padding,List=list,Call=call,IsPointer=isPointer,OpenPopup=popup,ClosePopup=function() window:ClosePopup() end}
    window.Context=ctx
    local install=buildControls(ctx)
    function window:AddTab(tabConfig)
        local tab={Title=tabConfig.Title or 'เมนู',Rows={}}
        tab.Button=make('TextButton',{Name=tab.Title,Text='',Size=UDim2.new(1,0,0,44),BackgroundColor3=C.Sidebar,AutoButtonColor=false,LayoutOrder=priorities[tab.Title] or 20},nav);round(tab.Button,7)
        local symbol=icon(tab.Button,tab.Title)
        tab.Symbol=symbol
        local caption=label(tab.Button,tab.Title,13,C.Muted);caption.Position=UDim2.fromOffset(40,0);caption.Size=UDim2.new(1,-44,1,0);caption.TextWrapped=true
        tab.Caption=caption
        local indicator=make('Frame',{Size=UDim2.fromOffset(3,26),Position=UDim2.fromOffset(0,9),BackgroundColor3=C.Lime,Visible=false},tab.Button);round(indicator,2)
        tab.Indicator=indicator
        tab.Page=make('ScrollingFrame',{Name=tab.Title,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.Line,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},pages)
        tab.Content=make('Frame',{Size=UDim2.new(1,-7,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},tab.Page)
        list(tab.Content,11)
        install(tab)
        table.insert(self.Tabs,tab)
        bind(tab.Button.Activated,function() self:SelectTab(tab) end)
        if not self.Selected then self:SelectTab(tab) end
        return tab
    end
    function window:SelectTab(value)
        local tab=type(value)=='number' and self.Tabs[value] or value
        if not tab then return end
        if not tab.Button.Visible then search.Text='' end
        self:ClosePopup()
        self.Selected=tab
        pageTitle.Text=tab.Title
        for _,other in ipairs(self.Tabs) do
            local on=other==tab
            other.Page.Visible=on;other.Indicator.Visible=on
            other.Button.BackgroundColor3=on and C.Selected or C.Sidebar
            other.Caption.TextColor3=on and C.Lime or C.Muted;other.Symbol:SetColor(other.Caption.TextColor3)
        end
    end
    function window:Minimize(value)
        if value==nil then value=frame.Visible end
        frame.Visible=not value;self.Visible=frame.Visible;self:ClosePopup()
    end
    function window:ClampPosition(position)
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1100,700)
        return Vector2.new(math.clamp(position.X,6,math.max(6,viewport.X-frame.AbsoluteSize.X-6)),math.clamp(position.Y,6,math.max(6,viewport.Y-frame.AbsoluteSize.Y-6)))
    end
    function window:SetPosition(position)
        local clamped=self:ClampPosition(position)
        frame.Position=UDim2.fromOffset(clamped.X,clamped.Y)
    end
    function window:ResetPosition()
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1100,700)
        self:SetPosition((viewport-frame.AbsoluteSize)/2)
        call(self.OnPositionChanged,{x=frame.Position.X.Offset/math.max(1,viewport.X),y=frame.Position.Y.Offset/math.max(1,viewport.Y)})
    end
    function window:SetBrandImage(image)
        logo.Image=image or '';fallback.Visible=logo.Image==''
    end
    function window:SetStatus(text,fault)
        local value='●  '..tostring(text)
        if ready.Text~=value then ready.Text=value end
        ready.TextColor3=fault and C.Red or C.Muted
    end
    bind(minimize.Activated,function() window:Minimize() end)
    bind(close.Activated,function()
        popup(close,function(container)
            local description=label(container,'ปิดผู้ช่วยและหยุดระบบอัตโนมัติทั้งหมด?',13,C.Text);description.Size=UDim2.new(1,0,0,42);description.TextWrapped=true;description.ZIndex=54
            local confirm=make('TextButton',{Text='ปิดผู้ช่วย',Size=UDim2.new(1,0,0,38),TextColor3=C.White,BackgroundColor3=C.Red,TextSize=14,Font=Enum.Font.Gotham,ZIndex=54},container);round(confirm,6)
            bind(confirm.Activated,function() if window.OnClose then call(window.OnClose) else Library:Destroy() end end,true)
            local cancel=make('TextButton',{Text='ยกเลิก',Size=UDim2.new(1,0,0,35),TextColor3=C.Text,BackgroundColor3=C.Input,TextSize=13,Font=Enum.Font.Gotham,ZIndex=54},container);round(cancel,6)
            bind(cancel.Activated,function() window:ClosePopup() end,true)
        end,151)
    end)
    bind(dragHandle.InputBegan,function(event)
        if isPointer(event) then window.Drag={Input=event,Start=Vector2.new(event.Position.X,event.Position.Y),Origin=Vector2.new(frame.Position.X.Offset,frame.Position.Y.Offset)} end
    end)
    bind(input.InputChanged,function(event)
        local mouse=event.UserInputType==Enum.UserInputType.MouseMovement
        if window.Drag and (event==window.Drag.Input or mouse and window.Drag.Input.UserInputType==Enum.UserInputType.MouseButton1) then
            local position=Vector2.new(event.Position.X,event.Position.Y)
            if (position-window.Drag.Start).Magnitude>=5 then window:SetPosition(window.Drag.Origin+position-window.Drag.Start) end
        end
        local drag=window.SliderDrag
        if drag and (event==drag.Input or mouse and drag.Input.UserInputType==Enum.UserInputType.MouseButton1) then drag.Change(event.Position.X) end
    end)
    bind(input.InputEnded,function(event)
        if window.Drag and event==window.Drag.Input then
            window.Drag=nil
            local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1100,700)
            call(window.OnPositionChanged,{x=frame.Position.X.Offset/math.max(1,viewport.X),y=frame.Position.Y.Offset/math.max(1,viewport.Y)})
        end
        if window.SliderDrag and event==window.SliderDrag.Input then window.SliderDrag=nil end
    end)
    bind(input.InputBegan,function(event,processed)
        if processed or input:GetFocusedTextBox() then return end
        if event.KeyCode==(config.MinimizeKey or Enum.KeyCode.RightControl) then window:Minimize() end
        if event.KeyCode==Enum.KeyCode.Escape and window.Popup then window:ClosePopup() end
    end)
    bind(search:GetPropertyChangedSignal('Text'),function()
        local query=string.lower(search.Text)
        local first,selectedHasRows
        for _,tab in ipairs(window.Tabs) do
            local count=0
            for _,entry in ipairs(tab.Rows) do
                local match=query=='' or string.find(entry.Search,query,1,true)~=nil
                entry.Frame.Visible=match;if match then count+=1 end
            end
            local visible=query=='' or count>0
            tab.Button.Visible=visible
            if visible and not first then first=tab end
            if tab==window.Selected and visible then selectedHasRows=true end
        end
        if not selectedHasRows then
            if first then window:SelectTab(first)
            elseif window.Selected then window.Selected.Page.Visible=false end
        elseif window.Selected then window.Selected.Page.Visible=true end
        empty.Visible=not first
    end)
    function window:Resize()
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1100,700)
        local requested=self.RequestedSize
        local width=math.max(1,math.min(requested.X.Scale*viewport.X+requested.X.Offset,viewport.X-24))
        local height=math.max(1,math.min(requested.Y.Scale*viewport.Y+requested.Y.Offset,viewport.Y-24))
        self.Scale=math.min(self.Zoom,width/360,height/280)
        self.Width=width/self.Scale
        self.Height=height/self.Scale
        frame.Size=UDim2.fromOffset(self.Width,self.Height);scale.Scale=self.Scale
        local side=self.Width<520 and 56 or self.Width<760 and 126 or 152
        sidebar.Size=UDim2.new(0,side,1,-100);content.Position=UDim2.fromOffset(side,56);content.Size=UDim2.new(1,-side,1,-100)
        for _,tab in ipairs(self.Tabs) do tab.Caption.Visible=side>60 end
        local compact=self.Width-side<540
        pageTitle.Visible=not compact
        search.Position=compact and UDim2.fromOffset(14,15) or UDim2.new(1,-267,0,16)
        search.Size=compact and UDim2.new(1,-28,0,36) or UDim2.fromOffset(245,36)
        pages.Position=UDim2.fromOffset(compact and 14 or 22,65);pages.Size=UDim2.new(1,compact and -28 or -44,1,-80)
        map.Visible=self.Width>=590;ready.Visible=self.Width>=650
        self:SetPosition(Vector2.new(frame.Position.X.Offset,frame.Position.Y.Offset))
        if self.OnResize then call(self.OnResize,self.Width-side-44) end
    end
    function window:SetZoom(value)
        self.Zoom=math.clamp(tonumber(value) or self.Zoom,0.8,1.5)
        self:ClosePopup();self:Resize()
    end
    function window:SetSize(size)
        self.RequestedSize=size;self:ClosePopup();self:Resize()
    end
    local cameraConnection
    local function watchCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then cameraConnection=bind(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),function() window:Resize() end) end
        window:Resize()
    end
    bind(workspace:GetPropertyChangedSignal('CurrentCamera'),watchCamera)
    watchCamera();window:ResetPosition()
    window.Overview=window:AddTab({Title='ภาพรวม'})
    return window
end

Library.ApiVersion=2
function Library:InstallThaiDisplay()
    if self.ThaiInstalled then return end
    installThaiDisplay(self,thaiDictionary)
    self.ThaiInstalled=true
end
function Library:AttachNeedleDashboard(window,state,remotes,player,savedOptions)
    return attachDashboard(self,window,state,remotes,player,savedOptions)
end
return Library
