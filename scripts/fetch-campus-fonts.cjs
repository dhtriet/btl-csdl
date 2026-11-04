const fs = require('node:fs/promises');
const path = require('node:path');
async function download(url) {
 const response=await fetch(url,{headers:{'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'}});
 if(!response.ok)throw new Error(`Font source returned ${response.status}`);
 return response;
}
async function main() {
 const folder=path.join(__dirname,'../public/assets/fonts');await fs.mkdir(folder,{recursive:true});
 const source='https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Manrope:wght@500;600;700;800&display=swap';
 const css=await (await download(source)).text();
 const blocks=[...css.matchAll(/\/\* (vietnamese|latin-ext|latin) \*\/\s*(@font-face\s*\{[^}]+\})/g)];
 if(blocks.length<2)throw new Error('Expected Latin and Vietnamese font subsets');
 const urls=new Map();let output='/* Self-hosted Google Fonts; SIL Open Font License, see adjacent license files. */\n';
 for(const [,subset,block] of blocks) {
  const url=block.match(/url\(([^)]+)\)/)[1];
  const family=block.includes('Be Vietnam Pro')?'be-vietnam-pro':'manrope';
  if(!urls.has(url)) {
   const name=`${family}-${subset}-${urls.size+1}.woff2`;
   const data=Buffer.from(await (await download(url)).arrayBuffer());
   if(data.toString('ascii',0,4)!=='wOF2')throw new Error('Expected WOFF2 font data');
   await fs.writeFile(path.join(folder,name),data);urls.set(url,name);
  }
  output+=`/* ${subset} */\n${block.replace(url,'/assets/fonts/'+urls.get(url))}\n`;
 }
 for(const family of ['bevietnampro','manrope']) await fs.writeFile(path.join(folder,`${family}-OFL.txt`),await (await download(`https://raw.githubusercontent.com/google/fonts/main/ofl/${family}/OFL.txt`)).text());
 await fs.writeFile(path.join(folder,'campus-fonts.css'),output);
 console.log(`Saved ${urls.size} WOFF2 files with Vietnamese/Latin subsets and both licenses.`);
}
main().catch(e=>{console.error(e.message);process.exitCode=1});
