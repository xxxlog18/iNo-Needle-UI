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
