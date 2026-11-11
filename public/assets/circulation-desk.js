const deskState = { resources: [], counterBusy: false, resourceSerial: 0, accountSerial: 0, traceSerial: 0 };

function configureCirculationDesk() {
  deskState.accountSerial++;
  deskState.resourceSerial++;
  deskState.traceSerial++;
  const librarian = state.user?.role === 'librarian';
  $('#counter-desk').classList.toggle('is-hidden', !librarian);
  if (!librarian) $('#counter-desk').open = false;
  $('#counter-result').textContent = '';
  $('#request-trace-result').textContent = '';
  $('#account-full-panel').classList.add('is-hidden');
  $('#account-full-content').textContent = '';
}

function deskTable(caption, headers, rows) {
  return `<div class="table-wrap desk-table"><table class="data-table"><caption>${escapeHtml(caption)}</caption><thead><tr>${headers.map(h=>`<th>${escapeHtml(h)}</th>`).join('')}</tr></thead><tbody>${rows.length ? rows.map(cells=>`<tr>${cells.map(cell=>`<td>${cell}</td>`).join('')}</tr>`).join('') : `<tr><td colspan="${headers.length}">Chưa có dữ liệu.</td></tr>`}</tbody></table></div>`;
}

function deskDefinitions(items) {
  return `<dl class="desk-definition">${items.map(([label,value])=>`<div><dt>${escapeHtml(label)}</dt><dd>${escapeHtml(value ?? 'Chưa cập nhật')}</dd></div>`).join('')}</dl>`;
}

function deskHistoryStatus(value) {
  return String(value || '').replace('Tra dung han','Trả đúng hạn').replace('Tra tre','Trả trễ').replace('Dang muon','Đang mượn').replace('Qua han','Quá hạn').replace(' ngay',' ngày');
}

async function openAccountFull(id) {
  const serial=++deskState.accountSerial;
  const panel = $('#account-full-panel');
  panel.classList.remove('is-hidden');
  $('#account-full-content').innerHTML = '<p role="status">Đang tải thông tin tài khoản…</p>';
  panel.scrollIntoView({block:'start',behavior:'smooth'});
  try {
    const {data} = await api(`/api/accounts/${encodeURIComponent(id)}`);
    if(serial!==deskState.accountSerial || state.user?.role!=='admin') return;
    const p = data.profile;
    $('#account-full-heading').textContent = p.full_name;
    let content = deskDefinitions([['Tên đăng nhập',p.username],['Vai trò',roleLabel(p.role)],['Mã định danh',p.student_code || p.librarian_code || 'Quản trị viên'],['Ngày sinh',p.date_of_birth ? formatDate(p.date_of_birth) : null],['Email',p.email],['Điện thoại',p.phone],['Địa chỉ',p.address],['Ngày đăng ký',formatDateTime(p.registered_at)],['Khoa / Lớp',p.role==='student'?`${p.faculty} / ${p.class_name}`:'—']]);
    if (data.history) content += deskTable('Lịch sử mượn sách và thiết bị', ['Tài nguyên','Mượn / hạn trả','Trả / trạng thái','Phiếu'], data.history.items.map(item=>[escapeHtml(item.resource_name),`${escapeHtml(formatDate(item.borrow_date))}<br>${escapeHtml(formatDate(item.due_date))}`,`${item.return_date?escapeHtml(formatDate(item.return_date)):'Chưa trả'}<br>${escapeHtml(deskHistoryStatus(item.status))}`,item.resource_type==='book'?`<button class="text-button" data-desk-receipt="${Number(item.receipt_id)}" type="button">Phiếu #${Number(item.receipt_id)}</button>`:`#${Number(item.receipt_id)}`]));
    if (p.role==='librarian') {
      for (const [key,title,type] of [['handled_books','Phiếu sách đã lập / duyệt (100 phiếu gần nhất)','book'],['handled_equipment','Phiếu thiết bị đã lập / duyệt (100 phiếu gần nhất)','equipment']]) content += deskTable(title,['Phiếu','Sinh viên','Ngày lập','Yêu cầu'],data[key].map(item=>[`#${item.id}`,`${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}`,escapeHtml(formatDateTime(item.registered_at)),item.request_id?`<button class="text-button" type="button" data-desk-trace="${type}:${Number(item.request_id)}">Yêu cầu #${Number(item.request_id)}</button>`:'Dữ liệu cũ chưa liên kết']));
      content += deskTable('Lịch sử gia hạn đã xử lý (100 lượt gần nhất)',['Chi tiết mượn','Hạn cũ','Hạn mới','Ngày xử lý'],data.extensions.map(item=>[`#${item.loan_detail_id}`,escapeHtml(formatDate(item.old_due_date)),escapeHtml(formatDate(item.new_due_date)),escapeHtml(formatDate(item.extension_date))]));
    }
    content += deskTable('Lịch phòng liên quan (100 lượt gần nhất)',['Phòng','Ngày / giờ','Mục đích','Trạng thái'],data.rooms.map(item=>[escapeHtml(item.name),`${escapeHtml(formatDate(item.use_date))}<br>${escapeHtml(item.start_time)}–${escapeHtml(item.end_time)}`,escapeHtml(item.purpose),escapeHtml(requestStatus(item.status))]));
    $('#account-full-content').innerHTML = content;
    $('#account-full-heading').focus({preventScroll:true});
  } catch(error) { if(serial===deskState.accountSerial && state.user?.role==='admin') showError($('#account-full-content'),error.message); }
}

async function showRequestTrace(type, id) {
  const serial=++deskState.traceSerial;
  const target=$('#request-trace-result');
  target.innerHTML='<p role="status">Đang truy vết yêu cầu…</p>';
  try {
    const {data} = await api(`/api/circulation/trace/${encodeURIComponent(type)}/${encodeURIComponent(id)}`);
    if(serial!==deskState.traceSerial || !state.user) return;
    const source = data.source==='counter'?'Lập tại quầy':'Sinh viên gửi trực tuyến';
    target.innerHTML = `<div class="desk-result"><h3>Yêu cầu #${data.id}${data.receipt_id?` → Phiếu #${data.receipt_id}`:''}</h3>${deskDefinitions([['Sinh viên',`${data.student_name} · ${data.student_code}`],['Nguồn',source],['Trạng thái',requestStatus(data.status)],['Ngày gửi',formatDateTime(data.requested_at)],['Thủ thư xử lý',data.librarian_name],['Ngày xử lý',data.reviewed_at?formatDateTime(data.reviewed_at):'Chưa xử lý']])}${data.review_note?`<p>${escapeHtml(data.review_note)}</p>`:''}${data.receipt_id?deskTable('Tài nguyên thuộc phiếu',['Tài nguyên / mã bản','Số lượng','Ngày mượn','Hạn trả','Ngày trả'],data.details.map(d=>[`${escapeHtml(d.title)}${d.barcode?`<br><small>${escapeHtml(d.barcode)}</small>`:''}`,String(Number(d.quantity||1)),escapeHtml(formatDate(d.borrow_date)),escapeHtml(formatDate(d.due_date)),d.return_date?escapeHtml(formatDate(d.return_date)):'Chưa trả'])):`<p>${data.status==='approved'?'Phiếu cũ chưa có liên kết xác minh.':'Yêu cầu chưa tạo phiếu mượn.'}</p>`}</div>`;
  } catch(error) { if(serial===deskState.traceSerial && state.user) showError(target,error.message); }
}

async function loadCounterResources() {
  const serial=++deskState.resourceSerial;
  const submit=$('#counter-loan-form button[type=submit]'); submit.disabled=true;
  $('#counter-items').innerHTML='<p role="status">Đang tải tài nguyên…</p>';
  const type=$('#counter-type').value;
  const {data}=await api(type==='book'?'/api/books':'/api/equipment/available');
  if(serial!==deskState.resourceSerial || state.user?.role!=='librarian') return;
  deskState.resources=data.filter(row=>Number(type==='book'?row.available_copies:row.available_quantity)>0);
  $('#counter-items').textContent=''; addCounterLine();
  submit.disabled=deskState.counterBusy;
}

function addCounterLine() {
  const type=$('#counter-type').value;
  const line=document.createElement('div'); line.className='counter-line';
  line.innerHTML=`<label>Tài nguyên<select class="counter-resource" required><option value="">Chọn tài nguyên</option>${deskState.resources.map(r=>`<option value="${Number(r.id)}">${escapeHtml(r.title||r.name)} · còn ${Number(type==='book'?r.available_copies:r.available_quantity)}</option>`).join('')}</select></label><label>Số lượng<input class="counter-quantity" type="number" min="1" step="1" max="1000000" value="1" required></label><label>Hạn trả<input class="counter-due" type="date" min="${dateAfter(1)}" value="${dateAfter(14)}" required></label><button class="text-button" type="button" data-counter-remove aria-label="Bỏ dòng tài nguyên">Bỏ</button>`;
  $('#counter-items').append(line);
}

$('#counter-desk').addEventListener('toggle',async()=>{
  if(!$('#counter-desk').open || state.user?.role!=='librarian') return;
  try {
    const {data}=await api('/api/circulation/readers');
    $('#counter-reader').innerHTML='<option value="">Chọn sinh viên</option>'+data.map(r=>`<option value="${escapeHtml(r.student_code)}">${escapeHtml(r.student_code)} · ${escapeHtml(r.full_name)}</option>`).join('');
    await loadCounterResources();
  } catch(error){showError($('#counter-result'),error.message);}
});
$('#counter-type').addEventListener('change',()=>loadCounterResources().catch(error=>showError($('#counter-result'),error.message)));
$('#counter-add').addEventListener('click',addCounterLine);
$('#counter-loan-form').addEventListener('submit',async event=>{
  event.preventDefault(); if(deskState.counterBusy) return;
  const form=event.currentTarget, type=$('#counter-type').value;
  const items=$$('#counter-items .counter-line').map(line=>({[type==='book'?'book_id':'equipment_id']:Number(line.querySelector('select').value),quantity:Number(line.querySelector('.counter-quantity').value),requested_due_date:line.querySelector('.counter-due').value}));
  if(!items.length) return showError($('#counter-result'),'Thêm ít nhất một tài nguyên.');
  const button=form.querySelector('[type=submit]'); button.disabled=true; deskState.counterBusy=true;
  try {
    const {data}=await api('/api/circulation/counter-loans',{method:'POST',body:JSON.stringify({type,student_code:form.elements.student_code.value,note:form.elements.note.value,items})});
    $('#counter-result').innerHTML=`<p>Đã lập phiếu #${data.receipt_id||data.loan_id}. <button type="button" class="text-button" data-desk-trace="${type}:${data.id}">Xem yêu cầu #${data.id} và tài nguyên đã giao</button></p>`;
    await loadCounterResources();
    form.elements.note.value='';
  } catch(error){showError($('#counter-result'),error.message);} finally {button.disabled=false;deskState.counterBusy=false;}
});

$('#request-trace-form').addEventListener('submit',event=>{event.preventDefault();const form=event.currentTarget;showRequestTrace(form.elements.type.value,form.elements.request_id.value);});
$('#account-full-close').addEventListener('click',()=>{deskState.accountSerial++;$('#account-full-panel').classList.add('is-hidden');$('#account-table button')?.focus();});
document.addEventListener('click',event=>{
  const account=event.target.closest('[data-account-detail]'); if(account) openAccountFull(account.dataset.accountDetail);
  const receipt=event.target.closest('[data-desk-receipt]'); if(receipt) openLoanReceiptDetail(receipt.dataset.deskReceipt);
  const trace=event.target.closest('[data-desk-trace]');
  if(trace){const [type,id]=trace.dataset.deskTrace.split(':');setView('circulation',{focus:true});$('#request-trace-form').elements.type.value=type;$('#request-trace-form').elements.request_id.value=id;showRequestTrace(type,id);}
  const remove=event.target.closest('[data-counter-remove]'); if(remove) remove.closest('.counter-line').remove();
});
if(state.user) configureCirculationDesk();
