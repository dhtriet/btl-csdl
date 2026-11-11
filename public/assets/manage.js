const management = { type: 'books', page: 1, search: '', visibility: 'all', serial: 0, record: null, options: { publishers: [], books: [] } };
const managementLabels = { books: 'Đầu sách', copies: 'Bản sách', rooms: 'Phòng học', equipment: 'Thiết bị' };
const resourceStatuses = { available:'Sẵn sàng', borrowed:'Đang mượn', unavailable:'Không khả dụng', maintenance:'Bảo trì', inactive:'Tạm ngừng', damaged:'Hư hỏng', lost:'Thất lạc', good:'Tốt', worn:'Cũ', classroom:'Phòng học', meeting_room:'Phòng họp' };
const managementFields = {
  books: [
    ['title','Tên sách','text',true,240], ['publisher_id','Nhà xuất bản','publishers',true],
    ['language','Ngôn ngữ','text',true,60], ['publication_year','Năm xuất bản','number',false,2155,1901],
    ['pages','Số trang','number',false,1000000,1], ['authors','Tác giả (ngăn cách bằng dấu ;)','names'],
    ['genres','Thể loại (ngăn cách bằng dấu ;)','names'], ['keywords','Từ khóa (ngăn cách bằng dấu ;)','names'],
    ['summary','Tóm tắt','textarea'], ['description','Mô tả','textarea'],
  ],
  copies: [
    ['book_id','Thuộc đầu sách','books',true], ['barcode','Mã vạch','text',true,40],
    ['storage_location','Vị trí lưu trữ','text',true,120], ['condition_status','Tình trạng','enum',true,['good','worn','damaged','lost']],
    ['status','Tình trạng hoạt động','enum',true,['available','damaged','lost']],
  ],
  rooms: [
    ['name','Tên phòng','text',true,100], ['room_type','Loại phòng','enum',true,['classroom','meeting_room']],
    ['location','Vị trí','text',true,160], ['capacity','Sức chứa','number',true,10000,1],
    ['included_equipment','Thiết bị trong phòng','text',false,255], ['operating_hours','Giờ hoạt động','text',false,120],
    ['status','Tình trạng hoạt động','enum',true,['available','maintenance','inactive']],
  ],
  equipment: [
    ['name','Tên thiết bị','text',true,160], ['equipment_type','Loại thiết bị','text',true,100],
    ['manufacturer','Hãng sản xuất','text',false,120], ['total_quantity','Tổng số lượng','number',true,1000000,1],
    ['storage_location','Vị trí lưu trữ','text',false,160], ['serial_number','Số serial','text',false,120],
    ['status','Tình trạng hoạt động','enum',true,['available','borrowed','maintenance','damaged','unavailable']],
    ['description','Mô tả','textarea'], ['usage_guide','Hướng dẫn sử dụng','textarea'],
  ],
};

async function loadManager() {
  const serial = ++management.serial;
  const target = $('#management-table');
  target.innerHTML = '<div class="empty-state" role="status">Đang tải tài nguyên…</div>';
  $('#management-add').textContent = `Thêm ${managementLabels[management.type].toLowerCase()}`;
  $$('#management-tabs button').forEach(button => {
    const selected = button.dataset.resourceType === management.type;
    button.classList.toggle('is-active', selected);
    button.setAttribute('aria-pressed', selected ? 'true' : 'false');
  });
  try {
    const query = new URLSearchParams({ page: management.page, search: management.search, visibility: management.visibility });
    const response = await api(`/api/manage/${management.type}?${query}`);
    if (serial !== management.serial) return;
    const rows = response.data;
    management.page=Number(response.page);
    const type = management.type;
    const heads = type === 'books' ? ['Đầu sách','Ngôn ngữ / Năm',''] : type === 'copies' ? ['Mã vạch / Đầu sách','Vị trí','Tình trạng','Tình trạng hoạt động',''] : type === 'rooms' ? ['Phòng / Vị trí','Loại / Sức chứa','Tình trạng hoạt động',''] : ['Thiết bị / Loại','Còn / Tổng','Tình trạng hoạt động',''];
    target.innerHTML = rows.length ? `<table class="data-table"><thead><tr>${heads.map(text=>`<th scope="col">${text}</th>`).join('')}</tr></thead><tbody>${rows.map(row => {
      let cells;
      if (type === 'books') cells = [`<strong>${escapeHtml(row.title)}</strong><small>#${row.id}</small>`, `${escapeHtml(row.language)} · ${escapeHtml(row.publication_year || 'Chưa rõ năm')}`];
      else if (type === 'copies') cells = [`<strong>${escapeHtml(row.barcode)}</strong><small>${escapeHtml(row.book_title)}</small>`, escapeHtml(row.storage_location), resourceStatuses[row.condition_status], resourceStatuses[row.status]];
      else if (type === 'rooms') cells = [`<strong>${escapeHtml(row.name)}</strong><small>${escapeHtml(row.location)}</small>`, `${resourceStatuses[row.room_type]} · ${row.capacity} chỗ`, resourceStatuses[row.status]];
      else cells = [`<strong>${escapeHtml(row.name)}</strong><small>${escapeHtml(row.equipment_type)}</small>`, `${row.available_quantity} / ${row.total_quantity}`, resourceStatuses[row.status]];
      const photo=row.cover_image || row.image_path;
      cells[0]=`<div class="managed-resource">${photo?`<img class="managed-thumb ${type==='books'||type==='copies'?'is-cover':''}" src="${escapeHtml(photo)}" alt="" loading="lazy">`:''}<div>${cells[0]}<small class="visibility-label">${Number(row.is_visible)?'● Hiện':'○ Đã ẩn'}${type==='copies'&&!Number(row.book_visible)?' · Đầu sách đang ẩn':''}</small></div></div>`;
      return `<tr>${cells.map(cell=>`<td>${cell}</td>`).join('')}<td><button class="request-link" data-edit-resource="${row.id}" aria-label="Sửa ${escapeHtml(row.title || row.name || row.barcode)}">Chỉnh sửa</button><button class="text-button" data-toggle-resource="${row.id}" data-visible="${row.is_visible}">${Number(row.is_visible)?'Ẩn':'Hiện'}</button><button class="text-button resource-delete" data-delete-resource="${row.id}" aria-label="Xóa ${escapeHtml(row.title || row.name || row.barcode)}">Xóa</button></td></tr>`;
    }).join('')}</tbody></table>` : '<div class="empty-state">Chưa có tài nguyên phù hợp. Thêm mới hoặc thay đổi từ khóa tìm kiếm.</div>';
    $('#management-count').textContent = `${response.total} ${managementLabels[type].toLowerCase()}`;
    const pages = Math.max(1, Math.ceil(response.total / response.page_size));
    $('#management-pagination').innerHTML = `<span>Trang ${management.page} / ${pages}</span><div><button data-manage-page="${management.page-1}" ${management.page===1?'disabled':''}>Trang trước</button><button data-manage-page="${management.page+1}" ${management.page>=pages?'disabled':''}>Trang sau</button></div>`;
    $$('[data-edit-resource]').forEach(button => button.addEventListener('click',()=>openResourceEditor(button.dataset.editResource)));
    $$('[data-toggle-resource]').forEach(button=>button.addEventListener('click',()=>mutateResource(button,'PATCH')));
    $$('[data-delete-resource]').forEach(button=>button.addEventListener('click',()=>mutateResource(button,'DELETE')));
    $$('[data-manage-page]').forEach(button => button.addEventListener('click',()=>{ management.page=Number(button.dataset.managePage); loadManager(); }));
  } catch(error) { showError(target,error.message); $('#management-pagination').innerHTML=''; }
}

async function openResourceEditor(id = null) {
  try {
    const type = management.type;
    const [options, record] = await Promise.all([api('/api/manage/options'), id ? api(`/api/manage/${type}/${id}`) : Promise.resolve({ data: {} })]);
    management.options=options.data;
    management.record=record.data;
    const data=record.data;
    $('#resource-editor-title').textContent = `${id?'Chỉnh sửa':'Thêm'} ${managementLabels[type].toLowerCase()}`;
    $('#resource-editor-hint').textContent = type==='equipment' ? 'Số lượng còn sẵn được tính tự động, giữ nguyên số đang mượn và số không khả dụng.' : type==='copies' ? 'Mỗi bản sách có một mã vạch riêng. Bản đang được mượn cần được nhận trả trước khi sửa.' : type==='books'?'Đầu sách lưu thông tin chung và ảnh bìa; thêm từng cuốn có mã vạch tại Bản sách.':'Các trường có dấu * là bắt buộc.';
    $('#resource-editor-fields').innerHTML = managementFields[type].map(([name,label,kind,required,max,min]) => {
      const value=data[name] ?? (kind==='enum'?max[0]:'');
      const disabled=name==='book_id'&&id?'disabled':'';
      let input;
      if (kind==='enum' || kind==='publishers' || kind==='books') {
        const choices=kind==='enum'?max.map(value=>({ id:value, name:resourceStatuses[value] })):management.options[kind].map(item=>({ id:item.id, name:item.name || item.title }));
        input=`<select name="${name}" ${required?'required':''} ${disabled}>${kind==='enum'?'':'<option value="">Chọn…</option>'}${choices.map(item=>`<option value="${escapeHtml(item.id)}" ${String(item.id)===String(value)?'selected':''}>${escapeHtml(item.name)}</option>`).join('')}</select>`;
      } else if (kind==='textarea') input=`<textarea name="${name}" rows="3" maxlength="${name==='description'?20000:10000}">${escapeHtml(value)}</textarea>`;
      else input=`<input name="${name}" type="${kind==='number'?'number':'text'}" value="${escapeHtml(kind==='names'?(data[name] || []).join('; '):value)}" ${required?'required':''} ${kind==='number'?`min="${min}" max="${max}" step="1"`: `maxlength="${max || 3000}"`}>`;
      return `<label class="${kind==='textarea'?'field-wide':''}">${label}${required?' *':''}${input}</label>`;
    }).join('');
    $('#resource-editor-fields').insertAdjacentHTML('afterbegin', `<label class="field-wide">Hiển thị với người dùng<select name="is_visible"><option value="1" ${Number(data.is_visible??1)?'selected':''}>Hiện</option><option value="0" ${Number(data.is_visible??1)?'':'selected'}>Đã ẩn</option></select><small>Ẩn khỏi danh mục và yêu cầu mới; giữ nguyên lịch sử mượn trả.</small></label>`);
    if (type!=='copies') {
      const image=data.cover_image || data.image_path || '';
      const field=type==='books'?'cover_image':'image_path';
      $('#resource-editor-fields').insertAdjacentHTML('beforeend', `<label class="field-wide">${type==='books'?'Ảnh bìa':'Hình ảnh'} (JPG, PNG, WebP; tối đa 2 MB)<input name="cover_file" type="file" accept="image/jpeg,image/png,image/webp"><input name="${field}" type="hidden" value="${escapeHtml(image)}"><span class="cover-preview" id="resource-image-preview">${image?`<img src="${escapeHtml(image)}" alt="Ảnh hiện tại">`:''}</span></label><div class="field-wide"><button type="button" class="text-button" id="resource-remove-image">Gỡ ảnh</button>${type!=='books'?`<label class="resource-illustration-choice"><input type="checkbox" name="image_is_illustration" value="1" ${Number(data.image_is_illustration)?'checked':''}> Ảnh minh họa</label>`:''}</div>`);
      const fileInput=$('#resource-editor-form').elements.cover_file;
      fileInput.addEventListener('change',()=>{ const file=fileInput.files[0]; if(!file)return; if(file.size>2*1024*1024){showToast('Ảnh vượt quá 2 MB.');fileInput.value='';return;} const url=URL.createObjectURL(file); const img=document.createElement('img');img.alt='Ảnh đã chọn';img.onload=()=>URL.revokeObjectURL(url);img.src=url;$('#resource-image-preview').replaceChildren(img); if(type!=='books')$('#resource-editor-form').elements.image_is_illustration.checked=false; });
      $('#resource-remove-image').addEventListener('click',()=>{fileInput.value='';$('#resource-editor-form').elements[field].value='';$('#resource-image-preview').replaceChildren();});
    }
    $('#resource-editor-error').classList.add('is-hidden');
    $('#resource-editor-save').disabled=false;
    $('#resource-editor').classList.remove('is-hidden');
  } catch(error) { showToast(error.message); }
}

async function saveManagedResource(event) {
  event.preventDefault();
  const button=$('#resource-editor-save');
  if(button.disabled) return;
  button.disabled=true; button.textContent='Đang lưu…';
  const form=event.currentTarget;
  const formData=new FormData(form);
  const body=Object.fromEntries(formData.entries());
  try {
    if (body.cover_file?.size) {
      const isBook=management.type==='books';
      const file=new FormData(); file.append(isBook?'cover':'image',body.cover_file);
      const response=await fetch(isBook?'/api/manage/cover':'/api/manage/image',{ method:'POST', credentials:'same-origin', headers:{'X-CSRF-Token':state.csrfToken}, body:file });
      const data=await response.json();
      if(!response.ok) throw new Error(data.message || 'Không tải được ảnh bìa.');
      const field=isBook?'cover_image':'image_path'; body[field]=data.data.path;
      // Keep the uploaded path if form validation requires another attempt.
      form.elements[field].value=body[field];
      form.elements.cover_file.value='';
    }
    delete body.cover_file;
    if(['rooms','equipment'].includes(management.type)) body.image_is_illustration=body.image_is_illustration?1:0;
    if(management.type==='books') for(const name of ['authors','genres','keywords']) body[name]=(body[name] || '').split(';').map(text=>text.trim()).filter(Boolean);
    if(management.record.id) body.version=management.record.version;
    await api(`/api/manage/${management.type}${management.record.id?'/'+management.record.id:''}`,{ method:management.record.id?'PUT':'POST', body:JSON.stringify(body) });
    $('#resource-editor').classList.add('is-hidden');
    await loadManager();
    showToast('Đã lưu tài nguyên.');
  } catch(error) {
    const target=$('#resource-editor-error'); target.textContent=error.message; target.classList.remove('is-hidden'); target.focus();
  } finally { button.disabled=false; button.textContent='Lưu tài nguyên'; }
}

document.addEventListener('DOMContentLoaded',()=>{
  $('#management-visibility').addEventListener('change',event=>{management.visibility=event.target.value;management.page=1;loadManager();});
  $('#management-add').addEventListener('click',()=>openResourceEditor());
  $('#management-search-form').addEventListener('submit',event=>{ event.preventDefault(); management.search=$('#management-search').value.trim(); management.page=1; loadManager(); });
  $('#management-reload').addEventListener('click',loadManager);
  $$('#management-tabs button').forEach(button=>button.addEventListener('click',()=>{ management.type=button.dataset.resourceType; management.page=1; management.search=''; $('#management-search').value=''; loadManager(); }));
  $('#resource-editor-form').addEventListener('submit',saveManagedResource);
  $('#close-resource-editor').addEventListener('click',()=>$('#resource-editor').classList.add('is-hidden'));
  $('#resource-editor-cancel').addEventListener('click',()=>$('#resource-editor').classList.add('is-hidden'));
});

async function mutateResource(button,method) {
  const type=management.type;
  const id=button.dataset.deleteResource || button.dataset.toggleResource;
  if(method==='DELETE'&&!window.confirm('Xóa tài nguyên khỏi danh mục? Lịch sử mượn trả vẫn được giữ. Nếu còn khoản mượn hoặc yêu cầu cần xử lý, hệ thống sẽ chặn xóa.'))return;
  button.disabled=true;
  try {
    const {data}=await api(`/api/manage/${type}/${id}`);
    await api(`/api/manage/${type}/${id}`,{method,body:JSON.stringify({version:data.version,is_visible:Number(data.is_visible)?0:1})});
    if(type===management.type)await loadManager();
    showToast(method==='DELETE'?'Đã xóa khỏi danh mục.':'Đã cập nhật hiển thị.');
  } catch(error){showToast(error.message);} finally{button.disabled=false;}
}
