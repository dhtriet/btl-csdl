const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require(process.env.NEXUS_PLAYWRIGHT_MODULE || 'C:/Users/Dell Gaming/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(__dirname, '..');
const out = path.join(root, '.impeccable/review');
fs.mkdirSync(out, { recursive: true });
async function main() {
 const browser = await chromium.launch({channel:'chrome', headless:true});
 const page = await browser.newPage({viewport:{width:1440,height:1000}});
 const errors=[]; page.on('pageerror',e=>errors.push(e.message));
 if(process.argv.includes('previews')) {
  await page.setViewportSize({width:1440,height:900});
  for(const name of ['mono-v2','campus-v2','grid-v2']) {
   const file=path.join(root,`.impeccable/mocks/decision/${name}.html`);
   const content=fs.readFileSync(file,'utf8'); fs.writeFileSync(file,content);
   await page.goto('file:///'+file.replaceAll('\\','/'));
   await page.evaluate(()=>document.fonts.ready);
   await page.screenshot({path:path.join(out,`${name}.png`)});
   console.log(JSON.stringify({name,overflow:await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth)}));
  }
  await browser.close(); return;
 }
 await page.goto('http://127.0.0.1:8000');
 if(process.argv.includes('verify') || process.argv.includes('final')) {
  for(const width of [1440,390]) { await page.setViewportSize({width,height:900}); await page.screenshot({path:path.join(out,`login-${width}.png`),fullPage:true}); }
  await page.setViewportSize({width:1440,height:1000});
 }
 await page.locator('#login-form input[name=username]').fill('user3');
 await page.locator('#login-form input[name=password]').fill('12345');
 await page.locator('#login-form button').click();
 await page.locator('body[data-role=student]').waitFor();
 await page.waitForTimeout(3000);
 if(process.argv.includes('final')) {
  for(const [width,view] of [[1440,'dashboard'],[390,'dashboard'],[390,'equipment']]) {
   await page.setViewportSize({width,height:width===390?844:1000});
   await page.evaluate(v=>setView(v),view); await page.waitForTimeout(500);
   await page.screenshot({path:path.join(out,`${view}-${width}.png`),fullPage:true});
   if(view==='dashboard')fs.copyFileSync(path.join(out,`${view}-${width}.png`),path.join(out,width===1440?'desktop.png':'mobile.png'));
  }
  await page.evaluate(()=>setView('circulation')); await page.waitForTimeout(500);
  await page.locator('#view-circulation [data-campus-find-book]').click();
  if(await page.evaluate(()=>state.currentView)!=='catalog')throw new Error('empty circulation CTA failed');
  console.log('PASS circulation empty-state CTA');
  console.log(JSON.stringify({errors})); await browser.close(); return;
 }
 if(process.argv.includes('verify')) {
  const assert=(test,message)=>{if(!test)throw new Error(message);console.log('PASS '+message)};
  await page.locator('#dashboard-book-search').fill('Clean Code');
  await page.locator('#dashboard-search button').click();
  await page.waitForTimeout(500);
  assert(await page.locator('.book-card').count()===1,'dashboard search filters catalog');
  await page.locator('[data-book-id]').first().click();
  await page.locator('#book-modal:not(.is-hidden)').waitFor();
  await page.screenshot({path:path.join(out,'book-dialog-1440.png')});
  await page.keyboard.press('Escape');
  assert(await page.locator('#book-modal').evaluate(e=>e.classList.contains('is-hidden')),'Escape closes book dialog');
  await page.locator('[data-add-book-id]').first().click();
  await page.locator('#resource-request-modal:not(.is-hidden)').waitFor();
  await page.setViewportSize({width:390,height:844});
  await page.screenshot({path:path.join(out,'request-dialog-390.png')});
  assert(!await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),'request dialog fits mobile');
  await page.keyboard.press('Escape');
  await page.locator('#campus-menu').click();
  assert(await page.locator('#campus-menu').getAttribute('aria-expanded')==='true','mobile menu opens');
  assert(await page.evaluate(()=>document.activeElement.matches('.main-nav .nav-item')),'mobile menu receives keyboard focus');
  await page.screenshot({path:path.join(out,'menu-390.png'),fullPage:true});
  await page.locator('.main-nav [data-view=spaces]').click();
  assert(await page.locator('#campus-menu').getAttribute('aria-expanded')==='false','mobile menu closes after navigation');
  await page.waitForTimeout(500);
  await page.locator('[data-request-room-id]').first().click();
  await page.locator('#room-request-modal:not(.is-hidden)').waitFor();
  await page.screenshot({path:path.join(out,'room-dialog-390.png')});
  await page.keyboard.press('Escape');
  await page.evaluate(()=>setView('dashboard')); await page.waitForTimeout(500);
  await page.locator('[data-campus-book]').first().click(); await page.waitForTimeout(500);
  assert(await page.locator('.book-card').count()>0 && await page.locator('#book-search').inputValue()!=='','popular book opens filtered catalog');
  await page.locator('#book-search').fill('zzzz-no-book'); await page.locator('#book-search-button').click(); await page.waitForTimeout(500);
  assert(await page.locator('#book-grid .empty-state').count()===1,'catalog empty result is shown');
  await page.evaluate(()=>setView('assistant')); await page.waitForTimeout(600);
  await page.locator('[data-study-mode=roadmap]').click();
  assert(await page.locator('[data-study-mode=roadmap]').getAttribute('aria-pressed')==='true','assistant mode switches');
  await page.evaluate(()=>setView('catalog')); await page.waitForTimeout(500);
  await page.locator('#book-search').fill('');
  await page.setViewportSize({width:1440,height:1000});
  for(const username of ['user2','user1','user3']) {
   await page.locator('#logout-button').evaluate(e=>e.click());
   await page.locator('#login-screen:not(.is-hidden)').waitFor();
   await page.locator('#login-form input[name=username]').fill(username); await page.locator('#login-form input[name=password]').fill('12345'); await page.locator('#login-form button').click();
   await page.locator('#app-shell:not(.is-hidden)').waitFor(); await page.waitForTimeout(600);
   assert(await page.locator('#dashboard-heading').textContent()!=='','role switch '+username+' preserves dashboard');
   if(username!=='user3'){await page.evaluate(()=>setView('manage')); await page.waitForTimeout(600); await page.screenshot({path:path.join(out,`${username}-manage.png`),fullPage:true});}
  }
  assert(await page.locator('.campus-layout').count()===1,'student layout restored after role changes');
  assert(await page.evaluate(()=>document.fonts.check('400 14px "Be Vietnam Pro"') && document.fonts.check('700 30px Manrope')),'chosen fonts loaded');
  assert(await page.evaluate(()=>performance.getEntriesByType('resource').filter(r=>/fonts\.(googleapis|gstatic)\.com/.test(r.name)).length)===0,'no external Google Fonts request');
  console.log(JSON.stringify({errors})); await browser.close(); return;
 }
 const before=process.argv.includes('before');
 if(before) { await page.screenshot({path:path.join(out,'before-desktop.png'),fullPage:true}); }
 else {
  for(const width of [1440,1024,390]) {
   await page.setViewportSize({width,height:width===390?844:1000});
   for(const view of ['dashboard','catalog','spaces','equipment','requests','circulation','assistant']) {
    await page.evaluate(v=>setView(v),view); await page.waitForTimeout(700);
    if(view==='catalog') await page.locator('.book-card').first().waitFor();
    await page.screenshot({path:path.join(out,`${view}-${width}.png`),fullPage:true});
    const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1);
    console.log(JSON.stringify({width,view,overflow}));
   }
  }
 }
 console.log(JSON.stringify({errors})); await browser.close();
}
main().catch(e=>{console.error(e);process.exit(1)});
