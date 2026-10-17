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
