const state = {
  user: null,
  currentView: 'dashboard',
  catalogRequestId: 0,
  bookRequestItems: [],
  equipmentRequestItems: [],
  roomCalendarView: 'day',
};
const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => [...document.querySelectorAll(selector)];

const viewTitles = {
  dashboard: 'Tổng quan',
  catalog: 'Kho sách',
  requests: 'Yêu cầu mượn',
  circulation: 'Mượn & trả',
  spaces: 'Không gian học tập',
  equipment: 'Thiết bị & dụng cụ',
  approvals: 'Duyệt yêu cầu',
  reports: 'Báo cáo thống kê',
  admin: 'Quản trị tài khoản',
  manage: 'Quản lý tài nguyên',
  assistant: 'Trợ lý học tập',
};

function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function formatDate(value) {
  if (!value) return '—';
  const parts = String(value).slice(0, 10).split('-');
  return parts.length === 3 ? `${parts[2]}/${parts[1]}/${parts[0]}` : value;
}

function formatDateTime(value) {
  if (!value) return '—';
  const date = String(value).replace('T', ' ');
  return `${formatDate(date.slice(0, 10))} ${date.slice(11, 16)}`;
}

function formatTime(value) {
  return String(value || '').slice(0, 5);
}

function isRoomTime(value) {
  return /^(?:[01][0-9]|2[0-3]):[0-5][0-9]$|^24:00$/.test(String(value || ''));
}

function roomTimeMinutes(value) {
  const [hours, minutes] = String(value).split(':').map(Number);
  return hours * 60 + minutes;
}

async function api(path, options = {}) {
  const response = await fetch(path, {
    credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json', ...(state.csrfToken ? { 'X-CSRF-Token': state.csrfToken } : {}), ...(options.headers || {}) },
    ...options,
  });
  const data = await response.json().catch(() => ({}));
  if (response.status === 401 && state.user) {
    state.csrfToken = null;
    setUser(null);
    $('#login-form [name="username"]')?.focus();
    throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại để tiếp tục.');
  }
  if (data.csrf_token) state.csrfToken = data.csrf_token;
  if (!response.ok) throw new Error(data.message || 'Không thể kết nối tới máy chủ.');
  return data;
}

function showToast(message) {
  const toast = $('#toast');
  toast.textContent = message;
  toast.classList.add('is-visible');
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => toast.classList.remove('is-visible'), 2800);
}

function showError(element, message) {
  element.innerHTML = `<div class="error-state">${escapeHtml(message)}</div>`;
}

function setUser(user) {
  $('#extension-requests-list').replaceChildren();
  ['personal-room-renewals', 'spaces-room-renewals'].forEach(id => {
    const el = document.getElementById(id);
    el.replaceChildren();
    el.closest('article').classList.add('is-hidden');
  });
  state.user = user;
  if (typeof configureCirculationDesk === 'function') configureCirculationDesk();
  if (!user) {
    $('#login-screen').classList.remove('is-hidden');
    $('#app-shell').classList.add('is-hidden');
    delete document.body.dataset.role;
    state.bookRequestItems = [];
    state.equipmentRequestItems = [];
    $('#login-form').reset();
    document.title = 'Đăng nhập · Nexus';
    closeAllDialogs();
    resetAssistant();
    return;
  }

  $('#login-screen').classList.add('is-hidden');
  $('#app-shell').classList.remove('is-hidden');
  $('#user-name').textContent = user.name;
  $('#user-role').textContent = user.role === 'admin' ? 'Quản trị viên' : user.role === 'librarian' ? 'Thủ thư' : 'Sinh viên';
  $('#user-avatar').textContent = user.name.split(' ').slice(-2).map((part) => part[0]).join('').toUpperCase();
  $('#admin-nav').classList.toggle('is-hidden', user.role !== 'admin');
  $('#student-requests-nav').classList.toggle('is-hidden', user.role !== 'student');
  $('#librarian-approvals-nav').classList.toggle('is-hidden', user.role !== 'librarian');
  $('#librarian-return-desk').classList.toggle('is-hidden', user.role !== 'librarian');
  document.body.dataset.role = user.role;
  configureWorkspace();
}

function allowedViews() {
  const common = ['assistant', 'dashboard', 'catalog', 'circulation', 'spaces', 'equipment'];
  if (state.user?.role === 'student') return [...common, 'requests'];
  return [...common, 'manage', 'reports', ...(state.user?.role === 'librarian' ? ['approvals'] : ['admin'])];
}

function configureWorkspace() {
  const student = state.user.role === 'student';
  const librarian = state.user.role === 'librarian';
  configureCampusDashboard(student);
  $$('.main-nav [data-view]').forEach((button) => button.classList.toggle('is-hidden', !allowedViews().includes(button.dataset.view)));
  $('.main-nav [data-view="circulation"]').lastChild.textContent = student ? ' Đang mượn & lịch sử' : ' Mượn & trả';
  $('#dashboard-heading').innerHTML = student ? `Chào ${escapeHtml(state.user.name.split(' ').at(-1))},<br><span>hôm nay học gì?</span>` : librarian ? 'Bàn làm việc của thủ thư' : 'Tổng quan trung tâm';
  $('#dashboard-description').textContent = student ? 'Tài nguyên, lịch mượn và không gian học tập của bạn, ở cùng một nơi.' : librarian ? 'Ưu tiên yêu cầu đang chờ và tài nguyên cần thu hồi.' : 'Theo dõi tài nguyên, hoạt động mượn trả và quản lý tài khoản.';
  const primary = $('#dashboard-primary');
  primary.dataset.view = student ? 'catalog' : librarian ? 'approvals' : 'reports';
  primary.innerHTML = `${student ? 'Khám phá kho sách' : librarian ? 'Duyệt yêu cầu' : 'Xem báo cáo'} ${uiIcon('arrow')}`;
  $('#dashboard-attention-title').textContent = student ? 'Tài nguyên đang mượn' : 'Cần xử lý hôm nay';
  $('#dashboard-attention-description').textContent = student ? 'Sắp xếp theo hạn trả gần nhất.' : 'Theo dõi các đầu việc đang cần bạn chú ý.';
  $('#dashboard-requests-title').textContent = student ? 'Yêu cầu của bạn' : 'Hàng chờ duyệt';
  $('#dashboard-requests-description').textContent = student ? 'Các yêu cầu gần nhất và trạng thái hiện tại.' : 'Những yêu cầu tài nguyên được gửi đến trung tâm.';
  $('#dashboard-workspace-link').dataset.view = student ? 'requests' : librarian ? 'approvals' : 'admin';
  $('#workspace-link-title').textContent = student ? 'Yêu cầu của tôi' : librarian ? 'Duyệt yêu cầu' : 'Quản lý tài khoản';
  $('#workspace-link-description').textContent = student ? 'Xem giỏ mượn và trạng thái yêu cầu' : librarian ? 'Xử lý các yêu cầu đang chờ' : 'Tra cứu tài khoản và vai trò';
  const heading = $('#view-circulation .section-intro h1');
  heading.textContent = student ? 'Tài nguyên đang mượn & lịch sử' : 'Mượn và trả';
  $('#view-circulation .section-intro p:not(.eyebrow)').textContent = student ? 'Theo dõi hạn trả và lịch sử mượn tài nguyên của riêng bạn.' : 'Mỗi cuốn trong một phiếu có hạn trả và lịch sử riêng.';
  $('#view-circulation .lookup-box').classList.toggle('is-hidden', student);
  const panels = $$('#view-circulation .circulation-grid .panel h2');
  panels[0].textContent = student ? 'Tài nguyên đang mượn' : 'Sách cần xử lý';
  panels[1].textContent = student ? 'Lịch sử của bạn' : 'Lịch sử gần đây';
  const circulationBadge = $('#view-circulation .panel-badge.danger');
  circulationBadge.classList.toggle('is-hidden', state.user?.role === 'librarian');
  circulationBadge.textContent = student ? 'Theo hạn trả' : 'Ưu tiên quá hạn lâu';
}

function configureCampusDashboard(student) {
  const dashboard = $('#view-dashboard');
  if (student && !dashboard.campusOrigins) {
    const layout = document.createElement('div');
    layout.className = 'campus-layout';
    layout.innerHTML = '<div class="campus-main"></div><div class="campus-personal"><h2>Góc học tập của bạn</h2></div>';
    dashboard.append(layout);
    const selectors = ['#campus-discovery', '#dashboard-top-books', '.resource-shortcuts', '#dashboard-stats', '.attention-panel', '#dashboard-requests'];
    dashboard.campusOrigins = selectors.map((selector, index) => {
      let node = dashboard.querySelector(selector);
      if (selector === '#dashboard-top-books' || selector === '#dashboard-requests') node = node.closest('.panel');
      const marker = document.createComment('workspace-position');
      node.before(marker);
      layout.querySelector(index < 3 ? '.campus-main' : '.campus-personal').append(node);
      return { node, marker };
    });
    const assistant = document.createElement('button');
    assistant.type = 'button';
    assistant.className = 'campus-assistant-link';
    assistant.innerHTML = `${uiIcon('catalog')}<span><strong>Học cùng trợ lý Nexus</strong><small>Hỏi về sách, tìm ý tưởng và hiểu sâu kiến thức.</small></span>${uiIcon('arrow')}`;
    assistant.addEventListener('click', () => setView('assistant', { focus: true }));
    layout.querySelector('.campus-personal').append(assistant);
  } else if (!student && dashboard.campusOrigins) {
    dashboard.campusOrigins.forEach(({ node, marker }) => marker.replaceWith(node));
    dashboard.querySelector('.campus-layout').remove();
    delete dashboard.campusOrigins;
  }
}

function closeCampusMenu() {
  document.body.classList.remove('campus-menu-open');
  $('#campus-menu').setAttribute('aria-expanded', 'false');
  $('#campus-menu').setAttribute('aria-label', 'Mở menu điều hướng');
}

$('#campus-menu').addEventListener('click', () => {
  const open = document.body.classList.toggle('campus-menu-open');
  $('#campus-menu').setAttribute('aria-expanded', String(open));
  $('#campus-menu').setAttribute('aria-label', open ? 'Đóng menu điều hướng' : 'Mở menu điều hướng');
  if (open) {
    const destination = $('.main-nav .nav-item.is-active:not(.is-hidden)') || $('.main-nav .nav-item:not(.is-hidden)');
    destination?.focus({ preventScroll: true });
  }
});
document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && document.body.classList.contains('campus-menu-open')) {
    closeCampusMenu(); $('#campus-menu').focus();
  }
});
document.addEventListener('click', (event) => {
  if (event.target.closest('[data-campus-find-book]')) setView('catalog', { focus: true });
  if (document.body.classList.contains('campus-menu-open') && !event.target.closest('.sidebar, #campus-menu')) closeCampusMenu();
});
window.matchMedia('(min-width: 761px)').addEventListener('change', closeCampusMenu);

function uiIcon(name) {
  return `<svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-${name}"/></svg>`;
}

function setView(view, { historyMode = 'push', focus = false } = {}) {
  if (!state.user) return;
  closeCampusMenu();
  if (!allowedViews().includes(view)) view = 'dashboard';
  const changed = state.currentView !== view;
  state.currentView = view;
  $$('.page-view').forEach((item) => item.classList.toggle('is-visible', item.id === `view-${view}`));
  $$('.nav-item').forEach((item) => {
    const active = item.dataset.view === view;
    item.classList.toggle('is-active', active);
    if (active) item.setAttribute('aria-current', 'page'); else item.removeAttribute('aria-current');
  });
  $('#page-title').textContent = view === 'circulation' && state.user.role === 'student' ? 'Đang mượn & lịch sử' : viewTitles[view];
  document.title = `${$('#page-title').textContent} · Nexus`;
  const hash = `#${view}`;
  if (location.hash !== hash) history[historyMode === 'replace' ? 'replaceState' : 'pushState'](null, '', hash);
  if (changed) { closeAllDialogs(); window.scrollTo({ top: 0, behavior: 'instant' }); }
  if (focus) $('#main-content').focus({ preventScroll: true });
  const loaders = {
    dashboard: loadDashboard, catalog: loadCatalog, requests: loadStudentRequests,
    circulation: () => Promise.all([loadCirculation(), state.user.role === 'librarian' ? loadReturns() : Promise.resolve()]),
    spaces: loadSpaces, equipment: loadEquipment, approvals: loadApprovals, reports: loadReports, admin: loadAdmin, manage: loadManager, assistant: loadAssistant,
  };
  loaders[view]?.();
}

function renderStats(data) {
  const student = state.user.role === 'student';
  const stats = student ? [
    ['Đang mượn', data.active_loans.length, 'circulation', 'circulation'],
    ['Quá hạn', data.overdue_count, 'circulation', 'requests'],
    ['Chờ duyệt', data.pending_requests, 'requests', 'approvals'],
    ['Lịch phòng', data.upcoming_rooms.length, 'spaces', 'spaces'],
  ] : [
    ['Đầu sách trong kho', data.books, 'catalog', 'catalog'],
    ['Bản sách sẵn sàng', data.available_copies, 'catalog', 'catalog'],
    ['Sách đang quá hạn', data.overdue_books, 'circulation', 'circulation'],
    ['Yêu cầu chờ duyệt', data.pending_requests, state.user.role === 'librarian' ? 'approvals' : 'reports', 'approvals'],
  ];
  $('#dashboard-stats').innerHTML = stats.map(([label, value, target, icon], i) => `<button class="stat-card${i === (student ? 1 : 2) && Number(value) > 0 ? ' has-warning' : ''}" data-target="${target}"><span class="stat-top">${escapeHtml(label)}${uiIcon(icon)}</span><strong>${escapeHtml(value)}</strong><span class="stat-footer">${i === 0 && !student ? 'Khám phá tài nguyên' : 'Xem chi tiết'} ${uiIcon('arrow')}</span></button>`).join('');
  $$('[data-target]').forEach((button) => button.addEventListener('click', () => setView(button.dataset.target, { focus: true })));
}

function renderRankList(element, items, nameKey, valueKey, suffix = 'lượt') {
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Chưa có dữ liệu thống kê.</div>';
    return;
  }
  element.innerHTML = items.map((item, index) => `<div class="rank-row"><span class="rank-number">0${index + 1}</span><div><strong>${escapeHtml(item[nameKey])}</strong><small>${escapeHtml(item.authors || item.equipment_type || item.room_type || '')}</small></div><span class="rank-value">${escapeHtml(item[valueKey])} ${suffix}</span></div>`).join('');
}

function renderRequests(element, requests) {
  if (!requests.length) {
    element.innerHTML = '<div class="empty-state">Không có yêu cầu chờ xử lý.</div>';
    return;
  }
  element.innerHTML = requests.map((item) => {
    const title = item.request_label || item.room_name || 'Yêu cầu tài nguyên';
    const details = item.items || `${formatDate(item.use_date)} · ${formatTime(item.start_time)}–${formatTime(item.end_time)}`;
    return `<div class="request-row"><strong>${escapeHtml(title)}</strong><span>${escapeHtml(item.student_name || '')}${item.student_name ? ' · ' : ''}${escapeHtml(details)}</span><em>${escapeHtml(item.status === 'pending' ? 'Chờ duyệt' : item.status)}</em></div>`;
  }).join('');
}

function renderPersonalLoans(items, extensionRequests = []) {
  if (!items.length) return `<div class="empty-state">${uiIcon('catalog')}<strong>Bạn chưa mượn tài nguyên nào.</strong><p>Một cuốn sách cho buổi học tiếp theo đang chờ bạn khám phá.</p><button type="button" class="text-button" data-campus-find-book>Tìm sách để mượn ${uiIcon('arrow')}</button></div>`;
  return items.map((item) => {
    const pending = extensionRequests.some(r => Number(r.loan_detail_id) === Number(item.loan_detail_id) && r.status === 'pending');
    let renewal = item.resource_type === 'book' && item.loan_detail_id && !item.return_date && state.user?.role === 'student'
      ? `<button type="button" class="return-button extension-button" data-extension-id="${item.loan_detail_id}" data-extension-due="${escapeHtml(item.due_date)}" ${pending || Number(item.extension_count) >= 3 ? 'disabled' : ''}>${pending ? 'Chờ duyệt gia hạn' : Number(item.extension_count) >= 3 ? 'Đã gia hạn 3 lần' : 'Gia hạn'}</button>` : '';
    if (item.resource_type === 'equipment' && item.equipment_detail_id && !item.return_date && state.user?.role === 'student') renewal = resourceRenewalButton('equipment', item.equipment_detail_id, item.resource_name, item.due_date, extensionRequests);
    return `<div class="personal-loan"><span class="loan-icon">${uiIcon(item.resource_type === 'book' ? 'catalog' : 'equipment')}</span><div><strong>${escapeHtml(item.resource_name)}</strong><small>${item.resource_type === 'book' ? 'Sách' : `Thiết bị · ${escapeHtml(item.quantity || 1)} chiếc`} · Hạn trả ${formatDate(item.due_date)}</small>${renewal}</div><span class="status-pill ${Number(item.overdue) > 0 ? 'danger' : ''}">${Number(item.overdue) > 0 ? 'Quá hạn' : 'Đang mượn'}</span></div>`;
  }).join('');
}

async function loadDashboard() {
  const role = state.user?.role;
  const panel = $('#dashboard-attention');
  panel.innerHTML = '<div class="empty-state" role="status">Đang tải hoạt động của bạn…</div>';
  try {
    const { data } = await api('/api/dashboard');
    if (state.user?.role !== role) return;
    renderStats(data);
    if (role === 'student') renderCampusBooks(data.top_books);
    else renderRankList($('#dashboard-top-books'), data.top_books, 'title', 'borrow_count');
    $('#pending-count').textContent = `${data.pending_requests ?? 0} chờ duyệt`;
    if (role === 'student') {
      panel.innerHTML = renderPersonalLoans(data.active_loans.slice(0, 4));
      const requests = data.recent_requests;
      $('#dashboard-requests').innerHTML = requests.length ? requests.slice(0, 3).map((item) => `<div class="overview-request"><div><strong>${item.request_type === 'book' ? 'Mượn sách' : item.request_type === 'room' ? 'Đặt phòng' : 'Mượn thiết bị'} #${escapeHtml(item.id)}</strong><small>${formatDateTime(item.requested_at)}</small></div><span class="status-pill ${item.status === 'pending' ? 'warning' : item.status === 'rejected' ? 'danger' : ''}">${requestStatus(item.status)}</span><p>${escapeHtml(item.items)}</p></div>`).join('') : '<div class="empty-state">Chưa có yêu cầu nào. Bạn có thể bắt đầu từ kho sách.</div>';
    } else {
      const jobs = [
        [data.pending_requests, 'Yêu cầu chờ duyệt', 'Sách, thiết bị và không gian học tập', role === 'librarian' ? 'approvals' : 'reports', 'approvals'],
        [data.overdue_books, 'Sách đã quá hạn trả', 'Kiểm tra và theo dõi các khoản mượn', 'circulation', 'circulation'],
        [data.available_equipment, 'Thiết bị đang sẵn sàng', 'Tra cứu số lượng có thể cho mượn', 'equipment', 'equipment'],
      ];
      panel.innerHTML = jobs.map(([count, title, description, target, icon]) => `<button class="work-item" data-job-view="${target}"><span class="loan-icon">${uiIcon(icon)}</span><span><strong>${title}</strong><small>${description}</small></span><span class="work-count">${count}</span>${uiIcon('arrow')}</button>`).join('');
      $$('[data-job-view]').forEach((button) => button.addEventListener('click', () => setView(button.dataset.jobView, { focus: true })));
      renderRequests($('#dashboard-requests'), data.recent_requests.slice(0, 3));
    }
  } catch (error) {
    showError(panel, error.message);
    $('#dashboard-stats').innerHTML = '';
    showError($('#dashboard-requests'), 'Không tải được dữ liệu. Chọn Tổng quan để thử lại.');
  }
}

function renderCampusBooks(books) {
  const container = $('#dashboard-top-books');
  if (!books.length) { container.innerHTML = '<div class="empty-state">Chưa có dữ liệu sách được mượn. Khám phá kho sách để bắt đầu.</div>'; return; }
  container.innerHTML = books.slice(0, 5).map((book, index) => `<button type="button" class="campus-book-row" data-campus-book="${index}"><span class="campus-book-cover" aria-hidden="true">${book.cover_image?`<img src="${escapeHtml(book.cover_image)}" alt="" loading="lazy">`:uiIcon('catalog')}</span><span class="campus-book-info"><strong>${escapeHtml(book.title)}</strong><small>${escapeHtml(book.authors || 'Chưa cập nhật tác giả')}</small><span>${escapeHtml(book.borrow_count)} lượt mượn</span></span>${uiIcon('arrow')}</button>`).join('');
  container.querySelectorAll('[data-campus-book]').forEach(button => button.addEventListener('click', () => {
    $('#book-search').value = books[Number(button.dataset.campusBook)].title;
    $('#book-language').value = ''; $('#book-year').value = '';
    setView('catalog', { focus: true });
  }));
}

function renderBookGrid(books, page = 1) {
  state.catalogBooks = books;
  state.catalogPage = page;
  const pageSize = 12;
  const displayedBooks = books.slice((page - 1) * pageSize, page * pageSize);
  const pages = Math.ceil(books.length / pageSize);
  const pagination = $('#catalog-pagination');
  pagination.innerHTML = pages > 1 ? `<span>Hiển thị ${(page - 1) * pageSize + 1}–${Math.min(page * pageSize, books.length)} trong ${books.length} đầu sách</span><div><button id="catalog-prev" ${page === 1 ? 'disabled' : ''}>Trang trước</button><span>Trang ${page} / ${pages}</span><button id="catalog-next" ${page === pages ? 'disabled' : ''}>Trang sau</button></div>` : '';
  const changePage = (next) => {
    renderBookGrid(state.catalogBooks, next);
    $('#book-grid').scrollIntoView({ block: 'start' });
    $('#catalog-pagination').focus({ preventScroll: true });
  };
  $('#catalog-prev')?.addEventListener('click', () => changePage(page - 1));
  $('#catalog-next')?.addEventListener('click', () => changePage(page + 1));
  $('#book-count').textContent = `${books.length} đầu sách`;
  if (!books.length) {
    $('#book-grid').innerHTML = '<div class="empty-state">Không tìm thấy sách phù hợp với bộ lọc hiện tại.</div>';
    return;
  }
  const canRequestBooks = state.user?.role === 'student';
  $('#book-grid').innerHTML = displayedBooks.map((book) => `<article class="book-card">
    <div class="book-cover">${book.cover_image ? `<img loading="lazy" src="${escapeHtml(book.cover_image)}" alt="Bìa ${escapeHtml(book.title)}">` : `<div class="book-cover-fallback">${uiIcon('catalog')}</div>`}<span class="availability">Còn ${escapeHtml(book.available_copies || 0)} / ${escapeHtml(book.copy_count || 0)} bản</span></div>
    <div class="book-content"><h4>${escapeHtml(book.title)}</h4><div class="book-meta">${escapeHtml(book.authors || 'Chưa cập nhật tác giả')}<br>${escapeHtml(book.publisher)} · ${escapeHtml(book.publication_year || '—')}</div><div class="book-stock">Kho sách: còn <strong>${escapeHtml(book.available_copies || 0)}</strong> bản / tổng ${escapeHtml(book.copy_count || 0)} bản</div><div class="book-tags">${String(book.genres || '').split(', ').filter(Boolean).slice(0, 2).map((tag) => `<span>${escapeHtml(tag)}</span>`).join('')}</div><div class="book-actions"><small>${escapeHtml(book.language)}</small><div><button data-book-id="${book.id}">Chi tiết</button>${book.has_ebook ? `<button class="request-link" data-read-book-id="${book.id}">Đọc</button>` : ''}${canRequestBooks ? `<button class="request-link" data-add-book-id="${book.id}" ${Number(book.available_copies) < 1 ? 'disabled' : ''}>${Number(book.available_copies) < 1 ? 'Hết bản' : 'Mượn +'}</button>` : ''}</div></div></div>
  </article>`).join('');
  $$('[data-book-id]').forEach((button) => button.addEventListener('click', () => openBookModal(button.dataset.bookId)));
  $$('[data-add-book-id]').forEach((button) => button.addEventListener('click', () => {
    const book = books.find((item) => String(item.id) === button.dataset.addBookId);
    if (book) openBookRequestModal(book);
  }));
  $$('[data-read-book-id]').forEach((button) => button.addEventListener('click', () => openEbookReader(button.dataset.readBookId)));
}

async function loadCatalog() {
  const requestId = ++state.catalogRequestId;
  const search = $('#book-search').value.trim();
  const language = $('#book-language').value;
  const year = $('#book-year').value;
  const params = new URLSearchParams();
  if (search) params.set('search', search);
  if (language) params.set('language', language);
  if (year) params.set('year', year);
  try {
    const { data } = await api(`/api/books?${params.toString()}`);
    if (requestId !== state.catalogRequestId) return;
    renderBookGrid(data);
  } catch (error) {
    if (requestId !== state.catalogRequestId) return;
    showError($('#book-grid'), error.message);
  }
}

function dateAfter(days) {
  const date = new Date();
  date.setHours(12, 0, 0, 0);
  date.setDate(date.getDate() + days);
  return date.toISOString().slice(0, 10);
}

function addBookToRequest(book, quantity, requestedDueDate) {
  if (state.bookRequestItems.some((item) => item.book_id === Number(book.id))) {
    showToast('Cuốn sách này đã có trong yêu cầu.');
    return false;
  }
  state.bookRequestItems.push({
    book_id: Number(book.id),
    title: book.title,
    quantity: Math.min(Number(book.available_copies) || 1, Math.max(1, Number(quantity) || 1)),
    available_quantity: Number(book.available_copies) || 1,
    requested_due_date: requestedDueDate || dateAfter(14),
  });
  renderBookRequestCart();
  showToast(`Đã thêm “${book.title}” vào yêu cầu.`);
  return true;
}

function addEquipmentToRequest(equipment, quantity, requestedDueDate) {
  if (state.equipmentRequestItems.some((item) => item.equipment_id === Number(equipment.id))) {
    showToast('Thiết bị này đã có trong yêu cầu.');
    return false;
  }
  state.equipmentRequestItems.push({
    equipment_id: Number(equipment.id),
    name: equipment.name,
    quantity: quantity || 1,
    available_quantity: Number(equipment.available_quantity),
    requested_due_date: requestedDueDate || dateAfter(7),
  });
  renderEquipmentRequestCart();
  showToast(`Đã thêm “${equipment.name}” vào yêu cầu.`);
  return true;
}

function openBookRequestModal(book) {
  const minDate = dateAfter(1);
  const currentNote = $('#book-request-note').value;
  $('#resource-request-modal-content').innerHTML = `<p class="eyebrow accent">BOOK BORROW REQUEST</p>
    <h2 id="resource-request-modal-title">Mượn ${escapeHtml(book.title)}</h2>
    <p class="modal-subtitle">${escapeHtml(book.authors || 'Chưa cập nhật tác giả')} · ${escapeHtml(book.publisher)} · ${escapeHtml(book.publication_year || '—')}</p>
    <div class="resource-summary">
      <span><strong>Ngôn ngữ</strong>${escapeHtml(book.language)}</span>
      <span><strong>Bản sẵn sàng</strong>${escapeHtml(book.available_copies || 0)} / ${escapeHtml(book.copy_count || 0)} bản</span>
      <span><strong>Ngày mượn thực tế</strong>Thủ thư xác nhận khi duyệt</span>
    </div>
    <form id="book-request-form" class="stack-form" data-book-id="${book.id}" data-book-title="${escapeHtml(book.title)}">
      <div class="resource-form-fields">
        <label>Số lượng<input name="quantity" type="number" min="1" max="${escapeHtml(book.available_copies || 1)}" value="1" required></label>
        <label>Hạn trả dự kiến<input name="requested_due_date" type="date" min="${minDate}" value="${dateAfter(14)}" required></label>
      </div>
      <label>Ghi chú cho thủ thư<textarea name="note" rows="3" maxlength="255" placeholder="Ví dụ: Phục vụ đồ án môn học">${escapeHtml(currentNote)}</textarea></label>
      <button class="primary-button" type="submit">Thêm vào yêu cầu mượn <span>→</span></button>
    </form>`;
  $('#resource-request-modal').classList.remove('is-hidden');
  $('#book-request-form').addEventListener('submit', (event) => submitBookRequestItem(event, book));
}

function openEquipmentRequestModal(equipment) {
  const minDate = dateAfter(1);
  const currentNote = $('#equipment-request-note').value;
  $('#resource-request-modal-content').innerHTML = `<p class="eyebrow accent">EQUIPMENT BORROW REQUEST</p>
    <h2 id="resource-request-modal-title">Mượn ${escapeHtml(equipment.name)}</h2>
    <p class="modal-subtitle">${escapeHtml(equipment.equipment_type)} · ${escapeHtml(equipment.manufacturer || 'Chưa cập nhật hãng sản xuất')}</p>
    <div class="resource-summary">
      <span><strong>Số lượng sẵn sàng</strong>${escapeHtml(equipment.available_quantity)} / ${escapeHtml(equipment.total_quantity)} đơn vị</span>
      <span><strong>Vị trí lưu trữ</strong>${escapeHtml(equipment.storage_location || 'Chưa cập nhật')}</span>
      <span><strong>Ngày mượn thực tế</strong>Thủ thư xác nhận khi duyệt</span>
    </div>
    <form id="equipment-request-form" class="stack-form" data-equipment-id="${equipment.id}" data-equipment-name="${escapeHtml(equipment.name)}">
      <div class="resource-form-fields">
        <label>Số lượng<input name="quantity" type="number" min="1" max="${escapeHtml(equipment.available_quantity)}" value="1" required></label>
        <label>Hạn trả dự kiến<input name="requested_due_date" type="date" min="${minDate}" value="${dateAfter(7)}" required></label>
      </div>
      <label>Ghi chú cho thủ thư<textarea name="note" rows="3" maxlength="255" placeholder="Ví dụ: Dùng cho buổi thuyết trình">${escapeHtml(currentNote)}</textarea></label>
      <button class="primary-button" type="submit">Thêm vào yêu cầu mượn <span>→</span></button>
    </form>`;
  $('#resource-request-modal').classList.remove('is-hidden');
  $('#equipment-request-form').addEventListener('submit', (event) => submitEquipmentRequestItem(event, equipment));
}

function submitBookRequestItem(event, book) {
  event.preventDefault();
  const form = event.currentTarget;
  const formData = new FormData(form);
  const quantity = Math.min(Number(book.available_copies) || 1, Math.max(1, Number(formData.get('quantity')) || 1));
  const added = addBookToRequest(book, quantity, String(formData.get('requested_due_date') || ''));
  if (!added) return;
  $('#book-request-note').value = String(formData.get('note') || '').trim();
  closeResourceRequestModal();
}

function submitEquipmentRequestItem(event, equipment) {
  event.preventDefault();
  const form = event.currentTarget;
  const formData = new FormData(form);
  const quantity = Math.min(Number(equipment.available_quantity), Math.max(1, Number(formData.get('quantity')) || 1));
  const added = addEquipmentToRequest(equipment, quantity, String(formData.get('requested_due_date') || ''));
  if (!added) return;
  $('#equipment-request-note').value = String(formData.get('note') || '').trim();
  closeResourceRequestModal();
}

function renderBookRequestCart() {
  const cart = $('#book-request-cart');
  const totalBooks = state.bookRequestItems.reduce((total, item) => total + Number(item.quantity || 1), 0);
  $('#book-request-count').textContent = `${totalBooks} cuốn`;
  cart.closest('.panel').classList.toggle('is-cart-empty', !state.bookRequestItems.length);
  if (!state.bookRequestItems.length) {
    cart.innerHTML = '<div class="empty-state">Chưa có sách. Mở Kho sách và chọn “Mượn +”.<button class="primary-button desktop-only" type="button" data-cart-start="catalog">Chọn sách để mượn</button></div>';
    cart.querySelector('[data-cart-start]').addEventListener('click', () => setView('catalog', { focus: true }));
    return;
  }

  const minDate = dateAfter(1);
  cart.innerHTML = state.bookRequestItems.map((item) => `<div class="request-cart-item book-cart-item"><div><strong>${escapeHtml(item.title)}</strong><small>Còn ${escapeHtml(item.available_quantity || 0)} bản · chọn hạn trả riêng</small></div><label>Số lượng<input data-book-request-quantity="${item.book_id}" type="number" min="1" max="${escapeHtml(item.available_quantity || 1)}" value="${escapeHtml(item.quantity || 1)}"></label><label>Hạn trả<input data-book-request-due="${item.book_id}" type="date" min="${minDate}" value="${escapeHtml(item.requested_due_date)}"></label><button class="icon-button" type="button" data-remove-book-request="${item.book_id}" aria-label="Bỏ sách">×</button></div>`).join('');
  $$('[data-book-request-quantity]').forEach((input) => input.addEventListener('change', () => {
    const item = state.bookRequestItems.find((entry) => entry.book_id === Number(input.dataset.bookRequestQuantity));
    if (!item) return;
    item.quantity = Math.min(item.available_quantity || 1, Math.max(1, Number(input.value) || 1));
    input.value = item.quantity;
    renderBookRequestCart();
  }));
  $$('[data-book-request-due]').forEach((input) => input.addEventListener('change', () => {
    const item = state.bookRequestItems.find((entry) => entry.book_id === Number(input.dataset.bookRequestDue));
    if (item && input.value) item.requested_due_date = input.value;
  }));
  $$('[data-remove-book-request]').forEach((button) => button.addEventListener('click', () => {
    state.bookRequestItems = state.bookRequestItems.filter((item) => item.book_id !== Number(button.dataset.removeBookRequest));
    renderBookRequestCart();
  }));
}

function renderEquipmentRequestCart() {
  const cart = $('#equipment-request-cart');
  $('#equipment-request-count').textContent = `${state.equipmentRequestItems.length} mục`;
  cart.closest('.panel').classList.toggle('is-cart-empty', !state.equipmentRequestItems.length);
  if (!state.equipmentRequestItems.length) {
    cart.innerHTML = '<div class="empty-state">Chưa có thiết bị. Mở Thiết bị và chọn “Mượn +”.<button class="primary-button desktop-only" type="button" data-cart-start="equipment">Chọn thiết bị để mượn</button></div>';
    cart.querySelector('[data-cart-start]').addEventListener('click', () => setView('equipment', { focus: true }));
    return;
  }

  const minDate = dateAfter(1);
  cart.innerHTML = state.equipmentRequestItems.map((item) => `<div class="request-cart-item equipment-cart-item"><div><strong>${escapeHtml(item.name)}</strong><small>Còn ${escapeHtml(item.available_quantity)} đơn vị</small></div><label>Số lượng<input data-equipment-request-quantity="${item.equipment_id}" type="number" min="1" max="${item.available_quantity}" value="${item.quantity}"></label><label>Hạn trả<input data-equipment-request-due="${item.equipment_id}" type="date" min="${minDate}" value="${escapeHtml(item.requested_due_date)}"></label><button class="icon-button" type="button" data-remove-equipment-request="${item.equipment_id}" aria-label="Bỏ thiết bị">×</button></div>`).join('');
  $$('[data-equipment-request-quantity]').forEach((input) => input.addEventListener('change', () => {
    const item = state.equipmentRequestItems.find((entry) => entry.equipment_id === Number(input.dataset.equipmentRequestQuantity));
    if (!item) return;
    item.quantity = Math.min(item.available_quantity, Math.max(1, Number(input.value) || 1));
    input.value = item.quantity;
  }));
  $$('[data-equipment-request-due]').forEach((input) => input.addEventListener('change', () => {
    const item = state.equipmentRequestItems.find((entry) => entry.equipment_id === Number(input.dataset.equipmentRequestDue));
    if (item && input.value) item.requested_due_date = input.value;
  }));
  $$('[data-remove-equipment-request]').forEach((button) => button.addEventListener('click', () => {
    state.equipmentRequestItems = state.equipmentRequestItems.filter((item) => item.equipment_id !== Number(button.dataset.removeEquipmentRequest));
    renderEquipmentRequestCart();
  }));
}

function requestStatus(status) {
  return ({ pending: 'Chờ duyệt', approved: 'Đã duyệt', rejected: 'Từ chối', cancelled: 'Đã hủy', completed: 'Đã kết thúc' }[status] || status);
}

function renderStudentBorrowRequests(items) {
  const element = $('#my-borrow-requests');
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Bạn chưa gửi yêu cầu mượn nào.</div>';
    return;
  }
  element.innerHTML = items.map((item) => {
    const type = item.request_type === 'book' ? 'Mượn sách' : item.request_type === 'equipment' ? 'Mượn thiết bị' : 'Đặt phòng';
    const tone = item.status === 'pending' ? 'warning' : item.status === 'rejected' ? 'danger' : item.status === 'approved' ? 'is-approved' : 'is-completed';
    const note = item.review_note ? `<small>Phản hồi: ${escapeHtml(item.review_note)}</small>` : '';
    const items = String(item.items || '').replaceAll('(han ', '(hạn ');
    return `<div class="request-row"><strong>${type} #${escapeHtml(item.id)}</strong><span>${escapeHtml(items)} · gửi ${formatDate(item.requested_at)}</span>${item.note ? `<small>Ghi chú: ${escapeHtml(item.note)}</small>` : ''}${note}<em class="status-pill ${tone}">${requestStatus(item.status)}</em>${item.request_type!=='room'?`<button class="text-button" type="button" data-desk-trace="${escapeHtml(item.request_type)}:${Number(item.id)}">Xem phiếu liên quan</button>`:''}</div>`;
  }).join('');
}

async function loadStudentRequests() {
  renderBookRequestCart();
  renderEquipmentRequestCart();
  try {
    const { data } = await api('/api/borrow-requests/mine');
    renderStudentBorrowRequests(data);
  } catch (error) {
    showError($('#my-borrow-requests'), error.message);
  }
}

async function submitBookRequest() {
  if (!state.bookRequestItems.length) return showToast('Hãy thêm ít nhất một cuốn sách.');
  const button = $('#submit-book-request');
  button.disabled = true;
  try {
    await api('/api/book-loan-requests', {
      method: 'POST',
      body: JSON.stringify({ items: state.bookRequestItems.map(({ book_id, quantity, requested_due_date }) => ({ book_id, quantity, requested_due_date })), note: $('#book-request-note').value.trim() }),
    });
    state.bookRequestItems = [];
    $('#book-request-note').value = '';
    await loadStudentRequests();
    showToast('Đã gửi yêu cầu mượn sách để thủ thư duyệt.');
  } catch (error) {
    showToast(error.message);
  } finally {
    button.disabled = false;
  }
}

async function submitEquipmentRequest() {
  if (!state.equipmentRequestItems.length) return showToast('Hãy thêm ít nhất một thiết bị.');
  const button = $('#submit-equipment-request');
  button.disabled = true;
  try {
    await api('/api/equipment-loan-requests', {
      method: 'POST',
      body: JSON.stringify({ items: state.equipmentRequestItems.map(({ equipment_id, quantity, requested_due_date }) => ({ equipment_id, quantity, requested_due_date })), note: $('#equipment-request-note').value.trim() }),
    });
    state.equipmentRequestItems = [];
    $('#equipment-request-note').value = '';
    await loadStudentRequests();
    showToast('Đã gửi yêu cầu mượn thiết bị để thủ thư duyệt.');
  } catch (error) {
    showToast(error.message);
  } finally {
    button.disabled = false;
  }
}

function renderOverdueBooks(items) {
  if (!items.length) {
    $('#overdue-books-table').innerHTML = '<div class="empty-state">Tuyệt vời — hiện không có sách quá hạn.</div>';
    return;
  }
  $('#overdue-books-table').innerHTML = `<table class="data-table"><thead><tr><th>Sách</th><th>Sinh viên</th><th>Hạn trả</th><th>Quá hạn</th><th>Gia hạn</th></tr></thead><tbody>${items.map((item) => `<tr><td><strong>${escapeHtml(item.title)}</strong><br><span class="muted">${escapeHtml(item.barcode)}</span></td><td>${escapeHtml(item.student_name)}<br><span class="muted">${escapeHtml(item.student_code)}</span></td><td>${formatDate(item.due_date)}</td><td class="danger-text">${escapeHtml(item.overdue_days)} ngày</td><td>${escapeHtml(item.extension_count)} lần</td></tr>`).join('')}</tbody></table>`;
}

function renderReturnedBooks(items) {
  if (!items.length) {
    $('#returned-books-list').innerHTML = '<div class="empty-state">Chưa có lịch sử trả sách.</div>';
    return;
  }
  $('#returned-books-list').innerHTML = items.slice(0, 6).map((item) => `<div class="history-item"><i></i><div><strong>${escapeHtml(item.title)}</strong><small>${escapeHtml(item.student_name)} · trả ${formatDate(item.return_date)}</small></div><span class="status-pill ${item.return_status === 'Tra tre' ? 'danger' : ''}">${item.return_status === 'Tra tre' ? `Trễ ${item.late_days} ngày` : 'Đúng hạn'}</span></div>`).join('');
}

async function loadCirculation() {
  try {
    if (state.user?.role === 'student') {
      const userId = state.user.id;
      const [{ data }, requests] = await Promise.all([api(`/api/students/${encodeURIComponent(state.user.student_code)}/history`), api('/api/extension-requests')]);
      if (state.user?.id !== userId) return;
      const active = data.items.filter((item) => !item.return_date).map((item) => ({ ...item, overdue: item.status === 'Qua han' })).sort((a, b) => a.due_date.localeCompare(b.due_date));
      $('#overdue-books-table').innerHTML = renderPersonalLoans(active, requests.data);
      $('#overdue-books-table').querySelectorAll('.extension-button').forEach(button => button.addEventListener('click', () => openExtensionModal(button)));
      bindResourceRenewals($('#overdue-books-table'));
      renderExtensionRequests(requests.data);
      await loadPersonalRoomRenewals();
      const returned = data.items.filter((item) => item.return_date).sort((a, b) => b.return_date.localeCompare(a.return_date));
      $('#returned-books-list').innerHTML = returned.length ? returned.map((item) => `<div class="request-row"><strong>${escapeHtml(item.resource_name)}</strong><span>Đã trả ${formatDate(item.return_date)} · ${item.resource_type === 'book' ? 'Sách' : 'Thiết bị'}</span></div>`).join('') : '<div class="empty-state">Chưa có tài nguyên đã trả.</div>';
      return;
    }
    const [overdue, returned] = await Promise.all([state.user?.role === 'librarian' ? Promise.resolve(null) : api('/api/overdue-books'), api('/api/books/returned')]);
    if (overdue) renderOverdueBooks(overdue.data);
    renderReturnedBooks(returned.data);
    await loadExtensionRequests();
  } catch (error) {
    showToast(error.message);
  }
}

function returnStatusLabel(item) {
  if (item.loan_status === 'Qua han') return `<span class="status-pill danger">Quá hạn ${escapeHtml(item.overdue_days)} ngày</span>`;
  return '<span class="status-pill warning">Đang mượn</span>';
}

function renderActiveBookReturns(items) {
  const element = $('#overdue-books-table');
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Không còn sách chưa trả.</div>';
    return;
  }
  element.innerHTML = `<table class="data-table"><thead><tr><th>Sách / sinh viên</th><th>Phiếu mượn</th><th>Hạn trả</th><th>Tình trạng</th><th>Thao tác</th></tr></thead><tbody>${items.map((item) => `<tr><td><strong>${escapeHtml(item.title)}</strong><br><span class="muted">${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}</span></td><td><button class="text-button" type="button" data-receipt-id="${item.receipt_id}">#${item.receipt_id}</button></td><td>${formatDate(item.due_date)}</td><td>${returnStatusLabel(item)}</td><td class="return-actions"><button class="return-button" type="button" data-return-kind="books" data-return-id="${item.loan_detail_id}">Đã trả</button></td></tr>`).join('')}</tbody></table>`;
}

function renderActiveEquipmentReturns(items) {
  const element = $('#active-equipment-returns');
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Không còn thiết bị chưa trả.</div>';
    return;
  }
  element.innerHTML = `<table class="data-table"><thead><tr><th>Thiết bị / sinh viên</th><th>SL</th><th>Hạn trả</th><th>Tình trạng</th><th></th></tr></thead><tbody>${items.map((item) => `<tr><td><strong>${escapeHtml(item.name)}</strong><br><span class="muted">${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}</span></td><td>${escapeHtml(item.quantity)}</td><td>${formatDate(item.due_date)}</td><td>${returnStatusLabel(item)}</td><td><button class="return-button" type="button" data-return-kind="equipment" data-return-id="${item.equipment_detail_id}">Đã trả</button></td></tr>`).join('')}</tbody></table>`;
}

function renderReturnedEquipment(items) {
  const element = $('#returned-equipment-list');
  element.innerHTML = items.length ? items.slice(0, 6).map((item) => `<div class="history-item"><i></i><div><strong>${escapeHtml(item.name)}</strong><small>${escapeHtml(item.student_name)} · trả ${formatDate(item.return_date)}</small></div><span class="status-pill ${item.return_status === 'Tra tre' ? 'danger' : ''}">${item.return_status === 'Tra tre' ? `Trễ ${item.late_days} ngày` : 'Đúng hạn'}</span></div>`).join('') : '<div class="empty-state">Chưa có lịch sử trả thiết bị.</div>';
}

function renderReturnedBookHistory(items) {
  const element = $('#returned-book-list');
  element.innerHTML = items.length ? items.slice(0, 6).map((item) => `<div class="history-item"><i></i><div><strong>${escapeHtml(item.title)}</strong><small>${escapeHtml(item.student_name)} · trả ${formatDate(item.return_date)}</small><button class="text-button history-detail-button" type="button" data-receipt-id="${item.receipt_id}">Xem phiếu #${item.receipt_id}</button></div><span class="status-pill ${item.return_status === 'Tra tre' ? 'danger' : ''}">${item.return_status === 'Tra tre' ? `Trễ ${item.late_days} ngày` : 'Đúng hạn'}</span></div>`).join('') : '<div class="empty-state">Chưa có lịch sử trả sách.</div>';
}

function renderRoomUsageHistory(items) {
  const element = $('#room-usage-history');
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Chưa có lịch sử đặt phòng.</div>';
    return;
  }
  const statusLabel = { approved: 'Đã duyệt', completed: 'Đã kết thúc', rejected: 'Từ chối' };
  element.innerHTML = `<table class="data-table"><thead><tr><th>Phòng / sinh viên</th><th>Thời gian</th><th>Mục đích</th><th>Trạng thái</th><th></th></tr></thead><tbody>${items.map((item) => {
    const finished = item.status === 'completed';
    const canComplete = item.status === 'approved';
    const roomType = item.room_type === 'classroom' ? 'Phòng học' : 'Phòng họp';
    return `<tr><td><strong>${escapeHtml(item.room_name)}</strong><br><span class="muted">${roomType} · ${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}</span></td><td>${formatDate(item.use_date)}<br>${formatTime(item.start_time)}–${formatTime(item.end_time)}</td><td>${escapeHtml(item.purpose)}</td><td><span class="status-pill ${item.status === 'rejected' ? 'danger' : finished ? '' : 'warning'}">${statusLabel[item.status] || escapeHtml(item.status)}</span></td><td>${canComplete ? `<button class="return-button room-complete-button" type="button" data-return-kind="rooms" data-return-id="${item.room_request_id}">Đã kết thúc</button>` : ''}</td></tr>`;
  }).join('')}</tbody></table>`;
}

async function loadReturns() {
  try {
    const [books, equipment, returnedBooks, returnedEquipment, rooms] = await Promise.all([api('/api/returns/books'), api('/api/returns/equipment'), api('/api/books/returned'), api('/api/equipment/returned'), api('/api/returns/rooms')]);
    renderActiveBookReturns(books.data);
    renderActiveEquipmentReturns(equipment.data);
    renderReturnedBookHistory(returnedBooks.data);
    renderReturnedEquipment(returnedEquipment.data);
    renderRoomUsageHistory(rooms.data);
    bindLoanReceiptButtons();
    $$('[data-return-kind]').forEach((button) => button.addEventListener('click', () => openReturnModal(button)));
  } catch (error) {
    showError($('#overdue-books-table'), error.message);
    showError($('#active-equipment-returns'), error.message);
    showError($('#room-usage-history'), error.message);
  }
}

function renderExtensionRequests(allItems) {
  const items = allItems.filter(item => !item.resource_type);
  const staff = state.user?.role === 'librarian';
  const labels = { pending: 'Chờ duyệt', approved: 'Đã duyệt', rejected: 'Từ chối' };
  $('#extension-requests-list').innerHTML = items.length ? `<table class="data-table"><thead><tr><th>Sách / người mượn</th><th>Hạn trả</th><th>Trạng thái</th><th>Xử lý</th></tr></thead><tbody>${items.map(item => `<tr><td><strong>${escapeHtml(item.title)}</strong><br>${escapeHtml(item.barcode)}<br>${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}${item.reason ? `<br>Lý do: ${escapeHtml(item.reason)}` : ''}</td><td>Hạn cũ: ${formatDate(item.old_due_date)}<br>Đề nghị: <strong>${formatDate(item.requested_due_date)}</strong></td><td><span class="status-pill ${item.status === 'pending' ? 'warning' : item.status === 'rejected' ? 'danger' : ''}">${labels[item.status]}</span><br><small>${item.return_date ? `Đã trả sách ${formatDate(item.return_date)}` : 'Sách chưa trả'}</small></td><td>${staff && item.status === 'pending' ? `<button class="return-button" data-review-extension="${item.id}">Xem yêu cầu</button>` : `${escapeHtml(item.librarian_name || 'Đang chờ thủ thư')}${item.review_note ? `<br>${escapeHtml(item.review_note)}` : ''}`}</td></tr>`).join('')}</tbody></table>` : (allItems.length ? '' : '<div class="empty-state">Chưa có yêu cầu gia hạn tài nguyên.</div>');
  $('#extension-requests-list').append(renderResourceExtensionRequests(allItems.filter(item => item.resource_type)));
  $$('[data-review-extension]').forEach(button => button.addEventListener('click', () => {
    const item = items.find(row => Number(row.id) === Number(button.dataset.reviewExtension));
    $('#extension-modal-content').innerHTML = `<h2 id="extension-modal-title">Xét yêu cầu gia hạn</h2><p>${escapeHtml(item.title)} · ${escapeHtml(item.barcode)}</p><p>${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}</p><p>Hạn cũ: ${formatDate(item.old_due_date)}<br>Hạn đề nghị: <strong>${formatDate(item.requested_due_date)}</strong></p><p>Lý do: ${escapeHtml(item.reason || 'Không cung cấp')}</p><form id="extension-review-form" class="stack-form"><label>Ghi chú xử lý (bắt buộc khi từ chối)<textarea name="review_note" rows="3" maxlength="500"></textarea></label><div id="extension-error" class="error-state is-hidden" role="alert"></div><button class="primary-button" name="decision" value="approved" type="submit" ${item.return_date ? 'disabled' : ''}>Duyệt gia hạn</button><button class="text-button" name="decision" value="rejected" type="submit">Từ chối yêu cầu</button></form>`;
    $('#extension-modal').classList.remove('is-hidden');
    $('#extension-review-form').addEventListener('submit', async event => {
      event.preventDefault();
      const form = event.currentTarget;
      const status = event.submitter?.value;
      const note = String(new FormData(form).get('review_note') || '').trim();
      if (status === 'rejected' && !note) { showError($('#extension-error'), 'Nhập lý do từ chối để sinh viên biết.'); return; }
      form.querySelectorAll('button').forEach(el => el.disabled = true);
      try {
        await api(`/api/extension-requests/${item.id}/review`, { method: 'POST', body: JSON.stringify({ status, review_note: note }) });
        closeExtensionModal();
        await Promise.all([loadCirculation(), loadReturns()]);
        showToast(status === 'approved' ? 'Đã duyệt gia hạn theo ngày sinh viên đề nghị.' : 'Đã từ chối yêu cầu gia hạn.');
      } catch (error) {
        showError($('#extension-error'), error.message);
        form.querySelectorAll('button').forEach(el => el.disabled = false);
      }
    });
  }));
}

async function loadExtensionRequests() {
  const userId = state.user?.id;
  try {
    const { data } = await api('/api/extension-requests');
    if (state.user?.id === userId) renderExtensionRequests(data);
  } catch (error) { if (state.user?.id === userId) showError($('#extension-requests-list'), error.message); }
}

$('#reload-extension-requests').addEventListener('click', () => state.user?.role === 'student' ? loadCirculation() : loadExtensionRequests());

function addDaysToDate(value, days) {
  const date = new Date(`${value}T12:00:00`);
  date.setDate(date.getDate() + days);
  return date.toISOString().slice(0, 10);
}

function openExtensionModal(button) {
  if (state.user?.role !== 'student') return;
  const row = button.closest('.personal-loan');
  const title = row?.querySelector('strong')?.textContent || 'sách';
  const currentDueDate = button.dataset.extensionDue;
  const minimum = [addDaysToDate(currentDueDate, 1), dateAfter(0)].sort().at(-1);
  const suggestedDate = [addDaysToDate(currentDueDate, 7), dateAfter(7)].sort().at(-1);
  $('#extension-modal-content').innerHTML = `<h2 id="extension-modal-title">Yêu cầu gia hạn sách</h2><p class="modal-subtitle">${escapeHtml(title)}</p><div class="extension-summary"><span>Hạn hiện tại</span><strong>${formatDate(currentDueDate)}</strong></div><form id="extension-form" class="stack-form" data-extension-id="${escapeHtml(button.dataset.extensionId)}" data-current-due="${escapeHtml(currentDueDate)}"><label>Hạn trả đề nghị<input name="new_due_date" type="date" min="${escapeHtml(minimum)}" value="${escapeHtml(suggestedDate)}" required></label><label>Lý do (không bắt buộc)<textarea name="reason" rows="3" maxlength="500"></textarea></label><p class="form-hint">Hạn trả chỉ thay đổi khi thủ thư duyệt. Tối đa 3 lần gia hạn được duyệt cho mỗi khoản mượn.</p><div class="error-state is-hidden" role="alert" id="extension-error"></div><button class="primary-button" type="submit">Gửi yêu cầu gia hạn <span>→</span></button></form>`;
  $('#extension-modal').classList.remove('is-hidden');
  $('#extension-form').addEventListener('submit', submitExtension);
}

async function submitExtension(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const button = form.querySelector('button[type="submit"]');
  const newDueDate = String(new FormData(form).get('new_due_date') || '');
  if (!newDueDate || newDueDate <= form.dataset.currentDue) {
    showToast('Hạn trả mới phải sau hạn trả hiện tại.');
    return;
  }
  button.disabled = true;
  try {
    await api('/api/extension-requests', {
      method: 'POST',
      body: JSON.stringify({ loan_detail_id: Number(form.dataset.extensionId), new_due_date: newDueDate, reason: new FormData(form).get('reason') }),
    });
    closeExtensionModal();
    await loadCirculation();
    showToast('Đã gửi yêu cầu gia hạn. Hạn trả hiện tại giữ nguyên cho đến khi thủ thư duyệt.');
  } catch (error) {
    showError($('#extension-error'), error.message);
    button.disabled = false;
  }
}

function openReturnModal(button) {
  if (button.dataset.returnKind === 'rooms') {
    markReturned(button);
    return;
  }
  const row = button.closest('tr');
  const resourceName = row?.querySelector('td strong')?.textContent || 'tài nguyên';
  const typeLabel = button.dataset.returnKind === 'books' ? 'sách' : 'thiết bị';
  $('#return-modal-content').innerHTML = `<h2 id="return-modal-title">Ghi nhận trả ${typeLabel}</h2><p class="modal-subtitle">${escapeHtml(resourceName)}</p><form id="return-form" class="stack-form" data-return-kind="${escapeHtml(button.dataset.returnKind)}" data-return-id="${escapeHtml(button.dataset.returnId)}"><label>Số ngày trễ<input name="late_days" type="number" min="0" max="65535" step="1" value="0" required></label><p class="form-hint">Nhập 0 nếu trả đúng hạn. Số ngày trễ do thủ thư xác nhận sẽ được lưu vào phiếu mượn.</p><button class="primary-button" type="submit">Xác nhận đã trả <span>→</span></button></form>`;
  $('#return-modal').classList.remove('is-hidden');
  $('#return-form').addEventListener('submit', submitReturnForm);
}

async function submitReturnForm(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const button = form.querySelector('button[type="submit"]');
  button.disabled = true;
  try {
    const success = await markReturned({ dataset: { returnKind: form.dataset.returnKind, returnId: form.dataset.returnId } }, { late_days: Number(new FormData(form).get('late_days')) });
    if (success) closeReturnModal();
    else button.disabled = false;
  } catch (error) {
    button.disabled = false;
  }
}

async function markReturned(button, returnDetails = {}) {
  const { returnKind, returnId } = button.dataset;
  button.disabled = true;
  try {
    const { data } = await api(`/api/returns/${returnKind}/${returnId}`, {
      method: 'POST',
      body: JSON.stringify(returnDetails),
    });
    await Promise.all([loadReturns(), loadCirculation(), loadEquipment(), loadDashboard()]);
    if (returnKind === 'rooms') {
      showToast('Đã đánh dấu lịch đặt phòng kết thúc.');
    } else {
      showToast(data.return_status === 'Tra tre' ? `Đã ghi nhận trả trễ ${data.late_days} ngày.` : 'Đã ghi nhận trả đúng hạn.');
    }
    return true;
  } catch (error) {
    showToast(error.message);
    button.disabled = false;
    return false;
  }
}

async function openStudentHistory() {
  const code = $('#student-history-code').value.trim();
  if (!code) return showToast('Nhập mã sinh viên cần tra cứu.');
  try {
    const { data } = await api(`/api/students/${encodeURIComponent(code)}/history`);
    $('#student-history-panel').classList.remove('is-hidden');
    $('#history-title').textContent = `Lịch sử của ${data.student.full_name}`;
    const bookCount = data.items.filter((item) => item.resource_type === 'book').length;
    $('#student-history-content').innerHTML = `<div class="history-summary"><span>${escapeHtml(data.student.student_code)}</span><span>${escapeHtml(data.student.faculty)}</span><span>${escapeHtml(data.student.class_name)}</span><span>${bookCount} cuốn sách · ${data.items.length} giao dịch</span></div>${data.items.length ? data.items.map((item) => { const receiptButton = item.resource_type === 'book' && item.receipt_id ? `<button class="text-button history-detail-button" type="button" data-receipt-id="${item.receipt_id}">Xem phiếu #${item.receipt_id}</button>` : ''; return `<div class="history-item"><i></i><div><strong>${escapeHtml(item.resource_name)}</strong><small>${item.resource_type === 'book' ? 'Sách · số lượng 1' : `Thiết bị · ${item.quantity || 1} đơn vị`} · mượn ${formatDate(item.borrow_date)} · hạn ${formatDate(item.due_date)}${item.return_date ? ` · trả ${formatDate(item.return_date)}` : ''}</small>${receiptButton}</div><span class="status-pill ${item.status === 'Qua han' || item.status.startsWith('Tra tre') ? 'danger' : item.status === 'Tra dung han' ? '' : 'warning'}">${escapeHtml(item.status)}</span></div>`; }).join('') : '<div class="empty-state">Sinh viên chưa có lịch sử mượn.</div>'}`;
    bindLoanReceiptButtons();
    $('#student-history-panel').scrollIntoView({ behavior: 'smooth', block: 'start' });
  } catch (error) {
    showToast(error.message);
  }
}

async function openLoanReceiptDetail(receiptId) {
  try {
    const { data } = await api(`/api/loan-receipts/${encodeURIComponent(receiptId)}`);
    const details = data.details || [];
    $('#loan-receipt-modal-content').innerHTML = `<p class="eyebrow accent">LOAN RECEIPT</p><h2 id="loan-receipt-modal-title">Chi tiết phiếu mượn #${escapeHtml(data.id)}</h2><p class="modal-subtitle">${escapeHtml(data.student_name)} · ${escapeHtml(data.student_code)} · thủ thư ${escapeHtml(data.librarian_name || '—')}</p><div class="loan-receipt-summary"><span>Mã phiếu<strong>#${escapeHtml(data.id)}</strong></span><span>Số lượng sách<strong>${escapeHtml(data.total_books ?? details.length)} cuốn</strong></span><span>Trạng thái<strong>${escapeHtml(data.status === 'completed' ? 'Đã hoàn tất' : 'Đang mượn')}</strong></span></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Sách</th><th>Số lượng</th><th>Ngày mượn</th><th>Hạn trả</th><th>Ngày trả</th><th>Trạng thái</th></tr></thead><tbody>${details.map((item) => `<tr><td><strong>${escapeHtml(item.title)}</strong><br><span class="muted">${escapeHtml(item.barcode)}</span></td><td>${escapeHtml(item.quantity || 1)}</td><td>${formatDate(item.borrow_date)}</td><td>${formatDate(item.due_date)}</td><td>${item.return_date ? formatDate(item.return_date) : 'Chưa trả'}</td><td>${escapeHtml(item.return_status === 'late' ? `Trễ ${item.late_days || 0} ngày` : item.return_date ? 'Đúng hạn' : item.status === 'overdue' ? 'Quá hạn' : 'Đang mượn')}</td></tr>`).join('')}</tbody></table></div>`;
    $('#loan-receipt-modal').classList.remove('is-hidden');
  } catch (error) {
    showToast(error.message);
  }
}

function bindLoanReceiptButtons() {
  $$('[data-receipt-id]').forEach((button) => button.addEventListener('click', () => openLoanReceiptDetail(button.dataset.receiptId)));
}

function renderRooms(rooms) {
  $('#room-result-count').textContent = `${rooms.length} phòng`;
  const canReserveRoom = state.user?.role === 'student';
  $('#available-rooms').innerHTML = rooms.length ? rooms.map((room) => `<div class="room-card">${resourcePhoto(room)}<strong>${escapeHtml(room.name)}</strong><small>${escapeHtml(room.location)} · ${room.room_type === 'classroom' ? 'Phòng học' : 'Phòng họp'}</small><div class="room-info"><span>${escapeHtml(room.capacity)} chỗ</span><span>${escapeHtml(room.included_equipment || 'Cơ bản')}</span></div>${canReserveRoom ? `<button class="request-link room-request-button" type="button" data-request-room-id="${room.id}">Đặt phòng +</button>` : ''}</div>`).join('') : '<div class="empty-state">Không có phòng phù hợp trong khung giờ này.</div>';
  $$('[data-request-room-id]').forEach((button) => button.addEventListener('click', () => {
    const room = rooms.find((item) => String(item.id) === button.dataset.requestRoomId);
    if (room) openRoomRequestModal(room);
  }));
}

function renderRoomSchedule(items, elementId = 'room-schedule') {
  const element = $(`#${elementId}`);
  if (!element) return;
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Chưa có lịch đặt phòng trong ngày này.</div>';
    return;
  }
  const statusLabel = { pending: 'Chờ duyệt', approved: 'Đã đặt', completed: 'Đã kết thúc' };
  element.innerHTML = `<table class="data-table"><thead><tr><th>Phòng</th><th>Khung giờ</th><th>Trạng thái</th><th>Mục đích</th></tr></thead><tbody>${items.map((item) => `<tr><td><strong>${escapeHtml(item.room_name)}</strong><br><span class="muted">${item.room_type === 'classroom' ? 'Phòng học' : 'Phòng họp'}</span></td><td>${formatTime(item.start_time)}–${formatTime(item.end_time)}</td><td><span class="status-pill ${item.status === 'pending' ? 'warning' : ''}">${statusLabel[item.status] || escapeHtml(item.status)}</span></td><td>${escapeHtml(item.purpose)}<br><span class="muted">${escapeHtml(item.student_name)} · ${escapeHtml(item.student_code)}</span></td></tr>`).join('')}</tbody></table>`;
}

function calendarStatusLabel(status) {
  return { pending: 'Chờ duyệt', approved: 'Đã đặt', completed: 'Đã kết thúc' }[status] || status;
}

function calendarEvent(item) {
  return `<div class="calendar-event ${escapeHtml(item.status)}"><div class="calendar-event-time">${formatTime(item.start_time)}–${formatTime(item.end_time)}</div><strong>${escapeHtml(item.room_name)}</strong><span>${escapeHtml(item.purpose || 'Không có mục đích')}</span><small>${calendarStatusLabel(item.status)}</small></div>`;
}

function renderDayCalendar(items, date) {
  const element = $('#room-schedule');
  if (!items.length) {
    element.innerHTML = `<div class="calendar-empty"><strong>${formatDate(date)}</strong><span>Chưa có lịch đặt hoặc yêu cầu trong ngày này.</span></div>`;
    return;
  }
  const grouped = items.reduce((groups, item) => {
    const key = String(item.room_id);
    groups[key] ||= { name: item.room_name, type: item.room_type, items: [] };
    groups[key].items.push(item);
    return groups;
  }, {});
  element.innerHTML = `<div class="calendar-day-header"><strong>Lịch ngày ${formatDate(date)}</strong><span>${items.length} lượt đặt / yêu cầu</span></div><div class="calendar-day-list">${Object.values(grouped).map((room) => `<section class="calendar-day-room"><div class="calendar-room-name"><strong>${escapeHtml(room.name)}</strong><span>${room.type === 'classroom' ? 'Phòng học' : 'Phòng họp'}</span></div><div class="calendar-events">${room.items.map(calendarEvent).join('')}</div></section>`).join('')}</div>`;
}

function dateLabel(date) {
  const value = new Date(`${date}T12:00:00`);
  return value.toLocaleDateString('vi-VN', { weekday: 'short', day: '2-digit', month: '2-digit' });
}

function mondayOf(date) {
  const value = new Date(`${date}T12:00:00`);
  const day = value.getDay() || 7;
  value.setDate(value.getDate() - day + 1);
  return value.toISOString().slice(0, 10);
}

function renderWeekCalendar(days, startDate) {
  const element = $('#room-schedule');
  const columns = days.map((items, index) => {
    const date = addDaysToDate(startDate, index);
    return `<section class="calendar-week-column"><div class="calendar-week-day"><strong>${dateLabel(date)}</strong><span>${items.length ? `${items.length} lịch` : 'Trống'}</span></div><div class="calendar-week-events">${items.length ? items.map(calendarEvent).join('') : '<div class="calendar-column-empty">Không có lịch</div>'}</div></section>`;
  }).join('');
  element.innerHTML = `<div class="calendar-week-caption"><strong>Tuần từ ${formatDate(startDate)} đến ${formatDate(addDaysToDate(startDate, 6))}</strong><span>Lịch chờ duyệt cũng được hiển thị để tránh đặt trùng.</span></div><div class="calendar-week-grid">${columns}</div>`;
}

async function loadRoomCalendar() {
  const selectedDate = $('#room-date').value || new Date().toISOString().slice(0, 10);
  $('#room-schedule').innerHTML = '<div class="calendar-loading">Đang tải lịch phòng...</div>';
  if (state.roomCalendarView === 'day') {
    const { data } = await api(`/api/room-schedule?date=${encodeURIComponent(selectedDate)}`);
    renderDayCalendar(data, selectedDate);
    return;
  }
  const startDate = mondayOf(selectedDate);
  const dates = Array.from({ length: 7 }, (_, index) => addDaysToDate(startDate, index));
  const responses = await Promise.all(dates.map((date) => api(`/api/room-schedule?date=${encodeURIComponent(date)}`)));
  renderWeekCalendar(responses.map((response) => response.data), startDate);
}

async function loadRoomSchedule(elementId = 'room-schedule', roomId = null, date = $('#room-date').value) {
  if (elementId === 'room-schedule' && roomId === null) {
    await loadRoomCalendar();
    return;
  }
  const query = new URLSearchParams({ date });
  const path = roomId === null ? `/api/room-schedule?${query.toString()}` : `/api/rooms/${roomId}/schedule?${query.toString()}`;
  const { data } = await api(path);
  renderRoomSchedule(data, elementId);
}

async function loadSpaces() {
  const dateInput = $('#room-date');
  if (!dateInput.value) dateInput.value = new Date().toISOString().slice(0, 10);
  await searchRooms();
  try {
    const { data } = await api('/api/room-requests?status=pending');
    renderRequests($('#pending-requests'), data);
    await loadPersonalRoomRenewals();
  } catch (error) {
    showToast(error.message);
  }
}

function setRoomCalendarView(view) {
  state.roomCalendarView = view;
  $('#calendar-day-button').classList.toggle('is-active', view === 'day');
  $('#calendar-week-button').classList.toggle('is-active', view === 'week');
  loadRoomCalendar().catch((error) => showError($('#room-schedule'), error.message));
}

async function searchRooms() {
  const start = $('#room-start').value.trim();
  const end = $('#room-end').value.trim();
  const context = $('#room-search-context');
  if (!isRoomTime(start) || !isRoomTime(end) || roomTimeMinutes(start) >= roomTimeMinutes(end)) {
    context.textContent = 'Khung giờ chưa hợp lệ. Giờ kết thúc phải sau giờ bắt đầu, trong khoảng 00:00–24:00.';
    showToast('Nhập khung giờ hợp lệ từ 00:00 đến 24:00.');
    return;
  }
  const params = new URLSearchParams({ date: $('#room-date').value, start, end });
  if ($('#room-type').value) params.set('type', $('#room-type').value);
  if ($('#room-capacity').value) params.set('capacity', $('#room-capacity').value);
  try {
    context.textContent = 'Đang kiểm tra phòng trống…';
    const { data } = await api(`/api/rooms/available?${params.toString()}`);
    renderRooms(data);
    context.textContent = `${data.length} phòng trống · Ngày ${formatDate(params.get('date'))} · ${start}–${end}${params.get('capacity') ? ` · Tối thiểu ${params.get('capacity')} người` : ''}`;
    await loadRoomSchedule();
  } catch (error) {
    context.textContent = 'Chưa tải được phòng trống. Kiểm tra lại điều kiện và bấm Kiểm tra để thử lại.';
    showError($('#available-rooms'), error.message);
    showError($('#room-schedule'), error.message);
  }
}

function openRoomRequestModal(room) {
  const date = $('#room-date').value || new Date().toISOString().slice(0, 10);
  const startTime = $('#room-start').value || '08:00';
  const endTime = $('#room-end').value || '10:00';
  const roomType = room.room_type === 'classroom' ? 'Phòng học' : 'Phòng họp';
  $('#room-request-modal-content').innerHTML = `<p class="eyebrow accent">SPACE RESERVATION</p>
    <h2 id="room-request-modal-title">Đặt ${escapeHtml(room.name)}</h2>
    <p class="modal-subtitle">${escapeHtml(room.location)} · ${roomType} · ${escapeHtml(room.capacity)} chỗ</p>
    <div class="reservation-summary"><span>${escapeHtml(room.included_equipment || 'Thiết bị cơ bản')}</span><span>${escapeHtml(room.operating_hours || 'Giờ hoạt động theo quy định')}</span></div>
    <div id="room-request-schedule" class="room-modal-schedule">Đang tải lịch phòng...</div>
    <form id="room-request-form" class="stack-form" data-room-id="${room.id}">
      <div class="reservation-fields">
        <label>Ngày sử dụng<input name="use_date" type="date" min="${new Date().toISOString().slice(0, 10)}" value="${escapeHtml(date)}" required></label>
        <label>Giờ bắt đầu<input name="start_time" class="room-time-input" type="text" inputmode="numeric" pattern="(?:[01][0-9]|2[0-3]):[0-5][0-9]|24:00" placeholder="00:00" value="${escapeHtml(startTime)}" required></label>
        <label>Giờ kết thúc<input name="end_time" class="room-time-input" type="text" inputmode="numeric" pattern="(?:[01][0-9]|2[0-3]):[0-5][0-9]|24:00" placeholder="24:00" value="${escapeHtml(endTime)}" required></label>
      </div>
      <label>Mục đích sử dụng<textarea name="purpose" rows="3" maxlength="255" required placeholder="Ví dụ: Học nhóm, thảo luận đồ án..."></textarea></label>
      <button class="primary-button" type="submit">Gửi yêu cầu đặt phòng <span>→</span></button>
    </form>`;
  $('#room-request-modal').classList.remove('is-hidden');
  $('#room-request-form').addEventListener('submit', submitRoomRequest);
  $('#room-request-form [name="use_date"]').addEventListener('change', (event) => {
    loadRoomSchedule('room-request-schedule', room.id, event.target.value).catch((error) => showError($('#room-request-schedule'), error.message));
  });
  loadRoomSchedule('room-request-schedule', room.id, date).catch((error) => showError($('#room-request-schedule'), error.message));
}

async function submitRoomRequest(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const formData = new FormData(form);
  const startTime = String(formData.get('start_time') || '').trim();
  const endTime = String(formData.get('end_time') || '').trim();
  if (!isRoomTime(startTime) || !isRoomTime(endTime) || roomTimeMinutes(startTime) >= roomTimeMinutes(endTime)) {
    showToast('Giờ sử dụng phải hợp lệ từ 00:00 đến 24:00 và giờ kết thúc phải sau giờ bắt đầu.');
    return;
  }
  const button = form.querySelector('button[type="submit"]');
  button.disabled = true;
  try {
    await api('/api/room-requests', {
      method: 'POST',
      body: JSON.stringify({
        room_id: Number(form.dataset.roomId),
        use_date: formData.get('use_date'),
        start_time: startTime,
        end_time: endTime,
        purpose: String(formData.get('purpose') || '').trim(),
      }),
    });
    closeRoomRequestModal();
    await Promise.all([loadSpaces(), loadStudentRequests()]);
    showToast('Đã gửi yêu cầu đặt phòng để thủ thư duyệt.');
  } catch (error) {
    showToast(error.message);
    button.disabled = false;
  }
}

function renderEquipment(items) {
  const canRequestEquipment = state.user?.role === 'student';
  $('#available-equipment').innerHTML = items.length ? items.map((item) => `<div class="equipment-row">${resourcePhoto(item)}<div><strong>${escapeHtml(item.name)}</strong><small>${escapeHtml(item.equipment_type)} · ${escapeHtml(item.manufacturer || 'Chưa cập nhật')} · ${escapeHtml(item.storage_location || '—')}</small></div><div class="equipment-actions"><div class="stock-meter"><strong>${escapeHtml(item.available_quantity)}</strong><small>/ ${escapeHtml(item.total_quantity)} sẵn sàng</small></div>${canRequestEquipment ? `<button class="request-link" type="button" data-add-equipment-id="${item.id}">Mượn +</button>` : ''}</div></div>`).join('') : '<div class="empty-state">Không có thiết bị đang sẵn.</div>';
  $$('[data-add-equipment-id]').forEach((button) => button.addEventListener('click', () => {
    const equipment = items.find((item) => String(item.id) === button.dataset.addEquipmentId);
    if (equipment) openEquipmentRequestModal(equipment);
  }));
}

function renderOverdueEquipment(items) {
  $('#overdue-equipment').innerHTML = items.length ? items.slice(0, 6).map((item) => `<div class="history-item"><i></i><div><strong>${escapeHtml(item.name)}</strong><small>${escapeHtml(item.student_name)} · ${escapeHtml(item.quantity)} đơn vị</small></div><span class="status-pill danger">${escapeHtml(item.overdue_days)} ngày</span></div>`).join('') : '<div class="empty-state">Không có thiết bị quá hạn.</div>';
}

async function loadEquipment() {
  try {
    const [available, overdue] = await Promise.all([api('/api/equipment/available'), api('/api/equipment/overdue')]);
    renderEquipment(available.data);
    renderOverdueEquipment(overdue.data);
  } catch (error) {
    showToast(error.message);
  }
}

function renderApprovals(items) {
  const element = $('#pending-approval-requests');
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Không có yêu cầu nào đang chờ duyệt.</div>';
    return;
  }
  element.innerHTML = items.map((item) => `<article class="approval-row"><div><span class="mini-label">${escapeHtml(item.request_label)}</span><strong>${escapeHtml(item.student_name)} <small>${escapeHtml(item.student_code)}</small></strong><p>${escapeHtml(item.items)}</p><small>Gửi lúc ${formatDate(item.requested_at)}</small></div><div class="approval-actions"><button class="approve-button" type="button" data-review-type="${item.request_type}" data-review-id="${item.id}" data-review-decision="approved">Duyệt</button><button class="reject-button" type="button" data-review-type="${item.request_type}" data-review-id="${item.id}" data-review-decision="rejected">Từ chối</button></div></article>`).join('');
  $$('[data-review-type]').forEach((button) => button.addEventListener('click', () => reviewRequest(button)));
}

function renderReviewHistory(items) {
  const element = $('#reviewed-approval-history');
  if (!items.length) {
    element.innerHTML = '<div class="empty-state">Chưa có yêu cầu nào được xử lý.</div>';
    return;
  }
  element.innerHTML = items.map((item) => {
    const approved = item.status === 'approved';
    const status = approved ? 'Đã duyệt' : 'Từ chối';
    const tone = approved ? '' : 'danger';
    return `<article class="approval-row processed-row"><div><span class="mini-label">${escapeHtml(item.request_label)}</span><strong>${escapeHtml(item.student_name)} <small>${escapeHtml(item.student_code)}</small></strong><p>${escapeHtml(item.items)}</p><small>Xử lý ${formatDateTime(item.reviewed_at)} · ${escapeHtml(item.librarian_name || 'Thủ thư')}</small>${item.review_note ? `<small>Ghi chú: ${escapeHtml(item.review_note)}</small>` : ''}${item.request_type!=='room'?`<button class="text-button" type="button" data-desk-trace="${escapeHtml(item.request_type)}:${Number(item.id)}">Truy vết yêu cầu #${Number(item.id)}</button>`:''}</div><span class="status-pill ${tone}">${status}</span></article>`;
  }).join('');
}

async function loadApprovals() {
  try {
    const [pending, history] = await Promise.all([api('/api/borrow-requests/pending'), api('/api/borrow-requests/history')]);
    renderApprovals(pending.data);
    renderReviewHistory(history.data);
  } catch (error) {
    showError($('#pending-approval-requests'), error.message);
    showError($('#reviewed-approval-history'), error.message);
  }
}

async function reviewRequest(button) {
  const { reviewType, reviewId, reviewDecision } = button.dataset;
  button.disabled = true;
  try {
    await api(`/api/borrow-requests/${encodeURIComponent(reviewType)}/${encodeURIComponent(reviewId)}/review`, {
      method: 'POST',
      body: JSON.stringify({ decision: reviewDecision }),
    });
    await Promise.all([loadApprovals(), loadDashboard()]);
    showToast(reviewDecision === 'approved' ? 'Đã duyệt yêu cầu và tạo giao dịch.' : 'Đã từ chối yêu cầu.');
  } catch (error) {
    showToast(error.message);
    button.disabled = false;
  }
}

function renderOverdueStudents(items) {
  $('#overdue-students').innerHTML = items.length ? `<table class="data-table"><thead><tr><th>Sinh viên</th><th>Sách quá hạn</th><th>Thiết bị quá hạn</th></tr></thead><tbody>${items.map((item) => `<tr><td><strong>${escapeHtml(item.full_name)}</strong><br><span class="muted">${escapeHtml(item.student_code)}</span></td><td class="danger-text">${escapeHtml(item.overdue_books)}</td><td class="danger-text">${escapeHtml(item.overdue_equipment)}</td></tr>`).join('')}</tbody></table>` : '<div class="empty-state">Không có sinh viên quá hạn.</div>';
}

async function loadReports() {
  try {
    const [books, rooms, equipment, students] = await Promise.all([api('/api/stats/books'), api('/api/stats/rooms'), api('/api/stats/equipment'), api('/api/overdue-students')]);
    renderRankList($('#report-books'), books.data, 'title', 'borrow_count');
    renderRankList($('#report-rooms'), rooms.data, 'name', 'booking_count');
    renderRankList($('#report-equipment'), equipment.data, 'name', 'borrow_count', 'đơn vị');
    renderOverdueStudents(students.data);
  } catch (error) {
    showToast(error.message);
  }
}

async function loadAdmin() {
  try {
    const { data } = await api('/api/accounts');
    $('#account-table').innerHTML = data.length ? `<table class="data-table"><thead><tr><th>Người dùng</th><th>Định danh</th><th>Vai trò</th><th>Liên hệ</th><th>Thông tin</th></tr></thead><tbody>${data.map((item) => `<tr><td><strong>${escapeHtml(item.full_name)}</strong><br><span class="muted">${escapeHtml(item.username)}</span></td><td>${escapeHtml(item.student_code || item.librarian_code || '—')}</td><td>${item.role === 'admin' ? 'Quản trị viên' : item.role === 'librarian' ? 'Thủ thư' : 'Sinh viên'}</td><td>${escapeHtml(item.email || '—')}</td><td><button class="text-button" type="button" data-account-detail="${Number(item.id)}">Xem chi tiết</button></td></tr>`).join('')}</tbody></table>` : '<div class="empty-state">Chưa có tài khoản.</div>';
  } catch (error) {
    showError($('#account-table'), error.message);
  }
}

async function openBookModal(bookId) {
  try {
    const { data: book } = await api(`/api/books/${bookId}`);
    const cover = book.cover_image ? `<img class="modal-cover" src="${escapeHtml(book.cover_image)}" alt="Bìa ${escapeHtml(book.title)}">` : '<div class="modal-cover book-cover-fallback">N</div>';
    const availableCopies = book.copies.filter((copy) => copy.status === 'available').length;
    $('#book-modal-content').innerHTML = `${cover}<p class="eyebrow accent">BOOK DETAIL / ${escapeHtml(book.language)}</p><h2 id="book-modal-title">${escapeHtml(book.title)}</h2><p class="modal-subtitle">${escapeHtml(book.publisher)} · ${escapeHtml(book.publication_year || 'Chưa rõ năm xuất bản')} · ${escapeHtml(book.pages || '—')} trang</p><p class="stock-summary">Kho sách: còn <strong>${availableCopies}</strong> / <strong>${book.copies.length}</strong> bản có thể mượn</p><p class="modal-text">${escapeHtml(book.description || book.summary || 'Chưa có mô tả.')}</p><div class="detail-block"><strong>Tác giả</strong><div class="detail-chips">${book.authors.map((item) => `<span>${escapeHtml(item.name)}</span>`).join('') || '<span>Chưa cập nhật</span>'}</div></div><div class="detail-block"><strong>Thể loại & từ khóa</strong><div class="detail-chips">${[...book.genres, ...book.keywords].map((item) => `<span>${escapeHtml(item.name)}</span>`).join('') || '<span>Chưa cập nhật</span>'}</div></div><div class="detail-block"><strong>Sách điện tử</strong><span>${book.ebook ? `${escapeHtml(book.ebook.file_format)} · ${escapeHtml(book.ebook.file_size_mb)} MB · ${escapeHtml(book.ebook.resolution || 'Responsive')}` : 'Chưa có phiên bản điện tử.'}</span></div><div class="detail-block"><strong>Bản sao</strong><span>${book.copies.map((copy) => `${escapeHtml(copy.barcode)} — ${copy.status === 'available' ? 'Có sẵn' : copy.status === 'borrowed' ? 'Đang mượn' : 'Không khả dụng'}`).join(' · ')}</span></div>`;
    if (book.ebook) {
      const readButton = document.createElement('button');
      readButton.className = 'request-link';
      readButton.type = 'button';
      readButton.textContent = 'Đọc trực tuyến';
      readButton.addEventListener('click', () => openEbookReader(book.id));
      const ebookBlock = $('#book-modal-content').querySelectorAll('.detail-block')[2];
      const ebookValue = ebookBlock?.querySelector('span');
      ebookValue?.appendChild(readButton);
    }
    const aiButton=document.createElement('button');
    aiButton.type='button';aiButton.className='book-ai-button';aiButton.textContent='Hỏi Nexus về cuốn sách này';
    aiButton.addEventListener('click',()=>openAssistantForBook(book.id));
    $('#book-modal-content').append(aiButton);
    $('#book-modal').classList.remove('is-hidden');
  } catch (error) {
    showToast(error.message);
  }
}

async function openEbookReader(bookId) {
  window.open(`/reader.php?book_id=${encodeURIComponent(bookId)}`, '_blank', 'noopener');
}

function closeBookModal() { $('#book-modal').classList.add('is-hidden'); }
function closeEbookReaderModal() { $('#ebook-reader-modal').classList.add('is-hidden'); }
function closeRoomRequestModal() { $('#room-request-modal').classList.add('is-hidden'); }
function closeResourceRequestModal() { $('#resource-request-modal').classList.add('is-hidden'); }
function closeReturnModal() { $('#return-modal').classList.add('is-hidden'); }
function closeExtensionModal() { $('#extension-modal').classList.add('is-hidden'); }
function closeProfileModal() { $('#profile-modal').classList.add('is-hidden'); }

function roleLabel(role) {
  return role === 'admin' ? 'Quản trị viên' : role === 'librarian' ? 'Thủ thư' : 'Sinh viên';
}

function renderProfile(profile) {
  const extraIdentity = profile.role === 'student'
    ? `<div class="profile-readonly"><span>Mã sinh viên</span><strong>${escapeHtml(profile.student_code || '—')}</strong></div>`
    : profile.role === 'librarian'
      ? `<div class="profile-readonly"><span>Mã thủ thư</span><strong>${escapeHtml(profile.librarian_code || '—')}</strong></div>`
      : '';
  const studentFields = profile.role === 'student' ? `<div class="profile-form-grid"><label>Khoa<input name="faculty" maxlength="120" value="${escapeHtml(profile.faculty || '')}"></label><label>Lớp<input name="class_name" maxlength="80" value="${escapeHtml(profile.class_name || '')}"></label></div>` : '';
  $('#profile-modal-content').innerHTML = `<p class="eyebrow accent">PERSONAL PROFILE</p><h2 id="profile-modal-title">Trang cá nhân</h2><p class="modal-subtitle">Xem và cập nhật thông tin tài khoản của bạn.</p><div class="profile-identity"><div class="profile-avatar">${escapeHtml((profile.full_name || 'N').split(' ').slice(-2).map((part) => part[0]).join('').toUpperCase())}</div><div><strong>${escapeHtml(profile.full_name)}</strong><span>${roleLabel(profile.role)} · ${escapeHtml(profile.username)}</span></div></div><div class="profile-readonly-grid"><div class="profile-readonly"><span>Tên đăng nhập</span><strong>${escapeHtml(profile.username)}</strong></div><div class="profile-readonly"><span>Vai trò</span><strong>${roleLabel(profile.role)}</strong></div>${extraIdentity}<div class="profile-readonly"><span>Ngày đăng ký</span><strong>${formatDateTime(profile.registered_at)}</strong></div></div><form id="profile-form" class="stack-form"><label>Họ và tên<input name="full_name" maxlength="120" value="${escapeHtml(profile.full_name || '')}" required></label><div class="profile-form-grid"><label>Ngày sinh<input name="date_of_birth" type="date" value="${escapeHtml(profile.date_of_birth || '')}"></label><label>Email<input name="email" type="email" maxlength="120" value="${escapeHtml(profile.email || '')}"></label></div><div class="profile-form-grid"><label>Số điện thoại<input name="phone" maxlength="30" value="${escapeHtml(profile.phone || '')}"></label><label>Địa chỉ<input name="address" maxlength="255" value="${escapeHtml(profile.address || '')}"></label></div>${studentFields}<button class="primary-button" type="submit">Lưu thông tin <span>→</span></button></form>`;
  $('#profile-form').addEventListener('submit', saveProfile);
}

async function openProfileModal() {
  try {
    const { data } = await api('/api/profile');
    renderProfile(data);
    $('#profile-modal').classList.remove('is-hidden');
  } catch (error) {
    showToast(error.message);
  }
}

async function saveProfile(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const formData = new FormData(form);
  const button = form.querySelector('button[type="submit"]');
  button.disabled = true;
  const payload = Object.fromEntries(formData.entries());
  try {
    const { data } = await api('/api/profile', { method: 'PUT', body: JSON.stringify(payload) });
    state.user = { ...state.user, name: data.full_name, faculty: data.faculty, class_name: data.class_name };
    setUser(state.user);
    renderProfile(data);
    showToast('Đã cập nhật thông tin cá nhân.');
  } catch (error) {
    showToast(error.message);
    button.disabled = false;
  }
}

async function boot() {
  try {
    const { user } = await api('/api/me');
    setUser(user);
    if (user) setView(location.hash.slice(1) || 'dashboard', { historyMode: 'replace' });
  } catch (error) {
    showToast(error.message);
  }
}

$('#login-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  const button = event.currentTarget.querySelector('button[type=submit]');
  button.disabled = true;
  button.setAttribute('aria-busy', 'true');
  try {
    const { user } = await api('/api/login', { method: 'POST', body: JSON.stringify({ username: form.get('username'), password: form.get('password') }) });
    setUser(user);
    setView(location.hash.slice(1) || 'dashboard', { historyMode: 'replace' });
    showToast(`Chào ${user.name}. Đăng nhập thành công.`);
  } catch (error) {
    showToast(error.message);
  } finally {
    button.disabled = false;
    button.removeAttribute('aria-busy');
  }
});

$$('[data-view]').forEach((button) => button.addEventListener('click', () => setView(button.dataset.view, { focus: true })));
$('#logout-button').addEventListener('click', async () => { await api('/api/logout', { method: 'POST' }); setUser(null); });
$('#profile-button').addEventListener('click', openProfileModal);
$('#book-search-button').addEventListener('click', loadCatalog);
$('#book-search').addEventListener('keydown', (event) => { if (event.key === 'Enter') loadCatalog(); });
$('#book-search').addEventListener('input', () => {
  window.clearTimeout(state.catalogSearchTimer);
  state.catalogSearchTimer = window.setTimeout(loadCatalog, 250);
});
$('#book-language').addEventListener('change', loadCatalog);
$('#book-year').addEventListener('change', loadCatalog);
$('#submit-book-request').addEventListener('click', submitBookRequest);
$('#submit-equipment-request').addEventListener('click', submitEquipmentRequest);
$('#student-history-button').addEventListener('click', openStudentHistory);
$('#student-history-code').addEventListener('keydown', (event) => { if (event.key === 'Enter') openStudentHistory(); });
$('#close-history').addEventListener('click', () => $('#student-history-panel').classList.add('is-hidden'));
$('#room-search-button').addEventListener('click', searchRooms);
$('#calendar-day-button').addEventListener('click', () => setRoomCalendarView('day'));
$('#calendar-week-button').addEventListener('click', () => setRoomCalendarView('week'));
$('#reload-approvals').addEventListener('click', loadApprovals);
$('#reload-returns').addEventListener('click', loadReturns);
$('#close-book-modal').addEventListener('click', closeBookModal);
$('#close-loan-receipt-modal').addEventListener('click', () => $('#loan-receipt-modal').classList.add('is-hidden'));
$('#close-ebook-reader-modal').addEventListener('click', closeEbookReaderModal);
$('#close-room-request-modal').addEventListener('click', closeRoomRequestModal);
$('#close-resource-request-modal').addEventListener('click', closeResourceRequestModal);
$('#close-return-modal').addEventListener('click', closeReturnModal);
$('#close-extension-modal').addEventListener('click', closeExtensionModal);
$('#close-profile-modal').addEventListener('click', closeProfileModal);
$('#book-modal').addEventListener('click', (event) => { if (event.target.id === 'book-modal') closeBookModal(); });
$('#loan-receipt-modal').addEventListener('click', (event) => { if (event.target.id === 'loan-receipt-modal') $('#loan-receipt-modal').classList.add('is-hidden'); });
$('#ebook-reader-modal').addEventListener('click', (event) => { if (event.target.id === 'ebook-reader-modal') closeEbookReaderModal(); });
$('#room-request-modal').addEventListener('click', (event) => { if (event.target.id === 'room-request-modal') closeRoomRequestModal(); });
$('#resource-request-modal').addEventListener('click', (event) => { if (event.target.id === 'resource-request-modal') closeResourceRequestModal(); });
$('#return-modal').addEventListener('click', (event) => { if (event.target.id === 'return-modal') closeReturnModal(); });
$('#extension-modal').addEventListener('click', (event) => { if (event.target.id === 'extension-modal') closeExtensionModal(); });
$('#profile-modal').addEventListener('click', (event) => { if (event.target.id === 'profile-modal') closeProfileModal(); });
let lastDialogTrigger = null;
function closeAllDialogs() {
  $$('.modal-backdrop').forEach((dialog) => dialog.classList.add('is-hidden'));
}
function visibleDialog() { return $$('.modal-backdrop').find((dialog) => !dialog.classList.contains('is-hidden')); }
new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    const dialog = mutation.target;
    if (!dialog.classList.contains('modal-backdrop')) continue;
    if (!dialog.classList.contains('is-hidden')) {
      lastDialogTrigger = document.activeElement;
      (dialog.querySelector('input:not([type=hidden]), select, textarea') || dialog.querySelector('button'))?.focus();
    }
  }
  if (!mutations.some((mutation) => mutation.target.classList.contains('modal-backdrop'))) return;
  const dialog = visibleDialog();
  document.body.classList.toggle('dialog-open', Boolean(dialog));
  $('#app-shell').inert = Boolean(dialog);
  if (!dialog && lastDialogTrigger?.isConnected) {
    if (lastDialogTrigger.closest('.page-view')?.classList.contains('is-visible') || lastDialogTrigger.closest('.topbar')) lastDialogTrigger.focus();
    lastDialogTrigger = null;
  }
}).observe(document.body, { subtree: true, attributes: true, attributeFilter: ['class'] });

document.addEventListener('keydown', (event) => {
  const dialog = visibleDialog();
  if (!dialog) return;
  if (event.key === 'Escape') { event.preventDefault(); closeAllDialogs(); }
  if (event.key === 'Tab') {
    const controls = [...dialog.querySelectorAll('button:not(:disabled), input:not(:disabled):not([type=hidden]), select:not(:disabled), textarea:not(:disabled), a[href], [tabindex="0"]')].filter((element) => element.getClientRects().length);
    const first = controls[0], last = controls.at(-1);
    if (!first) { event.preventDefault(); return; }
    if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
    else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
  }
});
window.addEventListener('popstate', () => setView(location.hash.slice(1) || 'dashboard', { historyMode: 'replace' }));
window.addEventListener('hashchange', () => { if (location.hash.slice(1) !== state.currentView) setView(location.hash.slice(1), { historyMode: 'replace' }); });
$('#dashboard-search').addEventListener('submit', (event) => {
  event.preventDefault();
  $('#book-search').value = $('#dashboard-book-search').value.trim();
  setView('catalog', { focus: true });
});
$('#current-date').textContent = new Intl.DateTimeFormat('vi-VN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }).format(new Date());
boot();

function resourcePhoto(resource) {
  if(!resource.image_path)return '';
  return `<figure class="resource-photo"><img src="${escapeHtml(resource.image_path)}" alt="${escapeHtml(resource.name)}${Number(resource.image_is_illustration)?' — ảnh minh họa':''}" loading="lazy">${Number(resource.image_is_illustration)?'<figcaption>Ảnh minh họa</figcaption>':''}</figure>`;
}
