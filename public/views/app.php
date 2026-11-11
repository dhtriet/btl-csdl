<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Nexus Learning Resource Center</title>
  <link rel="stylesheet" href="/assets/fonts/campus-fonts.css?v=campus-1">
  <link rel="stylesheet" href="/assets/style.css?v=resources-20261103">
  <link rel="stylesheet" href="/assets/desktop.css?v=resources-20261103">
  <link rel="stylesheet" href="/assets/assistant.css?v=study-4">
  <link rel="stylesheet" href="/assets/campus.css?v=campus-2">
  <link rel="stylesheet" href="/assets/campus-desktop.css?v=desktop-1">
  <link rel="stylesheet" href="/assets/learning-kit.css?v=kit-2">
  <link rel="stylesheet" href="/assets/resource-gallery.css?v=1">
  <link rel="stylesheet" href="/assets/pink-glam.css?v=glam-2">
  <link rel="stylesheet" href="/assets/circulation-desk.css?v=1">
</head>
<body>
  <svg class="icon-sprite" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"><defs><symbol id="icon-dashboard" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></symbol><symbol id="icon-catalog" viewBox="0 0 24 24"><path d="M12 5v16M3 4c3-1 6-1 9 1 3-2 6-2 9-1v15c-3-1-6-1-9 2-3-3-6-3-9-2Z"/></symbol><symbol id="icon-requests" viewBox="0 0 24 24"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4V2h6v2M8 10h8M8 14h8M8 18h5"/></symbol><symbol id="icon-circulation" viewBox="0 0 24 24"><path d="M3 7h17l-4-4M21 17H4l4 4M20 7l-4 4M4 17l4-4"/></symbol><symbol id="icon-spaces" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 11h18M8 15h2M14 15h2"/></symbol><symbol id="icon-equipment" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="13" rx="2"/><path d="M8 21h8M12 17v4"/></symbol><symbol id="icon-approvals" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/></symbol><symbol id="icon-reports" viewBox="0 0 24 24"><path d="M4 3v18h17M9 16v-5M14 16V7M19 16v-8"/></symbol><symbol id="icon-admin" viewBox="0 0 24 24"><circle cx="9" cy="8" r="3"/><path d="M3 21v-3a6 6 0 0 1 12 0v3M16 5a3 3 0 0 1 0 6M18 15a5 5 0 0 1 3 5"/></symbol><symbol id="icon-search" viewBox="0 0 24 24"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></symbol><symbol id="icon-arrow" viewBox="0 0 24 24"><path d="M4 12h16m-6-6 6 6-6 6"/></symbol><symbol id="icon-logout" viewBox="0 0 24 24"><path d="M9 4H4v16h5M9 12h12m-4-4 4 4-4 4"/></symbol></defs></svg>
  <a class="skip-link" href="#main-content">Bỏ qua menu, đến nội dung</a>
  <div class="ambient ambient-one"></div>
  <div class="ambient ambient-two"></div>

  <div id="toast" class="toast" role="status" aria-live="polite"></div>

  <section id="login-screen" class="login-screen">
    <div class="login-story">
      <div class="login-wordmark"><span class="brand-mark">N</span><strong>Nexus<span>Trung tâm tài nguyên học tập</span></strong></div>
      <div class="login-story-content"><h2>Một nơi cho <br>mọi điều bạn <br>muốn học.</h2><p>Tìm giáo trình, đặt không gian học nhóm và mượn thiết bị. Kết nối tài nguyên với hành trình học tập của bạn.</p>
      <div class="login-resources"><span><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-catalog"/></svg> Kho sách</span><span><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-spaces"/></svg> Phòng học</span><span><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-equipment"/></svg> Thiết bị</span></div></div>
      <span class="login-story-footer">Nexus Learning Resource Center</span>
    </div>
    <div class="login-orbit orbit-left"></div>
    <div class="login-orbit orbit-right"></div>
    <div class="login-card">
      <h1>Đăng nhập hệ thống</h1>
      <p class="login-copy">Đăng nhập để quản lý sách, không gian học tập và thiết bị dùng chung.</p>
      <form id="login-form" class="stack-form">
        <label>
          Tên đăng nhập
          <input name="username" required autocomplete="username" placeholder="Nhập tên đăng nhập">
        </label>
        <label>
          Mật khẩu
          <input name="password" type="password" required autocomplete="current-password" placeholder="••••••••">
        </label>
        <button class="primary-button" type="submit">Đăng nhập <span>→</span></button>
      </form>
    </div>
    <div class="login-note">
      <span class="status-dot"></span>
      <span>Trung tâm tài nguyên học tập</span>
    </div>
  </section>

  <div id="app-shell" class="app-shell is-hidden">
    <aside id="main-sidebar" class="sidebar">
      <div class="sidebar-brand">
        <div class="brand-mark small">N</div>
        <div>
          <strong>Nexus</strong>
          <span>Trung tâm học liệu</span>
        </div>
      </div>

      <nav class="main-nav" aria-label="Điều hướng chính">
        <button class="nav-item is-active" data-view="dashboard"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-dashboard"/></svg></span> Tổng quan</button>
        <button class="nav-item" data-view="catalog"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-catalog"/></svg></span> Kho sách</button>
        <button class="nav-item" data-view="assistant"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true"><use href="#icon-catalog"/></svg></span> Trợ lý học tập</button>
        <button id="student-requests-nav" class="nav-item is-hidden" data-view="requests"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-requests"/></svg></span> Yêu cầu mượn</button>
        <button class="nav-item" data-view="circulation"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-circulation"/></svg></span> Mượn & trả</button>
        <button class="nav-item" data-view="spaces"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-spaces"/></svg></span> Không gian</button>
        <button class="nav-item" data-view="equipment"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-equipment"/></svg></span> Thiết bị</button>
        <button id="librarian-approvals-nav" class="nav-item is-hidden" data-view="approvals"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-approvals"/></svg></span> Duyệt yêu cầu</button>
        <button class="nav-item is-hidden" data-view="manage"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true"><use href="#icon-catalog"/></svg></span> Quản lý tài nguyên</button>
        <button class="nav-item" data-view="reports"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-reports"/></svg></span> Báo cáo</button>
        <button id="admin-nav" class="nav-item is-hidden" data-view="admin"><span class="nav-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-admin"/></svg></span> Quản trị</button>
      </nav>

      <div class="sidebar-footer">
        <button class="campus-help" data-view="assistant" type="button"><strong>Cùng bạn học tốt hơn</strong><span>Hỏi từ nội dung sách và tìm trang để đối chiếu.</span><span class="campus-help-link">Mở trợ lý học tập <svg class="ui-icon" aria-hidden="true"><use href="#icon-arrow"/></svg></span></button>
        <button id="logout-button" class="logout-button"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-logout"/></svg> Đăng xuất</button>
      </div>
    </aside>

    <main id="main-content" class="main-content" tabindex="-1">
      <header class="topbar">
        <button id="campus-menu" class="campus-menu" type="button" aria-expanded="false" aria-controls="main-sidebar" aria-label="Mở menu điều hướng"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></svg></button>
        <div class="breadcrumb"><span>Trung tâm tài nguyên</span><span aria-hidden="true">/</span><span id="page-title">Tổng quan</span></div>
        <div class="topbar-actions"><time id="current-date"></time><button id="profile-button" class="topbar-user" type="button" aria-label="Mở trang cá nhân">
          <div class="avatar" id="user-avatar">N</div><div><strong id="user-name">Người dùng</strong><span id="user-role">Sinh viên</span></div><span class="chevron" aria-hidden="true">⌄</span>
        </button></div>
      </header>

      <section id="view-dashboard" class="page-view is-visible" aria-labelledby="dashboard-heading">
        <div class="dashboard-intro"><div><h1 id="dashboard-heading">Không gian học tập của bạn</h1><p id="dashboard-description">Tìm tài nguyên và theo dõi hoạt động của bạn tại Nexus.</p></div><button id="dashboard-primary" class="primary-button" data-view="catalog">Tìm sách <svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-arrow"/></svg></button></div>
        <div id="campus-discovery" class="campus-discovery"><div class="campus-discovery-heading"><h2>Tìm điều bạn đang cần.</h2><svg class="ui-icon" aria-hidden="true"><use href="#icon-search"/></svg></div><nav class="campus-resource-tabs" aria-label="Khám phá tài nguyên"><button type="button" class="is-active" data-view="catalog">Sách & tài liệu</button><button type="button" data-view="spaces">Phòng học</button><button type="button" data-view="equipment">Thiết bị</button></nav><form id="dashboard-search" class="dashboard-search"><label for="dashboard-book-search"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-search"/></svg><span class="sr-only">Tìm sách theo tên</span></label><input id="dashboard-book-search" placeholder="Tên cuốn sách bạn muốn tìm…" autocomplete="off"><button class="primary-button compact" type="submit">Tìm kiếm</button></form><p class="campus-search-note">Chọn một cuốn sách. Mở thêm một góc nhìn.</p></div>
        <div id="dashboard-stats" class="stats-grid" aria-live="polite"></div>
        <div class="dashboard-grid overview-grid">
          <article class="panel attention-panel"><div class="panel-heading"><div><h2 id="dashboard-attention-title">Cần chú ý</h2><p id="dashboard-attention-description">Những việc cần ưu tiên hôm nay.</p></div><button id="dashboard-attention-link" class="text-button" data-view="circulation">Xem tất cả <svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-arrow"/></svg></button></div><div id="dashboard-attention" class="attention-list"></div></article>
          <article class="panel"><div class="panel-heading"><div><h2 id="dashboard-requests-title">Yêu cầu gần đây</h2><p id="dashboard-requests-description">Theo dõi trạng thái xử lý tài nguyên.</p></div><span class="panel-badge" id="pending-count">0</span></div><div id="dashboard-requests" class="request-list"></div></article>
        </div>
        <div class="dashboard-grid secondary-grid">
          <article class="panel"><div class="panel-heading"><div><h2>Sách được quan tâm</h2><p>Những đầu sách được mượn nhiều tại trung tâm.</p></div><button class="text-button" data-view="catalog">Kho sách <svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-arrow"/></svg></button></div><div id="dashboard-top-books" class="rank-list"></div></article>
          <article class="resource-shortcuts"><h2>Tiếp tục công việc</h2><button data-view="spaces"><span class="shortcut-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-spaces"/></svg></span><span><strong>Không gian học tập</strong><small>Xem phòng trống và lịch sử dụng</small></span><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-arrow"/></svg></button><button data-view="equipment"><span class="shortcut-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-equipment"/></svg></span><span><strong>Thiết bị & dụng cụ</strong><small>Tra cứu thiết bị đang sẵn sàng</small></span><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-arrow"/></svg></button><button id="dashboard-workspace-link" data-view="requests"><span class="shortcut-icon"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-requests"/></svg></span><span><strong id="workspace-link-title">Yêu cầu của tôi</strong><small id="workspace-link-description">Xem giỏ mượn và trạng thái yêu cầu</small></span><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-arrow"/></svg></button></article>
        </div>
      </section>

      <section id="view-catalog" class="page-view">
        <div class="section-intro">
          <div><h1>Kho sách</h1><p>Nhập một phần tên sách để tìm nhanh, sau đó có thể lọc theo ngôn ngữ hoặc năm xuất bản.</p></div>
          <div class="result-count" id="book-count">0 đầu sách</div>
        </div>
        <div class="filter-bar">
          <label class="search-field"><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><use href="#icon-search"/></svg><input id="book-search" aria-label="Tìm tên sách" placeholder="Nhập tên sách..." autocomplete="off"></label>
          <select id="book-language" aria-label="Ngôn ngữ"><option value="">Mọi ngôn ngữ</option><option value="Tiếng Việt">Tiếng Việt</option><option value="English">Tiếng Anh</option></select>
          <input id="book-year" aria-label="Năm xuất bản" type="number" min="1900" max="2100" placeholder="Năm">
          <button id="book-search-button" class="primary-button compact">Tìm kiếm</button>
        </div>
        <div id="book-grid" class="book-grid"></div>
        <nav id="catalog-pagination" class="catalog-pagination" aria-label="Phân trang kho sách" tabindex="-1"></nav>
      </section>

      <section id="view-requests" class="page-view">
        <div class="section-intro"><div><h1>Yêu cầu mượn</h1><p>Thêm sách hoặc thiết bị từ các mục tương ứng, chọn hạn trả cho từng mục rồi gửi thủ thư duyệt.</p></div></div>
        <div class="request-workspace">
          <article class="panel">
            <div class="panel-heading"><div><h2>Sách muốn mượn</h2></div><span id="book-request-count" class="panel-badge">0 cuốn</span></div>
            <div id="book-request-cart" class="request-cart"></div>
            <label class="request-note">Ghi chú cho thủ thư<textarea id="book-request-note" rows="2" maxlength="255" placeholder="Ví dụ: Phục vụ đồ án môn học"></textarea></label>
            <button id="submit-book-request" class="primary-button request-submit" type="button">Gửi yêu cầu mượn sách <span>→</span></button>
          </article>
          <article class="panel">
            <div class="panel-heading"><div><h2>Thiết bị muốn mượn</h2></div><span id="equipment-request-count" class="panel-badge">0 mục</span></div>
            <div id="equipment-request-cart" class="request-cart"></div>
            <label class="request-note">Ghi chú cho thủ thư<textarea id="equipment-request-note" rows="2" maxlength="255" placeholder="Ví dụ: Dùng cho buổi thuyết trình"></textarea></label>
            <button id="submit-equipment-request" class="primary-button request-submit" type="button">Gửi yêu cầu mượn thiết bị <span>→</span></button>
          </article>
        </div>
        <article class="panel my-requests-panel"><div class="panel-heading"><div><h2>Yêu cầu của tôi</h2></div></div><div id="my-borrow-requests" class="request-list"></div></article>
      </section>

      <section id="view-circulation" class="page-view">
        <div class="section-intro">
          <div><h1 id="circulation-heading">Mượn và trả</h1><p>Mỗi cuốn trong một phiếu có hạn trả và lịch sử riêng.</p></div>
          <div class="lookup-box"><label for="student-history-code">Mã sinh viên</label><div><input id="student-history-code" placeholder="SV001"><button id="student-history-button" class="primary-button compact">Tra cứu</button></div></div>
        </div>
        <details id="counter-desk" class="panel desk-disclosure is-hidden"><summary><strong>Lập phiếu mượn tại quầy</strong><span>Thủ thư chọn sinh viên và giao sách hoặc thiết bị trực tiếp.</span></summary><form id="counter-loan-form" class="stack-form desk-form"><div class="desk-fields"><label>Sinh viên<select id="counter-reader" name="student_code" required><option value="">Chọn sinh viên</option></select></label><label>Loại tài nguyên<select id="counter-type" name="type"><option value="book">Sách</option><option value="equipment">Thiết bị</option></select></label></div><div id="counter-items"></div><button id="counter-add" class="text-button" type="button">Thêm tài nguyên +</button><label>Ghi chú giao tài nguyên<textarea name="note" maxlength="255" rows="2"></textarea></label><p class="muted">Xác nhận sẽ tạo yêu cầu tại quầy, phiếu mượn và cập nhật tồn kho trong cùng một giao dịch. Bạn có thể lập một phiếu gồm nhiều tài nguyên cùng loại.</p><div id="counter-result" role="status" aria-live="polite"></div><button class="primary-button" type="submit">Lập phiếu & giao tài nguyên</button></form></details>
        <article class="panel trace-panel"><div class="panel-heading"><div><h2>Truy vết yêu cầu và phiếu mượn</h2><p>Xem phiếu được tạo từ yêu cầu và từng tài nguyên đã giao.</p></div></div><form id="request-trace-form" class="desk-fields"><label>Loại yêu cầu<select name="type"><option value="book">Mượn sách</option><option value="equipment">Mượn thiết bị</option></select></label><label>Mã yêu cầu<input name="request_id" type="number" min="1" step="1" required placeholder="Ví dụ: 9"></label><button class="primary-button compact" type="submit">Truy vết</button></form><div id="request-trace-result" aria-live="polite"></div></article>
        <div class="dashboard-grid circulation-grid">
          <article class="panel panel-wide"><div class="panel-heading"><div><h2>Sách cần xử lý</h2></div><span class="panel-badge danger">Ưu tiên quá hạn lâu</span></div><div id="overdue-books-table" class="table-wrap"></div></article>
          <article class="panel"><div class="panel-heading"><div><h2>Lịch sử gần đây</h2></div></div><div id="returned-books-list" class="compact-list"></div></article>
        </div>
        <article class="panel"><div class="panel-heading"><div><h2>Yêu cầu gia hạn sách</h2><p>Sinh viên gửi yêu cầu. Thủ thư duyệt hoặc từ chối; hạn trả chỉ thay đổi khi được duyệt.</p></div><button id="reload-extension-requests" class="text-button" type="button">Tải lại yêu cầu</button></div><div id="extension-requests-list" class="table-wrap" aria-live="polite"></div></article>
        <article id="librarian-return-desk" class="panel librarian-return-desk is-hidden"><div class="panel-heading"><div><h2>Ghi nhận trả tài nguyên</h2></div><button id="reload-returns" class="text-button" type="button">Tải lại <span>↻</span></button></div><div class="return-desk-grid"><div><h5>Sách đang mượn</h5><div id="active-book-returns" class="table-wrap"></div></div><div><h5>Thiết bị đang mượn</h5><div id="active-equipment-returns" class="table-wrap"></div></div><div class="return-history-block"><h5>Lịch sử trả sách</h5><div id="returned-book-list" class="compact-list"></div></div><div class="return-history-block"><h5>Lịch sử trả thiết bị</h5><div id="returned-equipment-list" class="compact-list"></div></div><div class="room-history-block"><h5>Lịch sử đặt phòng</h5><div id="room-usage-history" class="table-wrap"></div></div></div></article>
        <article id="student-history-panel" class="panel history-panel is-hidden"><div class="panel-heading"><div><h4 id="history-title">Lịch sử sinh viên</h2></div><button id="close-history" class="icon-button" aria-label="Đóng">×</button></div><div id="student-history-content"></div></article>
      </section>

      <section id="view-approvals" class="page-view">
        <div class="section-intro"><div><h1>Duyệt yêu cầu</h1><p>Khi duyệt, hệ thống tạo phiếu mượn thực tế, gán bản sao sách hoặc trừ số lượng thiết bị còn sẵn.</p></div></div>
        <article class="panel"><div class="panel-heading"><div><h2>Yêu cầu đang chờ duyệt</h2></div><button id="reload-approvals" class="text-button" type="button">Tải lại <span>↻</span></button></div><div id="pending-approval-requests" class="approval-list"></div></article>
        <article class="panel review-history-panel"><div class="panel-heading"><div><h2>Các yêu cầu đã xử lý</h2></div><span class="panel-badge">Đã duyệt / Từ chối</span></div><div id="reviewed-approval-history" class="approval-list"></div></article>
      </section>

      <section id="view-spaces" class="page-view">
        <div class="section-intro"><div><h1>Đặt phòng học và phòng họp</h1><p>Kiểm tra phòng trống, sau đó sinh viên có thể gửi yêu cầu đặt phòng trong chính khung giờ đã chọn.</p></div></div>
        <div class="filter-bar room-filters"><label class="sr-only desktop-room-label" for="room-date">Ngày sử dụng</label><input id="room-date" aria-label="Ngày sử dụng" type="date"><label class="sr-only desktop-room-label" for="room-start">Từ giờ</label><input id="room-start" aria-label="Giờ bắt đầu" class="room-time-input" type="text" inputmode="numeric" pattern="(?:[01][0-9]|2[0-3]):[0-5][0-9]|24:00" placeholder="Giờ bắt đầu (00:00)" value="08:00"><label class="sr-only desktop-room-label" for="room-end">Đến giờ</label><input id="room-end" aria-label="Giờ kết thúc" class="room-time-input" type="text" inputmode="numeric" pattern="(?:[01][0-9]|2[0-3]):[0-5][0-9]|24:00" placeholder="Giờ kết thúc (24:00)" value="10:00"><label class="sr-only desktop-room-label" for="room-type">Loại phòng</label><select id="room-type" aria-label="Loại phòng"><option value="">Mọi loại phòng</option><option value="classroom">Phòng học</option><option value="meeting_room">Phòng họp</option></select><label class="sr-only desktop-room-label" for="room-capacity">Sức chứa tối thiểu</label><input id="room-capacity" aria-label="Sức chứa tối thiểu" type="number" min="1" placeholder="Số người"><button id="room-search-button" class="primary-button compact">Kiểm tra</button></div>
        <p id="room-search-context" class="sr-only desktop-room-context" role="status" aria-live="polite" aria-atomic="true"></p>
        <div class="dashboard-grid spaces-grid"><article class="panel panel-wide"><div class="panel-heading"><div><h2>Phòng còn trống</h2></div><span class="panel-badge" id="room-result-count">0 phòng</span></div><div id="available-rooms" class="room-grid"></div></article><article class="panel"><div class="panel-heading"><div><h2>Chờ duyệt</h2></div></div><div id="pending-requests" class="request-list"></div></article></div>
        <article class="panel room-schedule-panel"><div class="panel-heading"><div><h2>Lịch phòng trực quan</h2></div><div class="calendar-toolbar"><button id="calendar-day-button" class="calendar-view-button is-active" type="button">Ngày</button><button id="calendar-week-button" class="calendar-view-button" type="button">Tuần</button></div></div><div class="calendar-legend"><span><i class="calendar-dot booked"></i>Đã đặt</span><span><i class="calendar-dot pending"></i>Chờ duyệt</span><span><i class="calendar-dot completed"></i>Đã kết thúc</span></div><div id="room-schedule" class="room-calendar"></div></article>
      </section>

      <section id="view-equipment" class="page-view">
        <div class="section-intro"><div><h1>Thiết bị và dụng cụ</h1><p>Kiểm tra số lượng khả dụng và những khoản mượn cần trả.</p></div></div>
        <div class="dashboard-grid equipment-grid"><article class="panel panel-wide"><div class="panel-heading"><div><h2>Thiết bị đang sẵn sàng</h2></div></div><div id="available-equipment" class="equipment-list"></div></article><article class="panel"><div class="panel-heading"><div><h2>Thiết bị quá hạn</h2></div></div><div id="overdue-equipment" class="compact-list"></div></article></div>
      </section>

      <section id="view-reports" class="page-view">
        <div class="section-intro"><div><h1>Báo cáo thống kê</h1><p>Thống kê hoạt động mượn sách, đặt phòng và mượn thiết bị.</p></div></div>
        <div class="report-columns"><article class="panel"><div class="panel-heading"><div><h2>Sách được mượn nhiều nhất</h2></div></div><div id="report-books" class="rank-list"></div></article><article class="panel"><div class="panel-heading"><div><h2>Phòng được đặt nhiều nhất</h2></div></div><div id="report-rooms" class="rank-list"></div></article><article class="panel"><div class="panel-heading"><div><h2>Thiết bị được mượn nhiều nhất</h2></div></div><div id="report-equipment" class="rank-list"></div></article></div>
        <article class="panel overdue-students-panel"><div class="panel-heading"><div><h2>Sinh viên có tài nguyên quá hạn</h2></div></div><div id="overdue-students" class="table-wrap"></div></article>
      </section>

      <section id="view-assistant" class="page-view" aria-labelledby="study-heading">
        <div class="section-intro study-intro"><div><h1 id="study-heading">Trợ lý học tập</h1><p>Đọc có định hướng. Hiểu sâu kiến thức. Tìm nguồn ngay trong sách.</p></div><span class="study-service" id="study-service-status">Nexus</span></div>
        <details id="learning-kit" class="learning-kit">
          <summary><span><strong>Bộ học liệu theo mục tiêu</strong><span>Một mục tiêu cụ thể. Những cuốn sách phù hợp. Một kế hoạch để bắt đầu.</span></span><svg class="ui-icon" aria-hidden="true" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></summary>
          <div class="kit-content">
            <form id="kit-form" class="kit-form">
              <label for="kit-goal">Bạn muốn làm được điều gì?<textarea id="kit-goal" rows="3" minlength="10" maxlength="600" required placeholder="Ví dụ: Tôi cần làm đồ án cơ sở dữ liệu trong 3 tuần, đã biết SQL cơ bản."></textarea></label>
              <div class="kit-examples"><span>Thử một mục tiêu:</span><button type="button" data-kit-example="Tôi muốn làm đồ án cơ sở dữ liệu: thiết kế bảng, viết SQL và kiểm tra dữ liệu.">Đồ án cơ sở dữ liệu</button><button type="button" data-kit-example="Tôi muốn ôn giải thuật để chuẩn bị phỏng vấn lập trình, có bài tập thực hành.">Ôn giải thuật</button></div>
              <div class="kit-fields"><label for="kit-weeks">Thời gian học (tuần)<input id="kit-weeks" type="number" min="1" max="12" value="3" required></label><label for="kit-minutes">Phút mỗi ngày<input id="kit-minutes" type="number" min="15" max="180" value="45" required></label><label for="kit-level">Trình độ hiện tại<select id="kit-level"><option value="beginner">Mới bắt đầu</option><option value="intermediate">Đã có nền tảng</option><option value="advanced">Muốn học chuyên sâu</option></select></label></div>
              <div class="kit-form-footer"><p>Chọn tối đa 3 sách từ kho. Kế hoạch là gợi ý học tập; phần đọc có nguồn sẽ dẫn tới trang PDF để đối chiếu.</p><button id="kit-create" class="primary-button" type="submit">Tạo bộ học liệu <svg class="ui-icon" aria-hidden="true"><use href="#icon-arrow"/></svg></button></div>
            </form>
            <p id="kit-status" class="kit-status" role="status" aria-live="polite"></p>
            <div id="kit-error" class="error-state is-hidden" role="alert" tabindex="-1"></div>
            <div id="kit-results" class="kit-results" aria-live="polite"></div>
          </div>
        </details>
        <div class="study-workspace">
          <div class="study-chat">
            <div class="study-chat-header"><div class="study-chat-identity"><span class="study-avatar"><svg class="ui-icon" aria-hidden="true"><use href="#icon-catalog"/></svg></span><div><strong>Nexus</strong><small>Cùng bạn khám phá học liệu</small></div></div><button id="study-new" type="button">Cuộc trò chuyện mới</button></div>
            <div id="study-modes" class="study-modes" role="group" aria-label="Mục tiêu học tập"><button data-study-mode="ask" class="is-active" aria-pressed="true">Hỏi kiến thức</button><button data-study-mode="summary" aria-pressed="false">Tóm tắt sách</button><button data-study-mode="roadmap" aria-pressed="false">Lộ trình học</button><button data-study-mode="outcomes" aria-pressed="false">Học được gì</button></div>
            <div class="study-body" id="study-scroll"><div id="study-welcome" class="study-welcome"><div class="study-welcome-mark"><svg class="ui-icon" aria-hidden="true"><use href="#icon-catalog"/></svg></div><h2>Bạn muốn hiểu điều gì hôm nay?</h2><p>Chọn sách bên phải hoặc hỏi từ toàn bộ kho. Nexus sẽ tìm các đoạn liên quan và giúp bạn học từng bước, kèm trang sách để đối chiếu.</p><div id="study-suggestions" class="study-suggestions"></div></div><div id="study-messages" class="study-messages" role="log" aria-live="polite" aria-relevant="additions" aria-label="Hội thoại học tập"></div></div>
            <form id="study-form" class="study-composer"><div class="study-current-scope"><svg class="ui-icon" aria-hidden="true"><use href="#icon-catalog"/></svg><span id="study-scope">Tra cứu toàn bộ kho sách</span></div><div id="study-error" class="error-state is-hidden" role="alert"></div><div class="study-input-wrap"><label class="sr-only" for="study-input">Câu hỏi dành cho trợ lý học tập</label><textarea id="study-input" rows="2" maxlength="2000" placeholder="Ví dụ: Tôi nên học cơ sở dữ liệu theo lộ trình nào?"></textarea><button id="study-send" class="primary-button" type="submit">Gửi <svg class="ui-icon" aria-hidden="true"><use href="#icon-arrow"/></svg></button></div><div class="study-composer-footer"><span>Enter để gửi · Shift + Enter để xuống dòng</span><span id="study-character-count">0/2000</span></div></form>
          </div>
          <aside class="study-context" aria-label="Nguồn sách và lịch sử hội thoại"><div class="study-context-panel"><h2>Nguồn học liệu</h2><p id="study-source-count">Đang đọc danh mục sách…</p><label class="sr-only" for="study-book-search">Tìm sách để hỏi</label><input id="study-book-search" placeholder="Tìm sách trong kho…" autocomplete="off"><div class="study-book-toolbar"><span id="study-selection-count">0/3 sách</span><button id="study-clear-books" type="button">Tra toàn kho</button></div><div id="study-books" class="study-books"></div><button id="study-reindex" class="is-hidden" type="button">Cập nhật nguồn sách</button></div><div class="study-context-panel"><h2>Trò chuyện gần đây</h2><p>Chỉ tài khoản của bạn xem được lịch sử này.</p><div id="study-threads" class="study-threads"></div></div></aside>
        </div>
      </section>

      <section id="view-manage" class="page-view" aria-labelledby="management-heading">
        <div class="section-intro"><div><h1 id="management-heading">Quản lý tài nguyên</h1><p>Quản lý thông tin, hình ảnh và hiển thị của tài nguyên.</p></div><button id="management-add" class="primary-button" type="button">Thêm đầu sách</button></div>
        <div id="management-tabs" class="management-tabs" role="group" aria-label="Loại tài nguyên"><button data-resource-type="books" class="is-active" aria-pressed="true">Đầu sách</button><button data-resource-type="copies" aria-pressed="false">Bản sách</button><button data-resource-type="rooms" aria-pressed="false">Phòng học</button><button data-resource-type="equipment" aria-pressed="false">Thiết bị</button></div>
        <p class="management-help">Đầu sách lưu tên, tác giả và ảnh bìa. Bản sách là từng cuốn có mã vạch để mượn trả: một đầu sách có thể có nhiều bản sách.</p><article class="panel"><div class="management-toolbar"><form id="management-search-form"><label class="sr-only" for="management-search">Tìm tên hoặc mã vạch</label><input id="management-search" placeholder="Tìm tên hoặc mã vạch…" autocomplete="off"><button class="primary-button compact" type="submit">Tìm kiếm</button></form><div><label for="management-visibility">Hiển thị </label><select id="management-visibility"><option value="all">Tất cả</option><option value="1">Hiện</option><option value="0">Đã ẩn</option></select><span id="management-count"></span><button id="management-reload" class="text-button" type="button">Tải lại</button></div></div><div id="management-table" class="table-wrap"></div><nav id="management-pagination" class="catalog-pagination" aria-label="Phân trang quản lý tài nguyên"></nav></article>
      </section>

      <section id="view-admin" class="page-view">
        <div class="section-intro"><div><h1>Quản lý tài khoản</h1><p>Danh sách tài khoản và thông tin liên hệ cơ bản.</p></div></div>
        <article class="panel"><div class="panel-heading"><div><h2>Danh sách tài khoản</h2></div><span class="panel-badge">Thông tin tài khoản</span></div><div id="account-table" class="table-wrap"></div></article>
        <article id="account-full-panel" class="panel is-hidden" aria-labelledby="account-full-heading"><div class="panel-heading"><h2 id="account-full-heading" tabindex="-1">Chi tiết tài khoản</h2><button id="account-full-close" class="text-button" type="button">Đóng chi tiết</button></div><div id="account-full-content"></div></article>
      </section>
    </main>
  </div>

  <div id="book-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="book-modal-title">
    <div class="modal-card"><button id="close-book-modal" class="modal-close" aria-label="Đóng">×</button><div id="book-modal-content"></div></div>
  </div>

  <div id="loan-receipt-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="loan-receipt-modal-title">
    <div class="modal-card loan-receipt-modal-card"><button id="close-loan-receipt-modal" class="modal-close" aria-label="Đóng">×</button><div id="loan-receipt-modal-content"></div></div>
  </div>

  <div id="ebook-reader-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="ebook-reader-title">
    <div class="modal-card ebook-reader-card"><button id="close-ebook-reader-modal" class="modal-close" aria-label="Đóng">×</button><div id="ebook-reader-content"></div></div>
  </div>

  <div id="room-request-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="room-request-modal-title">
    <div class="modal-card room-request-modal-card"><button id="close-room-request-modal" class="modal-close" aria-label="Đóng">×</button><div id="room-request-modal-content"></div></div>
  </div>

  <div id="resource-request-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="resource-request-modal-title">
    <div class="modal-card resource-request-modal-card"><button id="close-resource-request-modal" class="modal-close" aria-label="Đóng">×</button><div id="resource-request-modal-content"></div></div>
  </div>

  <div id="return-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="return-modal-title">
    <div class="modal-card return-modal-card"><button id="close-return-modal" class="modal-close" aria-label="Đóng">×</button><div id="return-modal-content"></div></div>
  </div>

  <div id="extension-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="extension-modal-title">
    <div class="modal-card extension-modal-card"><button id="close-extension-modal" class="modal-close" aria-label="Đóng">×</button><div id="extension-modal-content"></div></div>
  </div>

  <div id="profile-modal" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="profile-modal-title">
    <div class="modal-card profile-modal-card"><button id="close-profile-modal" class="modal-close" aria-label="Đóng">×</button><div id="profile-modal-content"></div></div>
  </div>

  <div id="resource-editor" class="modal-backdrop is-hidden" role="dialog" aria-modal="true" aria-labelledby="resource-editor-title">
    <div class="modal-card resource-editor-card"><button id="close-resource-editor" class="modal-close" type="button" aria-label="Đóng biểu mẫu">×</button><h2 id="resource-editor-title">Thêm tài nguyên</h2><p id="resource-editor-hint" class="modal-subtitle"></p><form id="resource-editor-form"><div id="resource-editor-fields" class="resource-editor-fields"></div><div id="resource-editor-error" class="error-state is-hidden" role="alert" tabindex="-1"></div><div class="editor-actions"><button id="resource-editor-cancel" class="editor-cancel" type="button">Hủy</button><button id="resource-editor-save" class="primary-button" type="submit">Lưu tài nguyên</button></div></form></div>
  </div>
  <script src="/assets/assistant.js?v=study-kit-1"></script>
  <script src="/assets/learning-kit.js?v=kit-3"></script>
  <script src="/assets/manage.js?v=librarian-delete-1"></script>
  <script src="/assets/app.js?v=extension-requests-1"></script>
  <script src="/assets/circulation-desk.js?v=no-inventory-2"></script>
  <script type="module" src="/assets/pink-glam-init.js?v=glam-2"></script>
</body>
</html>
