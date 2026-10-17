import fs from 'node:fs';
const read=name=>fs.readFileSync(new URL(name,import.meta.url),'utf8');
const controls=read('./src/controls.luau');
const core=read('./src/core.luau');
const localize=read('./src/localize.luau');
const dashboard=read('./src/dashboard.luau');
const literal=value=>typeof value==='string'?JSON.stringify(value):'{'+Object.entries(value).map(([key,item])=>`[${JSON.stringify(key)}]=${literal(item)}`).join(',')+'}';
const dictionary=literal(JSON.parse(read('./src/thai.json')));
const api=`
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
`;
fs.writeFileSync(new URL('./main.lua',import.meta.url),`-- iNo Needle UI | Custom dark/lime interface\nlocal buildControls=(function()\n${controls}\nend)()\nlocal installThaiDisplay=(function()\n${localize}\nend)()\nlocal thaiDictionary=${dictionary}\nlocal attachDashboard=(function()\n${dashboard}\nend)()\n${core.replace(/\nreturn Library\s*$/,'')}\n${api}`);
console.log('Built independent iNo UI library');
