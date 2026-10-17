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
        ctx.Padding(frame,14)
        ctx.List(frame,7)
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
local Library={Options={},Unloaded=false,Version='iNo UI 1.0',Connections={}}
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
local symbols={['ภาพรวม']='⌂',['เก็บฟาง']='≋',['เพชร']='◇',['เครื่องมือ']='⚒',['ร้านค้า']='▱',['อัปเกรด']='↗',['เป้าหมายด่าน']='◎',['ไฮไลต์']='◉',['เล่นใหม่']='↻',['สถิติ']='▥',['ตั้งค่า']='⚙'}

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
    local window={Tabs={},Rows={},Selected=nil,Scale=1,Visible=true}
    self.Window=window
    local frame=make('Frame',{Name='Window',Size=UDim2.fromOffset(1000,650),BackgroundColor3=C.Background,ClipsDescendants=false,Active=true},gui)
    window.Root=frame;round(frame,12);stroke(frame,C.Line)
    local scale=make('UIScale',{Scale=1},frame)
    local header=make('Frame',{Name='Header',Size=UDim2.new(1,0,0,64),BackgroundTransparency=1},frame)
    make('Frame',{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=C.Line,BorderSizePixel=0},header)
    local dragHandle=make('TextButton',{Name='DragWindow',Text='',Size=UDim2.new(1,-105,1,0),BackgroundTransparency=1},header)
    local logo=make('ImageLabel',{Name='BrandIcon',Size=UDim2.fromOffset(39,39),Position=UDim2.fromOffset(18,12),BackgroundColor3=C.Selected,Image='',ScaleType=Enum.ScaleType.Fit},header);round(logo,9)
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
    local sidebar=make('Frame',{Name='Sidebar',Position=UDim2.fromOffset(0,64),Size=UDim2.new(0,176,1,-116),BackgroundColor3=C.Sidebar,BorderSizePixel=0},frame)
    local nav=make('ScrollingFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Line,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},sidebar)
    padding(nav,10);list(nav,5)
    local content=make('Frame',{Name='Main',Position=UDim2.fromOffset(176,64),Size=UDim2.new(1,-176,1,-116),BackgroundTransparency=1},frame)
    local pageTitle=label(content,'ภาพรวม',24,C.Text);pageTitle.Position=UDim2.fromOffset(23,16);pageTitle.Size=UDim2.new(1,-320,0,36);pageTitle.Font=Enum.Font.GothamBold
    local search=make('TextBox',{Name='Search',Text='',PlaceholderText='ค้นหาฟังก์ชัน...',Size=UDim2.fromOffset(245,36),Position=UDim2.new(1,-267,0,16),BackgroundColor3=C.Input,TextColor3=C.Text,PlaceholderColor3=C.Muted,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false},content)
    padding(search,11);round(search,7);stroke(search,C.Line)
    local pages=make('Frame',{Name='Pages',Position=UDim2.fromOffset(22,65),Size=UDim2.new(1,-44,1,-80),BackgroundTransparency=1},content)
    local empty=label(pages,'ไม่พบฟังก์ชันที่ค้นหา',14,C.Muted);empty.Size=UDim2.new(1,0,0,60);empty.Visible=false
    local footer=make('Frame',{Name='Footer',Position=UDim2.new(0,0,1,-52),Size=UDim2.new(1,0,0,52),BackgroundTransparency=1},frame)
    make('Frame',{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Line,BorderSizePixel=0},footer)
    local ready=label(footer,'●  กำลังเชื่อมข้อมูล',12,C.Muted);ready.Position=UDim2.fromOffset(18,14);ready.Size=UDim2.new(1,-320,0,24)
    window.StatusLabel=ready
    local function footerButton(text,x,width,color)
        local button=make('TextButton',{Text=text,Position=UDim2.new(1,x,0,9),Size=UDim2.fromOffset(width,34),BackgroundColor3=color,TextColor3=C.Text,TextSize=12,Font=Enum.Font.Gotham},footer)
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
        local symbol=label(tab.Button,symbols[tab.Title] or '·',20,C.Muted);symbol.Size=UDim2.fromOffset(27,44);symbol.Position=UDim2.fromOffset(6,0)
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
            other.Caption.TextColor3=on and C.Lime or C.Muted;other.Symbol.TextColor3=other.Caption.TextColor3
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
        if isPointer(event) then window.Drag={Input=event,Start=Vector2.new(event.Position.X,event.Position.Y),Origin=frame.AbsolutePosition} end
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
            call(window.OnPositionChanged,{x=frame.AbsolutePosition.X/math.max(1,viewport.X),y=frame.AbsolutePosition.Y/math.max(1,viewport.Y)})
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
        self.Width=math.min(1000,math.max(360,viewport.X-24));self.Height=math.min(650,math.max(430,viewport.Y-36))
        self.Scale=math.min(1,(viewport.X-18)/self.Width,(viewport.Y-24)/self.Height)
        frame.Size=UDim2.fromOffset(self.Width,self.Height);scale.Scale=self.Scale
        local side=self.Width<760 and 126 or 176
        sidebar.Size=UDim2.new(0,side,1,-116);content.Position=UDim2.fromOffset(side,64);content.Size=UDim2.new(1,-side,1,-116)
        local compact=self.Width<760
        pageTitle.Visible=not compact
        search.Position=compact and UDim2.fromOffset(14,15) or UDim2.new(1,-267,0,16)
        search.Size=compact and UDim2.new(1,-28,0,36) or UDim2.fromOffset(245,36)
        pages.Position=UDim2.fromOffset(compact and 14 or 22,65);pages.Size=UDim2.new(1,compact and -28 or -44,1,-80)
        map.Visible=self.Width>=590;ready.Visible=self.Width>=650
        self:SetPosition(Vector2.new(frame.Position.X.Offset,frame.Position.Y.Offset))
        if self.OnResize then call(self.OnResize,self.Width-side-44) end
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
return Library
