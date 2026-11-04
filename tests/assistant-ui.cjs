// Read-only API and mocked UI regression. This suite never calls paid Gemini generation.
const path=require('node:path');const assert=require('node:assert/strict');
const {chromium,request}=require(process.env.NEXUS_PLAYWRIGHT_MODULE || 'playwright');
const base=process.env.NEXUS_TEST_URL || 'http://127.0.0.1:8000';
(async()=>{
 const anon=await request.newContext({baseURL:base});assert.equal((await anon.get('/api/assistant/status')).status(),401);await anon.dispose();
 const api=await request.newContext({baseURL:base});const login=await(await api.post('/api/login',{data:{username:'user3',password:'12345'}})).json();
 assert(login.csrf_token);const headers={'X-CSRF-Token':login.csrf_token};
 assert.equal((await api.post('/api/assistant/chat',{data:{message:'missing token'}})).status(),403);
 assert.equal((await api.post('/api/assistant/index',{headers,data:{}})).status(),403);
 assert.equal((await api.post('/api/assistant/chat',{headers,data:{message:'x',request_id:'../bad'}})).status(),422);
 const status=(await(await api.get('/api/assistant/status')).json()).data;const book=status.books.find(book=>book.status==='ready');assert(book,'Index at least one PDF first');
 const browser=await chromium.launch({executablePath:process.env.NEXUS_CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
 try {
  const page=await browser.newPage({viewport:{width:1440,height:1000}});const errors=[];page.on('pageerror',error=>errors.push(error.message));
  await page.goto(base);await page.locator('#login-screen').waitFor({state:'visible'});await page.locator('[name=username]').fill('user3');await page.locator('[name=password]').fill('12345');await page.locator('#login-form button').click();await page.locator('.stat-card').first().waitFor();
  await page.locator('.main-nav [data-view=assistant]').click();await page.locator('.study-book-option').first().waitFor();
  const text='**Nội dung kiểm thử UI** <img src=x onerror="window.__unsafe=true"> 【S1】\n| Ngày | Mục tiêu |\n|---|---|\n| 1 | Học kiến thức |';
  const source={id:'S1',book_id:book.id,title:book.title,page:1,excerpt:'Trích đoạn giả lập chỉ dành cho kiểm thử giao diện.'};
  await page.route('**/api/assistant/chat',route=>{
   const body=route.request().postDataJSON();const reply={role:'assistant',text,sources:[source],grounding:'partial',coverage:'retrieved_passages',follow_ups:['Tôi nên đọc tiếp gì?']};
   return route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({data:{thread:{id:'a'.repeat(32),title:'UI test',mode:'ask',book_ids:[],messages:[{role:'user',text:body.message},reply]},reply}})});
  });
  await page.locator('#study-input').fill('Kiểm thử hiển thị');await page.locator('#study-send').click();await page.locator('.from-assistant').waitFor();
  assert.equal(await page.locator('.study-table-wrap table tbody tr').count(),1);assert.equal(await page.locator('.study-prose img').count(),0);assert.equal(await page.evaluate(()=>window.__unsafe),undefined);
  const popup=page.waitForEvent('popup');await page.locator('.study-citation').click();const reader=await popup;assert(reader.url().includes(`book_id=${book.id}&page=1`));await reader.close();
  await page.unroute('**/api/assistant/chat');await page.route('**/api/assistant/chat',route=>route.fulfill({status:503,contentType:'application/json',body:JSON.stringify({message:'Lỗi mạng giả lập'})}));
  await page.locator('#study-input').fill('Giữ câu hỏi này');await page.locator('#study-send').click();await page.locator('#study-error:not(.is-hidden)').waitFor();assert.equal(await page.locator('#study-input').inputValue(),'Giữ câu hỏi này');assert(await page.locator('#study-send').isEnabled());
  for(const width of [1024,1280,1440,1920]){await page.setViewportSize({width,height:1000});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);}
  assert.deepEqual(errors,[]);console.log('PASS assistant authorization, CSRF, safe rendering, PDF links, retry draft and desktop layout (mocked AI; zero inference calls).');
 } finally {await browser.close();await api.dispose();}
})().catch(error=>{console.error(error);process.exit(1);});
