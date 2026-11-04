const {request,chromium}=require('C:/Users/Dell Gaming/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('node:fs');const path=require('node:path');
(async()=>{
 const api=await request.newContext({baseURL:'http://127.0.0.1:8000',timeout:100000});
 const login=await(await api.post('/api/login',{data:{username:'user3',password:'12345'}})).json();
 const payload={goal:'Tôi muốn làm đồ án cơ sở dữ liệu: thiết kế bảng, viết SQL và kiểm tra dữ liệu.',weeks:3,minutes:45,level:'intermediate',request_id:require('node:crypto').randomBytes(16).toString('hex')};
 const savedOnly=process.argv.includes('--saved');
 const response=savedOnly?await api.get('/api/assistant/learning-kit'):await api.post('/api/assistant/learning-kit',{headers:{'X-CSRF-Token':login.csrf_token},data:payload});const result=await response.json();
 console.log(JSON.stringify({status:response.status(),message:result.message,books:result.data?.books?.map(b=>({id:b.id,title:b.title,available:b.available_copies})),weeks:result.data?.weeks?.length,sources:result.data?.sources?.length}));
 if(!response.ok()){await api.dispose();process.exitCode=1;return;}
 const cached=(await(await api.get('/api/assistant/learning-kit')).json()).data;
 if(cached.goal!==payload.goal||cached.books.length!==result.data.books.length)throw new Error('Saved kit mismatch');
 if(!savedOnly){const repeat=await api.post('/api/assistant/learning-kit',{headers:{'X-CSRF-Token':login.csrf_token},data:payload});if(!repeat.ok())throw new Error('Replay failed');}
 const other=await request.newContext({baseURL:'http://127.0.0.1:8000'});await other.post('/api/login',{data:{username:'user2',password:'12345'}});
 const own=(await(await other.get('/api/assistant/learning-kit')).json()).data;
 const forged=(await(await other.get('/api/assistant/learning-kit?user_id='+login.user.id)).json()).data;
 if(JSON.stringify(own)!==JSON.stringify(forged))throw new Error('Owner isolation failed');await other.dispose();
 const browser=await chromium.launch({channel:'chrome',headless:true});const context=await browser.newContext({storageState:await api.storageState(),viewport:{width:1440,height:1000}});const page=await context.newPage();
 await page.goto('http://127.0.0.1:8000/#assistant');await page.locator('#learning-kit summary').click();
 await page.locator('.kit-book').first().waitFor();await page.evaluate(()=>document.fonts.ready);
 const out=path.join(__dirname,'../.impeccable/review/learning-kit');fs.mkdirSync(out,{recursive:true});await page.screenshot({path:path.join(out,'live-kit-1440.png'),fullPage:true});
 console.log(savedOnly?'PASS saved plan reload and account isolation; zero inference calls.':'PASS live generation, saved plan reload, idempotent replay and account isolation. No loan submitted.');
 await browser.close();await api.dispose();
})().catch(e=>{console.error(e.message);process.exitCode=1});
