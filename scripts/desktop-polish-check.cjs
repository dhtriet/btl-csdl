const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require(process.env.NEXUS_PLAYWRIGHT_MODULE || 'C:/Users/Dell Gaming/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const out = path.join(__dirname, '../.impeccable/review/desktop-polish');
fs.mkdirSync(out, { recursive: true });
async function main() {
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const page=await browser.newPage({viewport:{width:1440,height:1000}});
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 let writes=0;page.on('request',r=>{if(r.method()!=='GET'&&!/\/api\/(login|logout)/.test(r.url())&&r.url().includes('/api/'))writes++});
 const assert=(value,label)=>{if(!value)throw new Error(label);console.log('PASS '+label)};
 await page.goto('http://127.0.0.1:8000');
 await page.locator('[name=username]').fill('user3');await page.locator('[name=password]').fill('12345');await page.locator('#login-form button').click();
 await page.locator('body[data-role=student]').waitFor();await page.waitForTimeout(3000);
 await page.evaluate(()=>setView('requests'));await page.waitForTimeout(400);
 assert(!await page.locator('#submit-book-request').isVisible()&&!await page.locator('#submit-equipment-request').isVisible(),'empty carts hide submit actions');
 assert(!await page.locator('#book-request-note').isVisible(),'empty cart hides optional note');
 await page.locator('[data-cart-start=catalog]').click();await page.locator('[data-add-book-id]:not([disabled])').first().waitFor();
 assert(await page.evaluate(()=>state.currentView)==='catalog','empty book cart opens catalog');
 await page.locator('[data-add-book-id]:not([disabled])').first().click();
 await page.locator('#book-request-form button[type=submit]').click();
 await page.evaluate(()=>setView('requests'));await page.waitForTimeout(300);
 assert(await page.locator('#submit-book-request').isVisible()&&await page.locator('#book-request-note').isVisible(),'adding book reveals complete request form');
 await page.screenshot({path:path.join(out,'book-cart-populated.png'),fullPage:true});
 await page.locator('[data-remove-book-request]').click();
 assert(!await page.locator('#submit-book-request').isVisible(),'removing last book restores empty state');
 await page.locator('[data-cart-start=equipment]').click();await page.locator('[data-add-equipment-id]').first().click();
 await page.locator('#equipment-request-form button[type=submit]').click();
 await page.evaluate(()=>setView('requests'));await page.waitForTimeout(300);
 assert(await page.locator('#submit-equipment-request').isVisible(),'adding equipment reveals request form');
 await page.locator('[data-remove-equipment-request]').click();
 assert(!await page.locator('#submit-equipment-request').isVisible(),'removing last equipment restores empty state');
 const tone=await page.locator('#my-borrow-requests em.is-approved').first().evaluate(e=>getComputedStyle(e).backgroundColor);
 assert(tone==='rgb(226, 235, 213)','approved requests use green status');
 await page.evaluate(()=>setView('spaces'));await page.waitForTimeout(500);
 for(const field of ['room-date','room-start','room-end','room-type','room-capacity']) {
  const box=await page.locator(`label[for=${field}]`).boundingBox();assert(box.width>20&&box.height>10,'visible room label '+field);
 }
 await page.locator('#room-start').fill('12:00');await page.locator('#room-end').fill('10:00');await page.locator('#room-search-button').click();
 assert((await page.locator('#room-search-context').textContent()).includes('chưa hợp lệ'),'invalid room time has persistent feedback');
 await page.locator('#room-start').fill('08:00');await page.locator('#room-end').fill('10:00');await page.locator('#room-search-button').click();
 await page.waitForFunction(()=>document.querySelector('#room-search-context').textContent.includes('08:00–10:00'));
 assert(true,'room results recap checked time range');
 const widths=process.argv.includes('quick')?[1024,1440]:[1024,1280,1440,1920];
 for(const width of widths) {
  await page.setViewportSize({width,height:1000});
  for(const view of ['dashboard','catalog','requests','spaces','equipment','circulation','assistant']) {
   await page.evaluate(v=>setView(v),view);await page.waitForTimeout(450);
   assert(!await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1),view+' fits '+width);
   await page.screenshot({path:path.join(out,`${view}-${width}.png`),fullPage:true});
  }
 }
 assert(writes===0,'no resource writes or AI calls');assert(errors.length===0,'no JavaScript errors');
 fs.writeFileSync(path.join(out,'results.json'),JSON.stringify({widths,views:7,errors,resourceWrites:writes},null,2));
 await browser.close();
}
main().catch(e=>{console.error(e);process.exit(1)});
