const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const os=require('node:os');
const {spawn,spawnSync}=require('node:child_process');
const { chromium, request }=require(process.env.NEXUS_PLAYWRIGHT_MODULE || 'playwright');
const root=path.resolve(__dirname,'..').replaceAll('\\','/');
if (!/^resource_center_test_[0-9]+$/.test(process.env.NEXUS_DB_NAME || '')) throw new Error('Set NEXUS_DB_NAME to a dedicated resource_center_test_<digits> database.');
const fixtureFile=path.join(os.tmpdir(), `nexus-fixture-${process.pid}.json`);
const fixtureScript=path.join(__dirname,'fixtures.php');
const php=process.env.NEXUS_PHP || 'php';
const env={...process.env,NEXUS_TEST_FIXTURE_FILE:fixtureFile};
const servers=[]; const clients=[]; const results=[];
let browser;
function phpRun(args){const r=spawnSync(php,args,{env,encoding:'utf8'});if(r.status!==0)throw new Error(r.stderr);return r.stdout;}
function ok(label){results.push(label);console.log('PASS '+label);}
async function client(username,port=8011){
  const ctx=await request.newContext({baseURL:`http://127.0.0.1:${port}`}); clients.push(ctx);
  const response=await ctx.post('/api/login',{data:{username,password:username.startsWith('fixture_')?'FixturePass_123':'12345'}});
  assert.equal(response.status(),200,await response.text());const data=await response.json();
  return {ctx,token:data.csrf_token,user:data.user};
}
async function send(c,path,method='GET',data,token=true){return c.ctx.fetch(path,{method,data,headers:token?{'X-CSRF-Token':c.token}:{}});}
async function json(c,path,method='GET',data){const r=await send(c,path,method,data);assert(r.ok(),`${r.status()} ${await r.text()}`);return r.json();}
async function race(type,id,operations){
  const gate=spawn(php,[fixtureScript,'gate',type,String(id)],{env,stdio:['pipe','pipe','pipe'],windowsHide:true});
  await new Promise((resolve,reject)=>{gate.stdout.once('data',resolve);gate.once('error',reject);gate.once('exit',code=>{if(code)reject(new Error('Gate failed'));});});
  const requests=operations.map(fn=>fn());
  await new Promise(resolve=>setTimeout(resolve,450));
  gate.stdin.end('\n');
  const responses=await Promise.all(requests);
  assert.equal(responses.filter(r=>r.ok()).length,1,JSON.stringify(await Promise.all(responses.map(async r=>({status:r.status(),body:await r.text()})))));
  assert(responses.every(r=>r.ok()||[409,422].includes(r.status())),'Race errors must be handled as business conflicts');
  return responses;
}
(async()=>{
  phpRun([fixtureScript,'seed']);
  const fixture=JSON.parse(fs.readFileSync(fixtureFile,'utf8'));
  for(const port of [8011,8012]){servers.push(spawn(php,['-S',`127.0.0.1:${port}`,'-t','public'],{cwd:root,env,stdio:'ignore',windowsHide:true}));}
  const anon=await request.newContext({baseURL:'http://127.0.0.1:8011'});clients.push(anon);
  for(let i=0;i<30;i++){try{await anon.get('/');break;}catch{await new Promise(r=>setTimeout(r,100));}}
  for(const path of ['/api/books','/api/room-requests','/api/stats/books','/api/manage/books','/api/loan-receipts/1']) assert.equal((await anon.get(path)).status(),401,path);
  ok('Anonymous API access blocked');
  const student=await client('user3'),other=await client(fixture.username),staff=await client('user2'),staff2=await client('user2',8012),admin=await client('user1');
  assert.equal((await send(student,'/api/manage/books')).status(),403);
  assert.equal((await send(student,'/api/students/'+fixture.code+'/history')).status(),403);
  assert.equal((await send(student,'/api/stats/books')).status(),403);
  assert.equal((await send(staff,'/api/manage/rooms','POST',{},false)).status(),403);
  assert.equal((await staff.ctx.post('/api/login',{data:{username:'user2',password:'12345'},headers:{Origin:'https://untrusted.example'}})).status(),403);
  ok('Role, ownership, CSRF and cross-origin enforcement');
  const room=(await json(admin,'/api/manage/rooms','POST',{name:'Regression room',room_type:'classroom',location:'Test',capacity:12,status:'available'})).data;
  const changed=(await json(staff,`/api/manage/rooms/${room.id}`,'PUT',{...room,capacity:20,status:'maintenance'})).data;
  assert.equal(changed.capacity,20);
  assert.equal((await send(admin,`/api/manage/rooms/${room.id}`,'PUT',{...room,capacity:30})).status(),409);
  const book=(await json(staff,'/api/manage/books','POST',{title:'Regression title',publisher_id:fixture.publisher,language:'Tiếng Việt',publication_year:2026,pages:100,authors:['Regression author'],genres:['Regression genre'],keywords:['Regression key']})).data;
  assert.deepEqual(book.authors,['Regression author']);
  const copy=(await json(staff,'/api/manage/copies','POST',{book_id:book.id,barcode:'REG_'+Date.now(),storage_location:'Kệ A',condition_status:'good',status:'available'})).data;
  assert.equal(copy.book_id,book.id);
  assert.equal((await send(staff,'/api/manage/copies','POST',{book_id:book.id,barcode:copy.barcode,storage_location:'Kệ B',condition_status:'good',status:'available'})).status(),409);
  assert.equal((await send(staff,'/api/manage/rooms','POST',{name:'Invalid',room_type:'classroom',location:'X',capacity:-1,status:'available'})).status(),422);
  ok('Resource creation, editing, validation, duplicate barcode and stale-edit protection');
  const png=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jA1sAAAAASUVORK5CYII=','base64');
  const uploaded=await staff.ctx.post('/api/manage/cover',{headers:{'X-CSRF-Token':staff.token},multipart:{cover:{name:'cover.png',mimeType:'image/png',buffer:png}}});
  assert.equal(uploaded.status(),201,await uploaded.text());
  const coverPath=(await uploaded.json()).data.path;
  assert.match(coverPath,/^\/uploads\/covers\/[a-f0-9]{32}\.png$/);
  const withCover=(await json(staff,`/api/manage/books/${book.id}`,'PUT',{...book,cover_image:coverPath})).data;
  assert.equal(withCover.cover_image,coverPath);
  assert.equal((await staff.ctx.post('/api/manage/cover',{headers:{'X-CSRF-Token':staff.token},multipart:{cover:{name:'bad.svg',mimeType:'image/svg+xml',buffer:Buffer.from('<svg/>')}}})).status(),422);
  fs.unlinkSync(root+'/public'+coverPath);
  ok('Cover image upload and invalid file rejection');
  await race('book',fixture.copy,[()=>send(staff,`/api/borrow-requests/book/${fixture.requests.book[0]}/review`,'POST',{decision:'approved'}),()=>send(staff2,`/api/borrow-requests/book/${fixture.requests.book[1]}/review`,'POST',{decision:'approved'})]);
  const approvedBook=JSON.parse(phpRun(['-r',`require '${root}/app/config.php';require '${root}/app/database.php';echo json_encode(Database::connection()->query("SELECT id FROM book_loan_requests WHERE id IN (${fixture.requests.book.slice(0,2).join(',')}) AND status='approved'")->fetchColumn());`]));
  const receipt=(await json(other,`/api/students/${fixture.code}/history`)).data.items.find(item=>!item.return_date).receipt_id;
  assert.equal((await send(student,`/api/loan-receipts/${receipt}`)).status(),403);
  assert.equal((await send(staff,`/api/borrow-requests/book/${approvedBook}/review`,'POST',{decision:'approved'})).status(),422);
  const borrowedCopy=(await json(staff,`/api/manage/copies/${fixture.copy}`)).data;
  assert.equal((await send(staff,`/api/manage/copies/${fixture.copy}`,'PUT',{...borrowedCopy,status:'available'})).status(),409);
  ok('Concurrent approvals allocate the final book once; repeated approval and borrowed-copy edits blocked');
  const extraCopy=(await json(staff,'/api/manage/copies','POST',{book_id:fixture.book,barcode:'RACE_'+Date.now(),storage_location:'Test',condition_status:'good',status:'available'})).data;
  const sameReview=()=>send(staff,`/api/borrow-requests/book/${fixture.requests.book[2]}/review`,'POST',{decision:'approved'});
  const sameReview2=()=>send(staff2,`/api/borrow-requests/book/${fixture.requests.book[2]}/review`,'POST',{decision:'approved'});
  await race('book',extraCopy.id,[sameReview,sameReview2]);
  ok('Two simultaneous approvals of the same request create only one receipt');
  await race('equipment',fixture.equipment,[()=>send(staff,`/api/borrow-requests/equipment/${fixture.requests.equipment[0]}/review`,'POST',{decision:'approved'}),()=>send(staff2,`/api/borrow-requests/equipment/${fixture.requests.equipment[1]}/review`,'POST',{decision:'approved'})]);
  const equipment=(await json(staff,`/api/manage/equipment/${fixture.equipment}`)).data;
  assert.equal((await send(staff,`/api/manage/equipment/${fixture.equipment}`,'PUT',{...equipment,total_quantity:0})).status(),409);
  ok('Concurrent equipment approvals never oversell; reducing stock below outstanding units blocked');
  const date=new Date(Date.now()+14*86400000).toISOString().slice(0,10);
  const other2=await client(fixture.username,8012);
  await race('room',fixture.room,[()=>send(other,'/api/room-requests','POST',{room_id:fixture.room,use_date:date,start_time:'08:00',end_time:'10:00',purpose:'Test one'}),()=>send(other2,'/api/room-requests','POST',{room_id:fixture.room,use_date:date,start_time:'09:00',end_time:'11:00',purpose:'Test two'})]);
  const schedule=(await json(student,`/api/room-schedule?date=${date}`)).data.find(item=>Number(item.room_id)===fixture.room);
  assert.equal(schedule.student_name,'Đã được đặt');assert.equal(schedule.student_code,null);assert(!schedule.purpose.startsWith('Test'));
  assert(!(await json(student,'/api/room-requests')).data.some(item=>item.student_code===fixture.code));
  ok('Concurrent overlapping bookings serialize; shared occupancy conceals other students personal details');
  phpRun([root+'/scripts/hash-passwords.php','--apply']);
  const invariant=JSON.parse(phpRun([fixtureScript,'verify']));
  assert.deepEqual(invariant,{copy_loans:1,equipment_available:0,equipment_units:1,room_bookings:1,plain_passwords:0});
  await client('user3');ok('Database invariants and password migration verified');
  const activeBook=JSON.parse(phpRun(['-r',`require '${root}/app/config.php';require '${root}/app/database.php';$pdo=Database::connection();$id=(int)$pdo->query('SELECT id FROM loan_details WHERE copy_id=${fixture.copy} AND return_date IS NULL')->fetchColumn();$pdo->exec("UPDATE loan_details SET borrow_date=DATE_SUB(CURDATE(),INTERVAL 7 DAY),due_date=DATE_SUB(CURDATE(),INTERVAL 2 DAY) WHERE id=$id");echo json_encode($id);`]));
  const computedReturn=(await json(staff,`/api/returns/books/${activeBook}`,'POST',{return_status:'on_time',late_days:0})).data;
  assert.equal(computedReturn.late_days,2);assert.equal(computedReturn.return_status,'Tra tre');
  assert.equal((await send(staff,`/api/returns/books/${activeBook}`,'POST',{})).status(),422);
  ok('Book return derives late days from stored dates and rejects repeated return');
  const maintenance=(await json(staff,`/api/manage/equipment/${fixture.equipment}`,'PUT',{...equipment,status:'maintenance'})).data;
  const detail=JSON.parse(phpRun(['-r',`require '${root}/app/config.php';require '${root}/app/database.php';echo json_encode(Database::connection()->query("SELECT id FROM equipment_loan_details WHERE equipment_id=${fixture.equipment} AND return_date IS NULL")->fetchColumn());`]));
  const equipmentReturn=(await json(staff,`/api/returns/equipment/${detail}`,'POST',{return_status:'late',late_days:999,condition_on_return:'Tot'})).data;
  assert.equal(equipmentReturn.late_days,0);assert.equal(equipmentReturn.return_status,'Tra dung han');
  const afterReturn=(await json(staff,`/api/manage/equipment/${fixture.equipment}`)).data;
  assert.equal(afterReturn.status,'maintenance');assert.equal(afterReturn.available_quantity,1);
  ok('Returning a loan preserves equipment maintenance status');
  browser=await chromium.launch({executablePath:process.env.NEXUS_CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
  const screenshotDir=path.join(__dirname,'output');fs.mkdirSync(screenshotDir,{recursive:true});
  for(const [username,role] of [['user2','librarian'],['user1','admin'],['user3','student']]) {
    const context=await browser.newContext({viewport:{width:1440,height:1000}});const page=await context.newPage();const errors=[];
    page.on('pageerror',e=>errors.push(e.message));page.on('response',r=>{if(r.url().includes('/api/')&&r.status()>=400)errors.push(r.status()+' '+r.url());});
    await page.goto('http://127.0.0.1:8011');await page.locator('#login-screen').waitFor({state:'visible'});
    await page.locator('[name=username]').fill(username);await page.locator('[name=password]').fill('12345');await page.locator('#login-form button').click();await page.locator('.stat-card').first().waitFor();
    if(role!=='student') {
      await page.locator('.main-nav [data-view=manage]').click();await page.locator('[data-edit-resource]').first().waitFor();
      for(const type of ['books','copies','rooms','equipment']) { await page.locator(`[data-resource-type=${type}]`).click();await page.waitForLoadState('networkidle');await page.locator('#management-add').click();await page.locator('#resource-editor:not(.is-hidden)').waitFor();await page.keyboard.press('Escape'); }
      await page.locator('[data-resource-type=rooms]').click();await page.waitForLoadState('networkidle');await page.locator('#management-add').click();
      await page.locator('#resource-editor-form [name=name]').fill('UI Regression room');await page.locator('#resource-editor-form [name=location]').fill('Test Wing');await page.locator('#resource-editor-form [name=capacity]').fill('25');await page.locator('#resource-editor-save').click();await page.locator('#resource-editor').waitFor({state:'hidden'});
      await page.locator('#management-table [data-edit-resource]').first().waitFor();
      await page.screenshot({path:`${screenshotDir}/${role}-resources.png`,fullPage:true});
      await page.setViewportSize({width:1024,height:1000});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);
    } else assert.equal(await page.locator('.main-nav [data-view=manage]').isVisible(),false);
    for(const view of ['catalog','circulation','spaces','equipment',...(role==='student'?['requests']:['reports'])]) {await page.locator(`.main-nav [data-view=${view}]`).click();await page.waitForLoadState('networkidle');}
    assert.deepEqual(errors,[],role+' frontend errors');await context.close();ok(role+' desktop regression');
  }
  await browser.close();browser=null;
  fs.writeFileSync(screenshotDir+'/resource-regression.json',JSON.stringify({results,invariant},null,2));
})().catch(e=>{console.error(e);process.exitCode=1;}).finally(async()=>{
  if(browser)await browser.close();for(const ctx of clients)await ctx.dispose();for(const server of servers)server.kill();
  fs.rmSync(fixtureFile,{force:true});
});
