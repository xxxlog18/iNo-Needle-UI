import fs from 'node:fs';
const read=name=>fs.readFileSync(new URL(name,import.meta.url),'utf8');
const controls=read('./src/controls.luau');
const core=read('./src/core.luau');
fs.writeFileSync(new URL('./main.lua',import.meta.url),`-- iNo Needle UI | Custom dark/lime interface\nlocal buildControls=(function()\n${controls}\nend)()\n${core}`);
console.log('Built independent iNo UI library');
