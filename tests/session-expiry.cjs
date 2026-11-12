const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const source = fs.readFileSync('public/assets/app.js', 'utf8');
const apiSource = source.slice(source.indexOf('async function api('), source.indexOf('\nfunction showToast('));
async function check(status, signedIn) {
  const state = { user: signedIn ? { id: 3 } : null, csrfToken: 'old-token' };
  let resets = 0, focused = 0;
  const ctx = vm.createContext({ state, fetch: async () => ({ status, ok: status === 200, json: async () => ({ message: 'Server message', csrf_token: 'new-token' }) }), setUser: user => { state.user = user; resets++; }, $: () => ({ focus: () => focused++ }) });
  vm.runInContext(apiSource, ctx);
  if (status === 200) await ctx.api('/api/dashboard');
  else await assert.rejects(ctx.api('/api/dashboard'), status === 401 && signedIn ? /Phiên đăng nhập đã hết hạn/ : /Server message/);
  if (status === 401 && signedIn) {
    assert.equal(state.user, null); assert.equal(state.csrfToken, null);
    assert.equal(resets, 1); assert.equal(focused, 1);
  } else { assert.equal(resets, 0); assert.equal(focused, 0); }
}
(async () => {
  await check(401, true); await check(401, false); await check(403, true); await check(200, true);
  console.log('Passed expired session, anonymous sign-in, forbidden response and successful response checks.');
})().catch(error => { console.error(error); process.exitCode = 1; });
