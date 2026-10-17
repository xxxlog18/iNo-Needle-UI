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
