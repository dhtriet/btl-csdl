const study = { books: [], selected: [], threads: [], threadId: null, mode: 'ask', messages: [], busy: false, owner: null, ready: false, requestId: null };
const studyModes = { ask:'Hỏi kiến thức', summary:'Tóm tắt sách', roadmap:'Lộ trình học', outcomes:'Bạn sẽ học được gì' };
const studyPrompts = [
  ['summary','Tóm tắt một cuốn sách','Nắm các ý chính và cấu trúc nội dung.','Tóm tắt các nội dung chính của sách đã chọn và chỉ ra phần nên đọc đầu tiên.'],
  ['roadmap','Xây lộ trình học','Chia mục tiêu thành từng tuần thực hành.','Tôi mới bắt đầu. Hãy gợi ý lộ trình học 4 tuần từ sách đã chọn, mỗi ngày khoảng 45 phút, có bài tập và cách tự kiểm tra.'],
  ['outcomes','Tôi sẽ học được gì?','Hiểu kiến thức, kỹ năng và ứng dụng.','Sau khi đọc sách đã chọn, tôi sẽ học được những kiến thức và kỹ năng nào? Có thể áp dụng vào việc gì?'],
  ['ask','Giải thích một khái niệm','Học qua ví dụ và trang sách liên quan.','Hãy giải thích một khái niệm nền tảng trong sách đã chọn bằng ví dụ đơn giản và gợi ý phần đọc tiếp.'],
];

function resetAssistant() {
  if(typeof resetLearningKit==='function')resetLearningKit();
  study.books=[];study.selected=[];study.threads=[];study.threadId=null;study.messages=[];study.owner=null;study.ready=false;study.mode='ask';study.requestId=null;study.busy=false;
  if($('#study-messages')){setStudyBusy(false);renderStudyMessages();}
}

async function loadAssistant() {
  if(study.owner!==state.user?.id){resetAssistant();study.owner=state.user?.id;}
  const owner=state.user?.id;
  $('#study-service-status').textContent='Đang kết nối nguồn sách…';
  try {
    const [status,threads]=await Promise.all([api('/api/assistant/status'),api('/api/assistant/threads')]);
    if(study.owner!==owner||owner!==state.user?.id)return;
    study.books=status.data.books;study.threads=threads.data;study.ready=true;
    const count=study.books.filter(book=>book.status==='ready').length;
    $('#study-service-status').textContent=status.data.configured?'Nexus · Đã cấu hình':'Nexus · Chưa cấu hình key';
    $('#study-source-count').textContent=`${count} sách có nội dung tra cứu`;
    $('#study-reindex').classList.toggle('is-hidden',!status.data.can_reindex);
    renderStudyBooks();renderStudyThreads();renderStudyModes();renderStudyMessages();
    setStudyError(status.data.configured?'':'Trợ lý chưa có key trên server. Hãy liên hệ quản trị để cấu hình.');
  } catch(error){if(study.owner===owner){$('#study-service-status').textContent='Chưa kết nối được';setStudyError(error.message);}}
}

function renderStudyBooks() {
  const search=($('#study-book-search').value || '').toLocaleLowerCase('vi');
  const books=study.books.filter(book=>book.title.toLocaleLowerCase('vi').includes(search));
  $('#study-books').replaceChildren();
  for(const book of books){
    const label=document.createElement('label');label.className='study-book-option';
    const input=document.createElement('input');input.type='checkbox';input.value=book.id;input.checked=study.selected.includes(book.id);input.disabled=study.busy;
    input.addEventListener('change',()=>{
      if(input.checked&&study.selected.length>=3){input.checked=false;showToast('Chọn tối đa 3 cuốn sách cho một câu hỏi.');return;}
      study.selected=input.checked?[...study.selected,book.id]:study.selected.filter(id=>id!==book.id);study.requestId=null;renderStudySelection();
    });
    const info=document.createElement('span');const title=document.createElement('strong');title.textContent=book.title;
    const status=document.createElement('small');status.className=book.status==='ready'?'source-ready':'';
    status.textContent=book.status==='ready'?`${book.extracted_pages}/${book.pages} trang PDF đọc được`:book.status==='no_pdf'?'Chỉ có thông tin danh mục':book.status==='needs_ocr'?'Cần OCR để đọc nội dung':'Chưa cập nhật chỉ mục';
    info.append(title,status);label.append(input,info);$('#study-books').append(label);
  }
  if(!books.length){const empty=document.createElement('p');empty.className='study-small-note';empty.textContent='Không tìm thấy sách phù hợp.';$('#study-books').append(empty);}
  renderStudySelection();
}

function renderStudySelection(){
  const selected=study.books.filter(book=>study.selected.includes(book.id));
  $('#study-scope').textContent=selected.length?selected.map(book=>book.title).join(' · '):'Tra cứu toàn bộ kho sách';
  $('#study-selection-count').textContent=`${selected.length}/3 sách`;
}

function renderStudyModes(){
  $$('#study-modes button').forEach(button=>{const active=button.dataset.studyMode===study.mode;button.classList.toggle('is-active',active);button.setAttribute('aria-pressed',String(active));button.disabled=study.busy;});
}

// Render a deliberately small Markdown subset with DOM APIs. Model text can never execute HTML.
function studyInline(parent,text,sources){
  const normalized=String(text).replace(/[【(]\s*(S\d+(?:\s*,\s*S\d+)*)\s*[】)]/g,(_,ids)=>'['+ids+']').replace(/\[(S\d+(?:\s*,\s*S\d+)+)\]/g,(_,ids)=>ids.split(',').map(id=>'['+id.trim()+']').join(' '));
  const parts=normalized.split(/(\*\*[^*]+\*\*|`[^`]+`|\[S\d+\])/g);
  for(const part of parts){
    if(/^\[S\d+\]$/.test(part)){
      const source=sources.find(source=>`[${source.id}]`===part);
      if(source){const button=document.createElement('button');button.className='study-citation';button.type='button';button.textContent=part;button.setAttribute('aria-label',`Đọc ${source.title}, trang PDF ${source.page}`);button.addEventListener('click',()=>openStudySource(source));parent.append(button);}
    } else if(part.startsWith('**')&&part.endsWith('**')){const strong=document.createElement('strong');strong.textContent=part.slice(2,-2);parent.append(strong);}
    else if(part.startsWith('`')&&part.endsWith('`')){const code=document.createElement('code');code.textContent=part.slice(1,-1);parent.append(code);}
    else parent.append(document.createTextNode(part));
  }
}

function studyMarkdown(text,sources){
  const block=document.createElement('div');block.className='study-prose';let list=null;
  const lines=String(text).split('\n');
  for(let index=0;index<lines.length;index++){
    const line=lines[index];
    if(line.trim().startsWith('|') && /^\s*\|?\s*:?-{3,}.*\|/.test(lines[index+1] || '')){
      list=null;
      const cells=value=>value.trim().replace(/^\||\|$/g,'').split('|').map(cell=>cell.trim());
      const wrapper=document.createElement('div');wrapper.className='study-table-wrap';
      const table=document.createElement('table');const head=document.createElement('thead');const header=document.createElement('tr');
      const headings=cells(line);
      for(const value of headings){const cell=document.createElement('th');cell.scope='col';studyInline(cell,value,sources);header.append(cell);}
      head.append(header);table.append(head);const body=document.createElement('tbody');index++;
      while(index+1<lines.length && lines[index+1].trim().startsWith('|')){
        const values=cells(lines[++index]);const row=document.createElement('tr');
        for(let column=0;column<headings.length;column++){const cell=document.createElement('td');studyInline(cell,values[column] || '',sources);row.append(cell);}
        body.append(row);
      }
      table.append(body);wrapper.append(table);block.append(wrapper);continue;
    }
    if(!line.trim()){list=null;continue;}
    const heading=line.match(/^#{1,4}\s+(.+)/);const bullet=line.match(/^\s*(?:[-*]|\d+\.)\s+(.+)/);
    let element;
    if(heading){element=document.createElement('h3');studyInline(element,heading[1],sources);list=null;}
    else if(bullet){if(!list){list=document.createElement('ul');block.append(list);}element=document.createElement('li');studyInline(element,bullet[1],sources);list.append(element);continue;}
    else {element=document.createElement('p');studyInline(element,line,sources);list=null;}
    block.append(element);
  }
  return block;
}

function openStudySource(source){
  if(!Number.isInteger(source.book_id)||!Number.isInteger(source.page))return;
  window.open(`/reader.php?book_id=${source.book_id}&page=${source.page}`,'_blank','noopener');
}

function renderStudyMessages(){
  const transcript=$('#study-messages');if(!transcript)return;
  transcript.replaceChildren();$('#study-welcome').classList.toggle('is-hidden',study.messages.length>0);
  for(const message of study.messages){
    const article=document.createElement('article');article.className=`study-message ${message.role==='user'?'from-user':'from-assistant'}`;
    const header=document.createElement('div');header.className='study-message-heading';header.textContent=message.role==='user'?'Bạn':'Nexus · Trợ lý học tập';article.append(header);
    if(message.role==='user'){const p=document.createElement('p');p.textContent=message.text;article.append(p);}
    else {
      article.append(studyMarkdown(message.text,message.sources || []));
      if(message.sources?.length){
        const sources=document.createElement('details');sources.className='study-evidence';
        const summary=document.createElement('summary');summary.textContent=`${message.sources.length} trích đoạn tham khảo · số trang theo file PDF`;sources.append(summary);
        const cards=document.createElement('div');cards.className='study-evidence-list';
        for(const source of message.sources){const card=document.createElement('button');card.type='button';card.className='study-source-card';
          const title=document.createElement('strong');title.textContent=`[${source.id}] ${source.title}`;const page=document.createElement('span');page.textContent=`Trang PDF ${source.page} · Mở tài liệu`;
          const excerpt=document.createElement('small');excerpt.textContent=source.excerpt.slice(0,220)+'…';card.append(title,page,excerpt);card.addEventListener('click',()=>openStudySource(source));cards.append(card);}
        sources.append(cards);article.append(sources);
      }
      const note=document.createElement('p');note.className='study-answer-note';
      note.textContent=message.grounding==='insufficient'?'Chưa có trích đoạn đủ để xác minh câu trả lời này.':message.coverage==='sampled_pages'?'Tổng hợp từ các trang mẫu được tra cứu; hãy đối chiếu nội dung chi tiết trong sách.':'Câu trả lời có tài liệu tham khảo; hãy đối chiếu phần cần sử dụng.';
      article.append(note);
      if(message.follow_ups?.length){const follow=document.createElement('div');follow.className='study-follow-ups';for(const suggestion of message.follow_ups){const button=document.createElement('button');button.type='button';button.textContent=suggestion;button.disabled=study.busy;button.addEventListener('click',()=>{ $('#study-input').value=suggestion;$('#study-input').focus();updateStudyCounter();});follow.append(button);}article.append(follow);}
    }
    transcript.append(article);
  }
  if(study.busy){const status=document.createElement('p');status.className='study-thinking';status.setAttribute('role','status');status.textContent='Nexus đang tìm và đọc các đoạn sách liên quan…';transcript.append(status);}
  const scroller=$('#study-scroll');scroller.scrollTop=scroller.scrollHeight;
}

function renderStudyThreads(){
  $('#study-threads').replaceChildren();
  for(const thread of study.threads){const button=document.createElement('button');button.type='button';button.textContent=thread.title;button.title=thread.title;button.disabled=study.busy;button.className=thread.id===study.threadId?'is-active':'';button.addEventListener('click',()=>{study.threadId=thread.id;study.messages=thread.messages;study.selected=thread.book_ids;study.mode=thread.mode;study.requestId=null;setStudyError('');renderStudyBooks();renderStudyModes();renderStudyMessages();renderStudyThreads();});$('#study-threads').append(button);}
  if(!study.threads.length){const p=document.createElement('p');p.className='study-small-note';p.textContent='Các cuộc trò chuyện đã trả lời sẽ xuất hiện ở đây.';$('#study-threads').append(p);}
}

function setStudyError(message){$('#study-error').textContent=message;$('#study-error').classList.toggle('is-hidden',!message);}
function updateStudyCounter(){ $('#study-character-count').textContent=`${$('#study-input').value.length}/2000`; }
function setStudyBusy(busy){study.busy=busy;$('#study-send').disabled=busy;$('#study-new').disabled=busy;$('#study-input').disabled=busy;renderStudyBooks();renderStudyModes();renderStudyThreads();}

async function sendStudyMessage(event){
  event.preventDefault();if(study.busy)return;
  const message=$('#study-input').value.trim();if(!message)return;
  const owner=study.owner;
  const requestId=study.requestId || crypto.randomUUID().replaceAll('-','');study.requestId=requestId;
  const before=study.messages.slice();study.messages.push({role:'user',text:message});setStudyError('');setStudyBusy(true);renderStudyMessages();
  try {
    const response=await api('/api/assistant/chat',{method:'POST',body:JSON.stringify({message,mode:study.mode,book_ids:study.selected,thread_id:study.threadId || undefined,request_id:requestId})});
    if(owner!==study.owner||owner!==state.user?.id)return;
    study.threadId=response.data.thread.id;study.messages=response.data.thread.messages;study.requestId=null;
    study.threads=[response.data.thread,...study.threads.filter(thread=>thread.id!==study.threadId)].slice(0,20);
    $('#study-input').value='';updateStudyCounter();
  } catch(error){if(owner===study.owner){study.messages=before;setStudyError(error.message);}}
  finally {if(owner===study.owner){setStudyBusy(false);renderStudyMessages();$('#study-input').focus();}}
}

async function openAssistantForBook(bookId){
  closeAllDialogs();setView('assistant',{focus:true});
  if(!study.ready) await loadAssistant();
  study.threadId=null;study.messages=[];study.requestId=null;renderStudyMessages();renderStudyThreads();
  study.selected=[Number(bookId)];study.mode='summary';renderStudyBooks();renderStudyModes();
  $('#study-input').value='Tóm tắt các ý chính của sách đã chọn và gợi ý cách bắt đầu học.';updateStudyCounter();$('#study-input').focus();
}

document.addEventListener('DOMContentLoaded',()=>{
  $('#study-form').addEventListener('submit',sendStudyMessage);$('#study-input').addEventListener('input',()=>{study.requestId=null;updateStudyCounter();});
  $('#study-input').addEventListener('keydown',event=>{if(event.key==='Enter'&&!event.shiftKey&&!event.isComposing){event.preventDefault();$('#study-form').requestSubmit();}});
  $('#study-book-search').addEventListener('input',renderStudyBooks);
  $('#study-clear-books').addEventListener('click',()=>{if(study.busy)return;study.selected=[];renderStudyBooks();});
  $('#study-new').addEventListener('click',()=>{if(study.busy)return;study.threadId=null;study.messages=[];study.requestId=null;setStudyError('');renderStudyThreads();renderStudyMessages();$('#study-input').value='';updateStudyCounter();$('#study-input').focus();});
  $$('#study-modes button').forEach(button=>button.addEventListener('click',()=>{study.mode=button.dataset.studyMode;study.requestId=null;renderStudyModes();}));
  const prompts=$('#study-suggestions');
  for(const [mode,title,description,prompt] of studyPrompts){const button=document.createElement('button');button.type='button';const h=document.createElement('strong');h.textContent=title;const p=document.createElement('span');p.textContent=description;button.append(h,p);button.addEventListener('click',()=>{study.mode=mode;renderStudyModes();$('#study-input').value=prompt;updateStudyCounter();$('#study-input').focus();});prompts.append(button);}
  $('#study-reindex').addEventListener('click',async()=>{const button=$('#study-reindex');button.disabled=true;button.textContent='Đang đọc PDF…';try{const result=await api('/api/assistant/index',{method:'POST',body:'{}'});showToast(`Đã cập nhật ${result.data.indexed_books} sách.`);await loadAssistant();}catch(error){setStudyError(error.message);}finally{button.disabled=false;button.textContent='Cập nhật nguồn sách';}});
});
