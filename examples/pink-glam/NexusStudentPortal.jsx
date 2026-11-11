import React, { useEffect, useState } from 'react';
import '../../public/assets/fonts/campus-fonts.css';
import '../../public/assets/style.css';
import '../../public/assets/desktop.css';
import '../../public/assets/campus.css';
import '../../public/assets/campus-desktop.css';
import '../../public/assets/learning-kit.css';
import '../../public/assets/pink-glam.css';
import { mountGlamEffects } from '../../public/assets/pink-glam-effects.js';

const navigation = [
  ['dashboard', 'Tổng quan'], ['catalog', 'Kho sách'],
  ['assistant', 'Trợ lý học tập'], ['requests', 'Yêu cầu mượn'],
  ['circulation', 'Đang mượn & lịch sử'], ['spaces', 'Không gian'],
  ['equipment', 'Thiết bị'],
];

function Icon({ name = 'arrow' }) {
  const paths = {
    dashboard: <><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></>,
    catalog: <path d="M12 5v16M3 4c3-1 6-1 9 1 3-2 6-2 9-1v15c-3-1-6-1-9 2-3-3-6-3-9-2Z" />,
    requests: <><rect x="5" y="4" width="14" height="17" rx="2" /><path d="M9 4V2h6v2M8 10h8M8 14h8M8 18h5" /></>,
    circulation: <path d="M3 7h17l-4-4M21 17H4l4 4M20 7l-4 4M4 17l4-4" />,
    spaces: <><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M7 3v4M17 3v4M3 11h18M8 15h2M14 15h2" /></>,
    equipment: <><rect x="3" y="4" width="18" height="13" rx="2" /><path d="M8 21h8M12 17v4" /></>,
    search: <><circle cx="10.5" cy="10.5" r="6.5" /><path d="m16 16 5 5" /></>,
    arrow: <path d="M4 12h16m-6-6 6 6-6 6" />,
    logout: <path d="M9 4H4v16h5M9 12h12m-4-4 4 4-4 4" />,
  };
  return <svg className="ui-icon" viewBox="0 0 24 24" aria-hidden="true">{paths[name === 'assistant' ? 'catalog' : name]}</svg>;
}

export function Sidebar({ onNavigate, onLogout }) {
  return <aside className="sidebar">
    <div className="sidebar-brand"><div className="brand-mark small">N</div><div><strong>Nexus</strong><span>Trung tâm học liệu</span></div></div>
    <nav className="main-nav" aria-label="Điều hướng chính">
      {navigation.map(([id, label]) => <button key={id} type="button" className={`nav-item${id === 'dashboard' ? ' is-active' : ''}`} aria-current={id === 'dashboard' ? 'page' : undefined} onClick={() => onNavigate(id)}><span className="nav-icon"><Icon name={id} /></span>{label}</button>)}
    </nav>
    <div className="sidebar-footer">
      <button className="campus-help" type="button" onClick={() => onNavigate('assistant')}><strong>Cùng bạn học tốt hơn</strong><span>Hỏi từ nội dung sách và tìm trang để đối chiếu.</span><span className="campus-help-link">Mở trợ lý học tập <Icon /></span></button>
      <button className="logout-button" type="button" onClick={onLogout}><Icon name="logout" /> Đăng xuất</button>
    </div>
  </aside>;
}

export function PortalHeader({ user, date, onProfile }) {
  const initials = user.full_name.split(' ').slice(-2).map(part => part[0]).join('').toUpperCase();
  const dateLabel = new Intl.DateTimeFormat('vi-VN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric', timeZone: 'Asia/Ho_Chi_Minh' }).format(date);
  return <header className="topbar">
    <div className="breadcrumb"><span>Trung tâm tài nguyên</span><span aria-hidden="true">/</span><span>Tổng quan</span></div>
    <div className="topbar-actions"><time dateTime={date.toISOString()} id="current-date">{dateLabel.charAt(0).toUpperCase() + dateLabel.slice(1)}</time><button className="topbar-user" type="button" onClick={onProfile} aria-label="Mở trang cá nhân"><div className="avatar">{initials}</div><div><strong>{user.full_name}</strong><span>Sinh viên</span></div><span className="chevron" aria-hidden="true">⌄</span></button></div>
  </header>;
}

export function DiscoveryBanner({ onNavigate, onSearch, onCreateKit }) {
  const [query, setQuery] = useState('');
  return <div className="campus-discovery">
    <div className="campus-discovery-heading"><h2>Tìm điều bạn đang cần.</h2><Icon name="search" /></div>
    <nav className="campus-resource-tabs" aria-label="Khám phá tài nguyên"><button className="is-active" type="button" onClick={() => onNavigate('catalog')}>Sách & tài liệu</button><button type="button" onClick={() => onNavigate('spaces')}>Phòng học</button><button type="button" onClick={() => onNavigate('equipment')}>Thiết bị</button></nav>
    <form className="dashboard-search" onSubmit={event => { event.preventDefault(); onSearch(query.trim()); }}><label htmlFor="glam-book-search"><Icon name="search" /><span className="sr-only">Tìm sách theo tên</span></label><input id="glam-book-search" value={query} onChange={event => setQuery(event.target.value)} placeholder="Tên cuốn sách bạn muốn tìm…" autoComplete="off" /><button className="primary-button compact" type="submit">Tìm kiếm</button></form>
    <p className="campus-search-note">Chọn một cuốn sách. Mở thêm một góc nhìn.</p>
    <button className="kit-entry" type="button" onClick={onCreateKit}>Chưa biết chọn sách? Tạo bộ học liệu theo mục tiêu</button>
  </div>;
}

export function PopularBooks({ books, onNavigate, onOpenBook }) {
  return <article className="panel"><div className="panel-heading"><div><h2>Sách được quan tâm</h2></div><button className="text-button" type="button" onClick={() => onNavigate('catalog')}>Kho sách <Icon /></button></div><div className="rank-list">
    {books.length ? books.map(book => <button className="campus-book-row" key={book.id} type="button" onClick={() => onOpenBook(book.id)}><span className="campus-book-cover">{book.cover_url ? <img src={book.cover_url} alt="" loading="lazy" /> : <Icon name="catalog" />}</span><span className="campus-book-info"><strong>{book.title}</strong><small>{book.authors}</small><span>{book.borrow_count} lượt mượn</span></span><Icon /></button>) : <p className="empty-state">Chưa có dữ liệu lượt mượn.</p>}
  </div></article>;
}

export function PersonalStudyRail({ stats, loans, requests, onNavigate }) {
  const statItems = [['Đang mượn', stats.borrowed, 'circulation'], ['Quá hạn', stats.overdue, 'circulation'], ['Chờ duyệt', stats.pending, 'requests'], ['Lịch phòng', stats.rooms, 'spaces']];
  return <aside className="campus-personal" aria-labelledby="personal-heading">
    <h2 id="personal-heading">Góc học tập của bạn</h2>
    <div className="stats-grid">{statItems.map(([label, value, view]) => <button key={label} className="stat-card" type="button" onClick={() => onNavigate(view)}><span className="stat-top">{label}</span><strong>{value}</strong></button>)}</div>
    <article className="panel attention-panel">
      <div className="panel-heading"><div><h2>Tài nguyên đang mượn</h2><p>Sắp xếp theo hạn trả gần nhất.</p></div><button className="text-button" type="button" onClick={() => onNavigate('circulation')}>Xem tất cả <Icon /></button></div>
      <div className="attention-list">{loans.length ? loans.map(loan => <div className="personal-loan" key={`${loan.resource_type}-${loan.id}`}>
        <span className="loan-icon"><Icon name={loan.resource_type === 'book' ? 'catalog' : 'equipment'} /></span>
        <div><strong>{loan.resource_name}</strong><small>{loan.resource_type === 'book' ? 'Sách' : `Thiết bị · ${loan.quantity || 1} chiếc`} · Hạn trả {loan.due_label}</small></div>
        <span className={`status-pill${Number(loan.overdue) > 0 ? ' danger' : ''}`}>{Number(loan.overdue) > 0 ? 'Quá hạn' : 'Đang mượn'}</span>
      </div>) : <div className="empty-state"><Icon name="catalog" /><strong>Bạn chưa mượn tài nguyên nào.</strong><p>Một cuốn sách cho buổi học tiếp theo đang chờ bạn khám phá.</p><button className="text-button" type="button" onClick={() => onNavigate('catalog')}>Tìm sách để mượn <Icon /></button></div>}</div>
    </article>
    <article className="panel">
      <div className="panel-heading"><div><h2>Yêu cầu của bạn</h2><p>Các yêu cầu gần nhất và trạng thái hiện tại.</p></div><span className="panel-badge">{stats.pending} chờ duyệt</span></div>
      <div className="request-list">{requests.length ? requests.slice(0, 3).map(request => <div className="overview-request" key={request.id}>
        <div><strong>{request.title}</strong><small>{request.created_label}</small></div>
        <span className={`status-pill ${request.tone || ''}`}>{request.status_label}</span>
        <p>{request.description}</p>
      </div>) : <div className="empty-state">Chưa có yêu cầu nào. Bạn có thể bắt đầu từ kho sách.</div>}</div>
    </article>
    <button className="campus-assistant-link" type="button" onClick={() => onNavigate('assistant')}><Icon name="catalog" /><span><strong>Học cùng trợ lý Nexus</strong><small>Hỏi về sách, tìm ý tưởng và hiểu sâu kiến thức.</small></span><Icon /></button>
  </aside>;
}

function ResourceShortcuts({ onNavigate }) {
  const items = [['spaces', 'Không gian học tập', 'Xem phòng trống và lịch sử dụng'], ['equipment', 'Thiết bị & dụng cụ', 'Tra cứu thiết bị đang sẵn sàng'], ['requests', 'Yêu cầu của tôi', 'Xem giỏ mượn và trạng thái yêu cầu']];
  return <article className="resource-shortcuts"><h2>Tiếp tục công việc</h2>{items.map(([view, title, description]) => <button key={view} type="button" onClick={() => onNavigate(view)}><span className="shortcut-icon"><Icon name={view} /></span><span><strong>{title}</strong><small>{description}</small></span><Icon /></button>)}</article>;
}

/** Dashboard presentation only. Pass authenticated API data and application callbacks. */
export default function NexusStudentPortal({ user, stats, books = [], loans = [], requests = [], date = new Date(), onNavigate, onSearch, onOpenBook, onCreateKit, onProfile, onLogout }) {
  useEffect(() => {
    const previous = document.body.dataset.role;
    document.body.dataset.role = 'student';
    const cleanupEffects = mountGlamEffects();
    return () => { cleanupEffects(); if (previous === undefined) delete document.body.dataset.role; else document.body.dataset.role = previous; };
  }, []);
  const firstName = user.full_name.trim().split(' ').at(-1);
  return <><a className="skip-link" href="#main-content">Bỏ qua menu, đến nội dung</a><div className="app-shell"><Sidebar onNavigate={onNavigate} onLogout={onLogout} /><main className="main-content" id="main-content" tabIndex={-1}><PortalHeader user={user} date={date} onProfile={onProfile} /><section className="page-view is-visible" id="view-dashboard" aria-labelledby="dashboard-heading"><div className="dashboard-intro"><div><h1 id="dashboard-heading">Chào {firstName},<br /><span>hôm nay học gì?</span></h1><p>Tài nguyên, lịch mượn và không gian học tập của bạn, ở cùng một nơi.</p></div></div><div className="campus-layout"><div className="campus-main"><DiscoveryBanner onNavigate={onNavigate} onSearch={onSearch} onCreateKit={onCreateKit} /><PopularBooks books={books} onNavigate={onNavigate} onOpenBook={onOpenBook} /><ResourceShortcuts onNavigate={onNavigate} /></div><PersonalStudyRail stats={stats} loans={loans} requests={requests} onNavigate={onNavigate} /></div></section></main></div></>;
}
