const assert=require('node:assert/strict');
const fs=require('node:fs');const path=require('node:path');
const {chromium,request}=require(process.env.NEXUS_PLAYWRIGHT_MODULE||'C:/Users/Dell Gaming/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const base=process.env.NEXUS_TEST_URL||'http://127.0.0.1:8000';
const out=path.join(__dirname,'../.impeccable/review/learning-kit');fs.mkdirSync(out,{recursive:true});
(async()=>{
 const anon=await request.newContext({baseURL:base});assert.equal((await anon.get('/api/assistant/learning-kit')).status(),401);await anon.dispose();
 const api=await request.newContext({baseURL:base});const login=await(await api.post('/api/login',{data:{username:'user3',password:'12345'}})).json();
 const headers={'X-CSRF-Token':login.csrf_token};
 assert.equal((await api.post('/api/assistant/learning-kit',{data:{}})).status(),403);
 for(const data of [{goal:'ngắn'}, {goal:'Cơ sở dữ liệu',weeks:'3',minutes:45,level:'beginner'}, {goal:'Cơ sở dữ liệu',weeks:13,minutes:45,level:'beginner'}, {goal:'Cơ sở dữ liệu',weeks:3,minutes:1,level:'beginner'}, {goal:'Cơ sở dữ liệu',weeks:3,minutes:45,level:[]}]) {
  assert.equal((await api.post('/api/assistant/learning-kit',{headers,data:{request_id:'a'.repeat(32),...data}})).status(),422);
 }
 const actual=(await(await api.get('/api/books')).json()).data.find(b=>Number(b.available_copies)>0);
 assert(actual,'Need an available real book');
 const data={goal:'Hoàn thành đồ án cơ sở dữ liệu trong 3 tuần',weeks_count:3,minutes:45,level:'intermediate',created_at:new Date().toISOString(),intro:'Gợi ý học tập. <img src=x onerror="window.__kitUnsafe=true">',books:[{id:Number(actual.id),title:actual.title,authors:actual.authors,reason:'Phù hợp mục tiêu thiết kế dữ liệu.',reading_focus:'Mô hình và truy vấn',source_ids:[],available_copies:Number(actual.available_copies),has_ebook:Boolean(actual.has_ebook)}],weeks:[1,2,3].map(week=>({week,focus:`Giai đoạn ${week}`,task:'Thực hành và tự kiểm tra kết quả.',book_ids:[Number(actual.id)],source_ids:[]})),sources:[]};
 const browser=await chromium.launch({channel:'chrome',headless:true});
 try {
  const page=await browser.newPage({viewport:{width:1440,height:1000}});const errors=[];page.on('pageerror',e=>errors.push(e.message));let submitted=0;
  page.on('request',r=>{if(r.method()==='POST'&&/\/api\/(book-loan-requests|equipment-loan-requests)/.test(r.url()))submitted++});
  let releaseSaved;const savedGate=new Promise(resolve=>{releaseSaved=resolve;});
  await page.route('**/api/assistant/learning-kit',async route=>{
   if(route.request().method()==='GET'){await savedGate;return route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({data:{...data,goal:'Mục tiêu cũ đã lưu từ trước',minutes:90}})});}
   return route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({data})});
  });
  await page.goto(base);await page.locator('[name=username]').fill('user3');await page.locator('[name=password]').fill('12345');await page.locator('#login-form button').click();
  await page.locator('.kit-entry').waitFor();await page.locator('.kit-entry').click();
  await page.locator('#kit-goal').fill(data.goal);await page.locator('#kit-level').selectOption('intermediate');
  releaseSaved();await page.locator('.kit-book').waitFor();assert.equal(await page.locator('#kit-goal').inputValue(),data.goal);assert.equal(await page.locator('#kit-minutes').inputValue(),'45');
  await page.locator('#kit-create').click();await page.locator('.kit-book').waitFor();
  assert.equal(await page.locator('.kit-week').count(),3);assert.equal(await page.locator('#kit-results img').count(),0);assert.equal(await page.evaluate(()=>window.__kitUnsafe),undefined);
  assert.equal(await page.locator('#kit-add-cart').isEnabled(),true);
  await page.locator('.study-book-option').first().waitFor();await page.evaluate(()=>document.fonts.ready);await page.waitForTimeout(3000);
  for(const width of [1024,1280,1440,1920]) {await page.setViewportSize({width,height:1000});await page.evaluate(()=>{document.activeElement.blur();window.scrollTo(0,0);});await page.waitForTimeout(100);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);await page.screenshot({path:path.join(out,`mock-kit-${width}.png`),fullPage:true});}
  await page.locator('#kit-add-cart').click();await page.waitForFunction(()=>state.currentView==='requests');
  assert.equal(await page.locator('[data-remove-book-request]').count(),1);assert.equal(submitted,0);
  await page.locator('[data-remove-book-request]').click();
  await page.evaluate(()=>setView('assistant'));
  await page.locator('#kit-create').click();await page.waitForFunction(()=>!learningKit.busy);
  const detail=(await(await api.get(`/api/books/${actual.id}`)).json()).data;
  await page.route(`**/api/books/${actual.id}`,route=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({data:{...detail,copies:[]}})}));
  await page.locator('#kit-add-cart').click();await page.locator('#kit-error:not(.is-hidden)').waitFor();
  assert.equal(await page.locator('#kit-add-cart').isEnabled(),false);assert.equal(await page.evaluate(()=>state.bookRequestItems.length),0);
  assert((await page.locator('.kit-book-actions').textContent()).includes('Hiện hết bản giấy'));
  await page.unroute(`**/api/books/${actual.id}`);
  await page.locator('#kit-goal').fill('Giữ mục tiêu này khi dịch vụ AI gặp lỗi');
  await page.unroute('**/api/assistant/learning-kit');
  await page.route('**/api/assistant/learning-kit',route=>route.fulfill({status:503,contentType:'application/json',body:JSON.stringify({message:'Lỗi dịch vụ giả lập'})}));
  await page.locator('#kit-create').click();await page.locator('#kit-error:not(.is-hidden)').waitFor();
  assert.equal(await page.locator('#kit-goal').inputValue(),'Giữ mục tiêu này khi dịch vụ AI gặp lỗi');assert.equal(await page.locator('.kit-book').count(),1);assert(await page.locator('#kit-create').isEnabled());
  await page.screenshot({path:path.join(out,'mock-error-1920.png'),fullPage:true});
  await page.unroute('**/api/assistant/learning-kit');await page.route('**/api/assistant/learning-kit',route=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({data:{...data,intro:'Chưa tìm thấy sách phù hợp trong kho.',books:[],weeks:[]}})}));
  await page.locator('#kit-create').click();await page.waitForFunction(()=>document.querySelector('#kit-results .empty-state'));
  assert.equal(await page.locator('#kit-add-cart').count(),0);
  await page.evaluate(()=>setUser(null));assert.equal(await page.locator('#kit-results').textContent(),'');
  assert.deepEqual(errors,[]);console.log('PASS kit authentication, CSRF, input boundaries, safe UI, desktop widths, add-to-cart without submission, stale stock, delayed-load draft protection, error draft retention, no-match and owner reset (mocked AI).');
 }finally{await browser.close();await api.dispose();}
})().catch(e=>{console.error(e);process.exit(1)});
