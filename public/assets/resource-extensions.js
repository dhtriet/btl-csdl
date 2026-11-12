/* Equipment and room renewals share the existing circulation dialog and review panel. */
function resourceRenewalButton(type, id, title, deadline, requests = []) {
  const own = requests.filter(r => r.resource_type === type && Number(r[type === 'room' ? 'room_request_id' : 'equipment_detail_id']) === Number(id));
  const pending = own.some(r => r.status === 'pending');
  const limit = own.filter(r => r.status === 'approved').length >= 3;
  return `<button type="button" class="return-button" data-resource-renew="${type}" data-target-id="${Number(id)}" data-title="${escapeHtml(title)}" data-deadline="${escapeHtml(deadline)}" ${pending || limit ? 'disabled' : ''}>${pending ? 'Chờ duyệt gia hạn' : limit ? 'Đã gia hạn 3 lần' : 'Gia hạn'}</button>`;
}

function bindResourceRenewals(container) {
  container.querySelectorAll('[data-resource-renew]').forEach(button => button.addEventListener('click', () => {
    if (state.user?.role !== 'student') return;
    const room = button.dataset.resourceRenew === 'room';
    const current = button.dataset.deadline;
    const min = room ? null : [addDaysToDate(current, 1), dateAfter(0)].sort().at(-1);
    $('#extension-modal-content').innerHTML = `<h2 id="extension-modal-title">Yêu cầu gia hạn ${room ? 'không gian' : 'thiết bị'}</h2><p>${escapeHtml(button.dataset.title)}</p><p>Hạn hiện tại: <strong>${room ? formatDateTime(current) : formatDate(current)}</strong></p><form id="resource-extension-form" class="stack-form"><label>${room ? 'Giờ kết thúc đề nghị (cùng ngày)' : 'Hạn trả đề nghị'}<input name="deadline" ${room ? 'type="text" inputmode="numeric" pattern="(?:[01][0-9]|2[0-3]):[0-5][0-9]|24:00" placeholder="Ví dụ: 18:00"' : `type="date" min="${min}" value="${min}"`} required></label><label>Lý do (không bắt buộc)<textarea name="reason" maxlength="500" rows="3"></textarea></label><p class="form-hint">Hạn chỉ thay đổi sau khi thủ thư duyệt. Tối đa 3 lần gia hạn.${room ? ' Giờ mới phải sau giờ hiện tại, không quá 24:00 và không trùng lịch đã duyệt.' : ''}</p><div id="extension-error" class="error-state is-hidden" role="alert"></div><button class="primary-button" type="submit">Gửi yêu cầu gia hạn</button></form>`;
    $('#extension-modal').classList.remove('is-hidden');
    $('#resource-extension-form').addEventListener('submit', async event => {
      event.preventDefault();
      const form = event.currentTarget, submit = form.querySelector('button');
      const values = new FormData(form);
      submit.disabled = true;
      try {
        await api('/api/resource-extension-requests', { method: 'POST', body: JSON.stringify({ resource_type: button.dataset.resourceRenew, target_id: Number(button.dataset.targetId), [room ? 'new_end_time' : 'new_due_date']: values.get('deadline'), reason: values.get('reason') }) });
        closeExtensionModal();
        await loadCirculation();
        if (room) await loadPersonalRoomRenewals();
        showToast('Đã gửi yêu cầu gia hạn. Vui lòng chờ thủ thư duyệt.');
      } catch (error) { showError($('#extension-error'), error.message); submit.disabled = false; }
    });
  }));
}

async function loadPersonalRoomRenewals() {
  const containers = [$('#personal-room-renewals'), $('#spaces-room-renewals')].filter(Boolean);
  containers.forEach(el => el.closest('article').classList.toggle('is-hidden', state.user?.role !== 'student'));
  if (state.user?.role !== 'student') return;
  const userId = state.user.id;
  try {
    const [rooms, requests] = await Promise.all([api('/api/room-requests?status=approved'), api('/api/resource-extension-requests')]);
    if (state.user?.id !== userId) return;
    const active = rooms.data.filter(r => new Date(`${r.use_date}T${r.end_time}`) > new Date());
    const html = active.length ? `<table class="data-table"><thead><tr><th>Không gian</th><th>Thời gian sử dụng</th><th>Gia hạn</th></tr></thead><tbody>${active.map(r => `<tr><td><strong>${escapeHtml(r.room_name)}</strong><br>Yêu cầu #${r.id}</td><td>${formatDate(r.use_date)} · ${formatTime(r.start_time)}–${formatTime(r.end_time)}</td><td>${resourceRenewalButton('room', r.id, r.room_name, `${r.use_date} ${r.end_time}`, requests.data)}</td></tr>`).join('')}</tbody></table>` : '<div class="empty-state">Chưa có lịch phòng đã duyệt còn thời gian sử dụng để gia hạn.</div>';
    containers.forEach(el => { el.innerHTML = html; bindResourceRenewals(el); });
  } catch (error) { if (state.user?.id === userId) containers.forEach(el => showError(el, error.message)); }
}

function renderResourceExtensionRequests(items) {
  const container = document.createElement('div');
  if (!items.length) return container;
  const labels = { pending: 'Chờ duyệt', approved: 'Đã duyệt', rejected: 'Từ chối' };
  const deadline = (item, key) => item.resource_type === 'room' ? formatDateTime(item[key]) : formatDate(item[key].slice(0, 10));
  container.innerHTML = `<h3>Thiết bị và không gian</h3><table class="data-table"><thead><tr><th>Tài nguyên / người mượn</th><th>Hạn sử dụng</th><th>Trạng thái</th><th>Xử lý</th></tr></thead><tbody>${items.map(item => `<tr><td><strong>${escapeHtml(item.title)}</strong><br>${item.resource_type === 'room' ? 'Không gian' : 'Thiết bị'} · ${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}${item.reason ? `<br>Lý do: ${escapeHtml(item.reason)}` : ''}</td><td>Hạn cũ: ${deadline(item, 'old_deadline')}<br>Đề nghị: <strong>${deadline(item, 'requested_deadline')}</strong></td><td><span class="status-pill ${item.status === 'pending' ? 'warning' : ''}">${labels[item.status]}</span>${item.return_date || item.booking_status === 'completed' ? '<br>Đã kết thúc sử dụng' : ''}</td><td>${state.user?.role === 'librarian' && item.status === 'pending' ? `<button class="return-button" type="button" data-review-resource-extension="${item.id}">Xem yêu cầu</button>` : escapeHtml(item.librarian_name || 'Đang chờ thủ thư')}${item.review_note ? `<br>${escapeHtml(item.review_note)}` : ''}</td></tr>`).join('')}</tbody></table>`;
  container.querySelectorAll('[data-review-resource-extension]').forEach(button => button.addEventListener('click', () => {
    const item = items.find(r => Number(r.id) === Number(button.dataset.reviewResourceExtension));
    $('#extension-modal-content').innerHTML = `<h2 id="extension-modal-title">Xét yêu cầu gia hạn</h2><p>${escapeHtml(item.title)} · ${escapeHtml(item.student_name)}</p><p>Hạn cũ: ${deadline(item, 'old_deadline')}<br>Đề nghị: <strong>${deadline(item, 'requested_deadline')}</strong></p><p>Lý do: ${escapeHtml(item.reason || 'Không cung cấp')}</p><form id="resource-extension-review" class="stack-form"><label>Ghi chú xử lý (bắt buộc khi từ chối)<textarea name="review_note" maxlength="500" rows="3"></textarea></label><div id="extension-error" class="error-state is-hidden" role="alert"></div><button class="primary-button" type="submit" value="approved">Duyệt gia hạn</button><button class="text-button" type="submit" value="rejected">Từ chối yêu cầu</button></form>`;
    $('#extension-modal').classList.remove('is-hidden');
    $('#resource-extension-review').addEventListener('submit', async event => {
      event.preventDefault();
      const form = event.currentTarget, status = event.submitter?.value;
      form.querySelectorAll('button').forEach(b => b.disabled = true);
      try {
        await api(`/api/resource-extension-requests/${item.id}/review`, { method: 'POST', body: JSON.stringify({ status, review_note: new FormData(form).get('review_note') }) });
        closeExtensionModal();
        await Promise.all([loadCirculation(), loadReturns()]);
        showToast(status === 'approved' ? 'Đã duyệt và cập nhật hạn sử dụng.' : 'Đã từ chối yêu cầu gia hạn.');
      } catch (error) { showError($('#extension-error'), error.message); form.querySelectorAll('button').forEach(b => b.disabled = false); }
    });
  }));
  return container;
}
