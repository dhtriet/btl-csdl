const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

// Exercise the shipped asynchronous renderers with deliberately reversed responses.
const nodes = new Map();
function node(selector) {
  if (!nodes.has(selector)) nodes.set(selector, {
    innerHTML: '', textContent: '', value: '', open: false,
    classList: { add() {}, remove() {}, toggle() {} },
    addEventListener() {}, scrollIntoView() {}, focus() {},
  });
  return nodes.get(selector);
}
const pending = [];
const context = vm.createContext({
  state: { user: { id: 1, role: 'admin' } },
  $: node, $$: () => [],
  document: { addEventListener() {} },
  api: url => new Promise((resolve, reject) => pending.push({ url, resolve, reject })),
  escapeHtml: value => String(value ?? ''),
  formatDateTime: value => value, formatDate: value => value,
  roleLabel: value => value, requestStatus: value => value,
  showError: (target, message) => { target.innerHTML = `ERROR:${message}`; },
});
vm.runInContext(fs.readFileSync(path.join(__dirname, '../public/assets/circulation-desk.js'), 'utf8'), context);
const trace = id => ({ data: { id, receipt_id: null, source: 'online', student_name: 'Reader', student_code: 'SV001', status: 'pending', requested_at: '2026-11-10', reviewed_at: null, librarian_name: null } });

(async () => {
  for (const staleError of [false, true]) {
    const first = vm.runInContext('showRequestTrace("book",1)', context);
    const second = vm.runInContext('showRequestTrace("book",2)', context);
    const [oldTrace, newTrace] = pending.splice(0);
    newTrace.resolve(trace(2)); await second;
    if (staleError) oldTrace.reject(new Error('Old trace 1')); else oldTrace.resolve(trace(1));
    await first;
    assert.ok(node('#request-trace-result').innerHTML.includes('Yêu cầu #2'));
    assert.ok(!node('#request-trace-result').innerHTML.includes('Yêu cầu #1'));
    assert.ok(!node('#request-trace-result').innerHTML.includes('ERROR:'));
  }
  const old = vm.runInContext('showRequestTrace("book",3)', context);
  const request = pending.shift();
  vm.runInContext('state.user=null;configureCirculationDesk()', context);
  request.resolve(trace(3)); await old;
  assert.equal(node('#request-trace-result').innerHTML.includes('Yêu cầu #3'), false);
  console.log('Passed stale success/error ordering for trace, plus sign-out invalidation.');
})().catch(error => { console.error(error); process.exitCode = 1; });
