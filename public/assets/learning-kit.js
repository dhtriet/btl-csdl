const learningKit = { owner:null, loaded:false, busy:false, data:null, selected:new Set(), requestId:null, signature:null, controller:null, version:0 };

function resetLearningKit() {
  learningKit.controller?.abort();
  learningKit.version++;
  Object.assign(learningKit,{owner:null,loaded:false,busy:false,data:null,selected:new Set(),requestId:null,signature:null,controller:null});
  if(document.querySelector('#kit-form')){
    document.querySelector('#kit-form').reset();document.querySelector('#kit-results').replaceChildren();
    document.querySelector('#kit-status').textContent='';document.querySelector('#kit-error').classList.add('is-hidden');
    document.querySelector('#learning-kit').open=false;kitBusy(false);
  }
}

function kitBusy(busy) {
  learningKit.busy=busy;
  document.querySelectorAll('#kit-form input, #kit-form select, #kit-form textarea, #kit-form button, #kit-results button, #kit-results input').forEach(control=>{control.disabled=busy;});
  document.querySelector('#kit-create').textContent=busy?'Đang tìm sách và lập kế hoạch…':'Tạo bộ học liệu';
  document.querySelector('#kit-form').setAttribute('aria-busy',String(busy));
}

function kitError(message) {
  const box=document.querySelector('#kit-error');box.textContent=message;box.classList.toggle('is-hidden',!message);
}

function kitDraftSignature(){return JSON.stringify(['#kit-goal','#kit-weeks','#kit-minutes','#kit-level'].map(selector=>document.querySelector(selector).value));}

async function loadLearningKit() {
  if(learningKit.loaded&&learningKit.owner===state.user?.id)return;
  const owner=state.user?.id;if(!owner)return;const version=learningKit.version,draft=kitDraftSignature();
  learningKit.owner=owner;learningKit.loaded=true;
  try {
    const response=await api('/api/assistant/learning-kit');
    if(owner!==state.user?.id||owner!==learningKit.owner||version!==learningKit.version)return;
    if(response.data){
      learningKit.data=response.data;
      if(kitDraftSignature()===draft){
        document.querySelector('#kit-goal').value=response.data.goal;
        document.querySelector('#kit-weeks').value=response.data.weeks_count;
        document.querySelector('#kit-minutes').value=response.data.minutes;
        document.querySelector('#kit-level').value=response.data.level;
      }
      kitSelectAvailable();renderLearningKit();
    }
  } catch(error){if(owner===state.user?.id&&version===learningKit.version){learningKit.loaded=false;kitError(error.message);}}
}

function kitSelectAvailable() {
  learningKit.selected=new Set((learningKit.data?.books||[]).filter(book=>book.available_copies>0&&!state.bookRequestItems.some(item=>item.book_id===book.id)).map(book=>book.id));
}

function kitNode(tag,text,className) {const node=document.createElement(tag);if(text!==undefined)node.textContent=text;if(className)node.className=className;return node;}

function kitSources(ids,parent,bookId) {
  const sources=learningKit.data.sources||[];
  for(const id of [...new Set(ids||[])]){
    const source=sources.find(item=>item.id===id&&(!bookId||item.book_id===bookId));if(!source)continue;
    const link=kitNode('a',`${source.title} · PDF trang ${source.page}`,'kit-source');
    link.href=`/reader.php?book_id=${encodeURIComponent(source.book_id)}&page=${encodeURIComponent(source.page)}`;link.target='_blank';link.rel='noopener';parent.append(link);
  }
}

function renderLearningKit() {
  const target=document.querySelector('#kit-results');target.replaceChildren();const data=learningKit.data;if(!data)return;
  const heading=kitNode('div',undefined,'kit-result-heading');
  const title=kitNode('div');title.append(kitNode('h2','Bộ học liệu của bạn'),kitNode('p',data.goal));
  heading.append(title,kitNode('span',`${data.weeks_count} tuần · ${data.minutes} phút/ngày`,'panel-badge'));target.append(heading);
  const intro=kitNode('div',undefined,'kit-intro');intro.append(studyMarkdown(data.intro,data.sources||[]));target.append(intro);
  if(!data.books.length){target.append(kitNode('p','Thử nêu tên môn học, kỹ năng hoặc sản phẩm bạn muốn hoàn thành.','empty-state'));return;}
  const layout=kitNode('div',undefined,'kit-result-layout'),resources=kitNode('section'),plan=kitNode('section');
  resources.setAttribute('aria-label','Sách đề xuất');plan.setAttribute('aria-label','Kế hoạch học theo tuần');
  resources.append(kitNode('h3','Sách cho mục tiêu này'));
  for(const book of data.books){
    const row=kitNode('article',undefined,'kit-book');const header=kitNode('div',undefined,'kit-book-heading');
    if(state.user?.role==='student'){
      const label=kitNode('label',undefined,'kit-select'),input=document.createElement('input');input.type='checkbox';input.checked=learningKit.selected.has(book.id);
      input.disabled=book.available_copies<1||state.bookRequestItems.some(item=>item.book_id===book.id);input.setAttribute('aria-label',`Chọn mượn ${book.title}`);
      input.addEventListener('change',()=>{input.checked?learningKit.selected.add(book.id):learningKit.selected.delete(book.id);updateKitCartButton();});label.append(input);header.append(label);
    }
    const identity=kitNode('div');identity.append(kitNode('h4',book.title),kitNode('p',book.authors||'Chưa cập nhật tác giả','kit-author'));header.append(identity);row.append(header);
    row.append(kitNode('p',book.reason,'kit-reason'),kitNode('strong','Nên tập trung'),kitNode('p',book.reading_focus));
    row.append(kitNode('small',book.source_ids.length?'Có trích đoạn để đối chiếu; phần đọc là gợi ý theo mục tiêu.':'Đề xuất dựa trên danh mục; chưa xác minh phần đọc từ toàn văn.','kit-grounding'));
    const refs=kitNode('div',undefined,'kit-sources');kitSources(book.source_ids,refs,book.id);row.append(refs);
    const actions=kitNode('div',undefined,'kit-book-actions');actions.append(kitNode('span',book.available_copies>0?`Còn ${book.available_copies} bản`:'Hiện hết bản giấy','status-pill'));
    if(book.has_ebook){const pdf=kitNode('a','Đọc PDF','text-button');pdf.href=`/reader.php?book_id=${encodeURIComponent(book.id)}`;pdf.target='_blank';pdf.rel='noopener';actions.append(pdf);}
    const detail=kitNode('button','Chi tiết sách','text-button');detail.type='button';detail.addEventListener('click',()=>openBookModal(book.id));actions.append(detail);
    const ask=kitNode('button','Hỏi sâu về sách','text-button');ask.type='button';ask.addEventListener('click',async()=>{
      await openAssistantForBook(book.id);document.querySelector('#learning-kit').open=false;
      study.mode='roadmap';renderStudyModes();document.querySelector('#study-input').value=`Mục tiêu của tôi: ${data.goal}. Tôi có ${data.weeks_count} tuần, ${data.minutes} phút mỗi ngày. Hãy hướng dẫn học phần ${book.reading_focus} từ sách đã chọn, chỉ dẫn nguồn khi có.`.slice(0,2000);
      updateStudyCounter();document.querySelector('#study-input').scrollIntoView({block:'center'});document.querySelector('#study-input').focus();
    });actions.append(ask);row.append(actions);resources.append(row);
  }
  plan.append(kitNode('h3','Kế hoạch học gợi ý'),kitNode('p','Bài thực hành và tiêu chí kiểm tra dưới đây được đề xuất cho mục tiêu của bạn.','kit-plan-note'));
  for(const week of data.weeks){const stage=kitNode('article',undefined,'kit-week');stage.append(kitNode('span',`Tuần ${week.week}`,'kit-week-label'),kitNode('h4',week.focus),kitNode('p',week.task));
    const titles=data.books.filter(book=>week.book_ids.includes(book.id)).map(book=>book.title);if(titles.length)stage.append(kitNode('small',`Học liệu: ${titles.join(' · ')}`));kitSources(week.source_ids,stage);plan.append(stage);}
  layout.append(resources,plan);target.append(layout);
  if(state.user?.role==='student'){
    const cart=kitNode('div',undefined,'kit-cart');const dueLabel=kitNode('label','Hạn trả dự kiến');const due=document.createElement('input');due.id='kit-due-date';due.type='date';due.min=dateAfter(1);due.value=dateAfter(14);dueLabel.append(due);
    const info=kitNode('p','Chỉ thêm vào giỏ mượn. Bạn xem lại và gửi thủ thư duyệt ở bước tiếp theo.');const button=kitNode('button','','primary-button');button.type='button';button.id='kit-add-cart';button.addEventListener('click',addLearningKitToCart);cart.append(dueLabel,info,button);target.append(cart);updateKitCartButton();
  }
}

function updateKitCartButton(){const button=document.querySelector('#kit-add-cart');if(button){button.textContent=`Thêm ${learningKit.selected.size} sách vào giỏ mượn`;button.disabled=learningKit.busy||!learningKit.selected.size;}}

async function createLearningKit(event){
  event.preventDefault();if(learningKit.busy)return;
  const owner=state.user?.id;learningKit.owner=owner;
  const version=++learningKit.version;
  const payload={goal:document.querySelector('#kit-goal').value.trim(),weeks:Number(document.querySelector('#kit-weeks').value),minutes:Number(document.querySelector('#kit-minutes').value),level:document.querySelector('#kit-level').value};
  const signature=JSON.stringify(payload);if(signature!==learningKit.signature){learningKit.requestId=null;learningKit.signature=signature;}
  learningKit.requestId ||= crypto.randomUUID().replaceAll('-','');payload.request_id=learningKit.requestId;
  const controller=new AbortController();learningKit.controller=controller;kitBusy(true);kitError('');document.querySelector('#kit-status').textContent='Đang đối chiếu mục tiêu với kho sách và chuẩn bị kế hoạch…';
  try{
    const response=await api('/api/assistant/learning-kit',{method:'POST',body:JSON.stringify(payload),signal:controller.signal});
    if(owner!==state.user?.id||owner!==learningKit.owner||version!==learningKit.version)return;
    learningKit.data=response.data;learningKit.loaded=true;kitSelectAvailable();renderLearningKit();document.querySelector('#kit-status').textContent=response.data.books.length?'Đã lưu bộ học liệu cho tài khoản của bạn.':'Chưa có học liệu phù hợp với mục tiêu này.';
  }catch(error){if(owner===state.user?.id&&version===learningKit.version&&error.name!=='AbortError'){kitError(error.message);document.querySelector('#kit-status').textContent='';}}
  finally{if(owner===state.user?.id&&owner===learningKit.owner&&version===learningKit.version){kitBusy(false);renderLearningKit();updateKitCartButton();}}
}

async function addLearningKitToCart(){
  if(learningKit.busy||!learningKit.selected.size)return;
  const due=document.querySelector('#kit-due-date');if(!due.reportValidity()||!due.value||due.value<dateAfter(1)){kitError('Chọn hạn trả từ ngày mai trở đi.');return;}
  const owner=state.user?.id,version=learningKit.version,ids=[...learningKit.selected],date=due.value;kitBusy(true);kitError('');
  try{
    const checked=await Promise.allSettled(ids.map(id=>api(`/api/books/${id}`)));
    if(owner!==state.user?.id||version!==learningKit.version)return;
    let added=0;const skipped=[];
    checked.forEach((result,index)=>{
      if(result.status==='fulfilled'){
        const book=result.value.data;const existing=state.bookRequestItems.some(item=>item.book_id===Number(book.id));
        const available=book.copies.filter(copy=>copy.status==='available').length;
        const suggested=learningKit.data.books.find(item=>item.id===Number(book.id));if(suggested)suggested.available_copies=available;
        if(available>0&&!existing){if(addBookToRequest({...book,available_copies:available},1,date))added++;}
        else skipped.push(book.title);
      }else skipped.push(learningKit.data.books.find(book=>book.id===ids[index])?.title||'Một cuốn sách');
    });
    if(added){showToast(`Đã thêm ${added} sách vào giỏ.${skipped.length?` ${skipped.length} sách hết bản, đã có trong giỏ hoặc chưa kiểm tra được.`:''}`);setView('requests',{focus:true});}
    else kitError('Chưa thêm sách: sách có thể đã có trong giỏ, hết bản hoặc chưa kiểm tra được. Hãy mở Chi tiết sách để kiểm tra lại.');
    kitSelectAvailable();
  }catch(error){if(owner===state.user?.id&&version===learningKit.version)kitError(error.message);}
  finally{if(owner===state.user?.id&&version===learningKit.version){kitBusy(false);renderLearningKit();updateKitCartButton();}}
}

document.addEventListener('DOMContentLoaded',()=>{
  document.querySelector('#kit-form').addEventListener('submit',createLearningKit);
  document.querySelector('#learning-kit').addEventListener('toggle',()=>{if(document.querySelector('#learning-kit').open)loadLearningKit();});
  document.querySelectorAll('[data-kit-example]').forEach(button=>button.addEventListener('click',()=>{document.querySelector('#kit-goal').value=button.dataset.kitExample;document.querySelector('#kit-goal').focus();}));
  const entry=document.createElement('button');entry.type='button';entry.className='kit-entry';entry.textContent='Chưa biết chọn sách? Tạo bộ học liệu theo mục tiêu';
  entry.addEventListener('click',()=>{setView('assistant',{focus:true});document.querySelector('#learning-kit').open=true;document.querySelector('#learning-kit').scrollIntoView({block:'start'});document.querySelector('#kit-goal').focus();});
  document.querySelector('#campus-discovery').append(entry);
});
