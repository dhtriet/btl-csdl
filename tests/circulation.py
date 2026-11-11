"""HTTP integration checks; only a separately cloned resource_center_test_<digits> DB."""
import datetime
import concurrent.futures
import http.cookiejar
import json
import os
import pathlib
import re
import subprocess
import time
import urllib.error
import urllib.request

root = pathlib.Path(__file__).resolve().parents[1]
if not re.fullmatch(r'resource_center_test_\d+', os.environ.get('NEXUS_DB_NAME', '')):
    raise SystemExit('Set NEXUS_DB_NAME to an isolated cloned test database.')
base = 'http://127.0.0.1:8014'
checks = []

class Client:
    def __init__(self, base_url=base):
        self.base_url = base_url
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
        self.csrf = ''
        self.user = None

    def call(self, path, method='GET', body=None, expected=200, csrf=True):
        headers = {'Content-Type': 'application/json'}
        if csrf:
            headers['X-CSRF-Token'] = self.csrf
        request = urllib.request.Request(self.base_url + path, data=json.dumps(body).encode() if body is not None else None, headers=headers, method=method)
        try:
            response = self.opener.open(request, timeout=20)
        except urllib.error.HTTPError as error:
            response = error
        data = json.loads(response.read().decode())
        assert response.code == expected, (path, expected, response.code, data)
        checks.append(f'{method} {path}: {expected}')
        return data.get('data', data)

    def login(self, username):
        result = self.call('/api/login', 'POST', {'username': username, 'password': os.environ.get('NEXUS_TEST_PASS', '12345')})
        self.csrf = result['csrf_token']
        self.user = result['user']
        return self

output = root / 'tests/output'
output.mkdir(exist_ok=True)
with (output / 'circulation-server.log').open('w', encoding='utf-8') as log:
    server = subprocess.Popen([os.environ.get('NEXUS_PHP', 'php'), '-S', '127.0.0.1:8014', '-t', 'public'], cwd=root, stdout=log, stderr=log, creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
    try:
        for _ in range(50):
            try:
                urllib.request.urlopen(base, timeout=1).close()
                break
            except OSError:
                time.sleep(.1)
        anon = Client()
        anon.call('/api/circulation/inventory', expected=401)
        admin, staff, student, other = [Client().login(name) for name in ['user1', 'user2', 'user3', 'user4']]
        student.call('/api/circulation/inventory', expected=403)
        staff.call(f'/api/accounts/{student.user["id"]}', expected=403)
        profile = admin.call(f'/api/accounts/{student.user["id"]}')
        assert {'phone', 'address', 'date_of_birth', 'faculty', 'class_name'} <= profile['profile'].keys()
        assert 'password' not in json.dumps(profile)
        admin.call(f'/api/accounts/{staff.user["id"]}')
        admin.call('/api/circulation/counter-loans', 'POST', {}, expected=403)
        staff.call('/api/circulation/counter-loans', 'POST', {}, expected=403, csrf=False)
        publisher = admin.call('/api/manage/options')['publishers'][0]['id']
        stamp = str(time.time_ns())
        books = []
        for index in range(2):
            book = admin.call('/api/manage/books', 'POST', {'title': f'COUNTER_TEST_{stamp}_{index}', 'publisher_id': publisher, 'language': 'Tiếng Việt', 'pages': 10, 'authors': [], 'genres': [], 'keywords': []}, 201)
            books.append(book)
            for copy in range(2):
                admin.call('/api/manage/copies', 'POST', {'book_id': book['id'], 'barcode': f'T{stamp}{index}{copy}', 'storage_location': 'TEST', 'condition_status': 'good', 'status': 'available'}, 201)
        equipment = admin.call('/api/manage/equipment', 'POST', {'name': f'COUNTER_EQUIPMENT_{stamp}', 'equipment_type': 'TEST', 'total_quantity': 5, 'status': 'available'}, 201)
        due = (datetime.date.today() + datetime.timedelta(days=14)).isoformat()
        reader_code = student.user['student_code']
        def book_body(quantity=1):
            return {'type': 'book', 'student_code': reader_code, 'items': [{'book_id': books[0]['id'], 'quantity': quantity, 'requested_due_date': due}]}
        staff.call('/api/circulation/counter-loans', 'POST', {'type': 'book', 'student_code': 'NO_SUCH_READER', 'items': []}, 404)
        staff.call('/api/circulation/counter-loans', 'POST', {**book_body(), 'items': []}, 422)
        staff.call('/api/circulation/counter-loans', 'POST', book_body(0), 422)
        staff.call('/api/circulation/counter-loans', 'POST', book_body(1.5), 422)
        pending_before = staff.call('/api/borrow-requests/pending')
        staff.call('/api/circulation/counter-loans', 'POST', book_body(3), 422)
        pending_after = staff.call('/api/borrow-requests/pending')
        assert len(pending_before) == len(pending_after), 'Failed counter loan left a pending request'
        body = book_body(2)
        body['items'].append({'book_id': books[1]['id'], 'quantity': 1, 'requested_due_date': due})
        receipt = staff.call('/api/circulation/counter-loans', 'POST', body, 201)
        trace_path = f'/api/circulation/trace/book/{receipt["id"]}'
        trace = student.call(trace_path)
        assert trace['source'] == 'counter' and trace['receipt_id'] == receipt['receipt_id']
        assert len(trace['details']) == 3 and len({row['barcode'] for row in trace['details']}) == 3
        other.call(trace_path, expected=403)
        staff.call(f'/api/borrow-requests/book/{receipt["id"]}/review', 'POST', {'decision': 'approved'}, 422)
        for detail in trace['details']:
            staff.call(f'/api/returns/books/{detail["id"]}', 'POST', {'condition_on_return': 'good'})
        staff.call(f'/api/returns/books/{trace["details"][0]["id"]}', 'POST', {'condition_on_return': 'good'}, 422)
        returned = admin.call(f'/api/loan-receipts/{receipt["receipt_id"]}')
        assert returned['status'] == 'completed' and returned['request_id'] == receipt['id']
        # Online approval uses the same persisted link and remains compatible.
        online = student.call('/api/book-loan-requests', 'POST', {'items': book_body()['items']}, 201)
        approved = staff.call(f'/api/borrow-requests/book/{online["id"]}/review', 'POST', {'decision': 'approved'})
        assert student.call(f'/api/circulation/trace/book/{online["id"]}')['source'] == 'online'
        online_receipt = student.call(f'/api/loan-receipts/{approved["receipt_id"]}')
        for detail in online_receipt['details']:
            staff.call(f'/api/returns/books/{detail["id"]}', 'POST', {'condition_on_return': 'good'})
        loan = staff.call('/api/circulation/counter-loans', 'POST', {'type': 'equipment', 'student_code': reader_code, 'items': [{'equipment_id': equipment['id'], 'quantity': 2, 'requested_due_date': due}]}, 201)
        def stock():
            return next(row for row in admin.call('/api/circulation/inventory') if row['id'] == equipment['id'])
        before = stock()
        assert (before['available_quantity'], before['on_loan_quantity'], before['unavailable_quantity'], before['difference']) == (3, 2, 0, 0)
        reconcile = {'total_quantity': 5, 'available_quantity': 2, 'unavailable_quantity': 1, 'reason': 'TEST kiểm kê một đơn vị không khả dụng', 'version': before['version']}
        student.call(f'/api/circulation/inventory/{equipment["id"]}', 'POST', reconcile, 403)
        admin.call(f'/api/circulation/inventory/{equipment["id"]}', 'POST', {**reconcile, 'reason': ''}, 422)
        admin.call(f'/api/circulation/inventory/{equipment["id"]}', 'POST', {**reconcile, 'available_quantity': 5}, 422)
        verified = admin.call(f'/api/circulation/inventory/{equipment["id"]}', 'POST', reconcile)
        assert verified['inventory_verified_at'] and verified['difference'] == 0
        admin.call(f'/api/circulation/inventory/{equipment["id"]}', 'POST', reconcile, 409)
        history = staff.call(f'/api/circulation/inventory/{equipment["id"]}')
        assert history[0]['actor_account_id'] == admin.user['id'] and history[0]['reason'] == reconcile['reason']
        eq_trace = student.call(f'/api/circulation/trace/equipment/{loan["id"]}')
        assert eq_trace['receipt_id'] == loan['loan_id'] and eq_trace['details'][0]['quantity'] == 2
        other.call(f'/api/circulation/trace/equipment/{loan["id"]}', expected=403)
        staff.call(f'/api/returns/equipment/{eq_trace["details"][0]["id"]}', 'POST', {'condition_on_return': 'Tot'})
        after = stock()
        assert (after['available_quantity'], after['on_loan_quantity'], after['unavailable_quantity'], after['difference']) == (4, 0, 1, 0)
        # General resource quantity edits are also recorded in the ledger.
        old = admin.call(f'/api/manage/equipment/{equipment["id"]}')
        admin.call(f'/api/manage/equipment/{equipment["id"]}', 'PUT', {**old, 'total_quantity': 6})
        assert staff.call(f'/api/circulation/inventory/{equipment["id"]}')[0]['event_type'] == 'adjustment'
        assert stock()['difference'] == 0
        # Two independent servers/sessions compete for the final equipment unit.
        final_unit = admin.call('/api/manage/equipment', 'POST', {'name': f'COUNTER_RACE_{stamp}', 'equipment_type': 'TEST', 'total_quantity': 1, 'status': 'available'}, 201)
        second_server = subprocess.Popen([os.environ.get('NEXUS_PHP', 'php'), '-S', '127.0.0.1:8015', '-t', 'public'], cwd=root, stdout=log, stderr=log, creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        for _ in range(50):
            try:
                urllib.request.urlopen('http://127.0.0.1:8015', timeout=1).close()
                break
            except OSError:
                time.sleep(.1)
        racer_a, racer_b = Client().login('user2'), Client('http://127.0.0.1:8015').login('user2')
        gate = subprocess.Popen([os.environ.get('NEXUS_PHP', 'php'), 'tests/fixtures.php', 'gate', 'equipment', str(final_unit['id'])], cwd=root, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=log, text=True, creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
        assert gate.stdout.readline().strip() == 'locked'
        race_body = {'type': 'equipment', 'student_code': reader_code, 'items': [{'equipment_id': final_unit['id'], 'quantity': 1, 'requested_due_date': due}]}
        def race(client):
            request = urllib.request.Request(client.base_url + '/api/circulation/counter-loans', data=json.dumps(race_body).encode(), headers={'Content-Type': 'application/json', 'X-CSRF-Token': client.csrf}, method='POST')
            try:
                response = client.opener.open(request, timeout=20)
            except urllib.error.HTTPError as error:
                response = error
            return response.code, json.loads(response.read())
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            futures = [pool.submit(race, client) for client in [racer_a, racer_b]]
            time.sleep(.3)
            gate.stdin.write('\n'); gate.stdin.flush(); gate.wait(timeout=10)
            responses = [future.result() for future in futures]
        assert sum(code == 201 for code, _ in responses) == 1 and all(code in (201, 409, 422) for code, _ in responses), responses
        race_stock = next(row for row in admin.call('/api/circulation/inventory') if row['id'] == final_unit['id'])
        assert (race_stock['available_quantity'], race_stock['on_loan_quantity'], race_stock['difference']) == (0, 1, 0)
        winner = next(result['data'] for code, result in responses if code == 201)
        race_trace = student.call(f'/api/circulation/trace/equipment/{winner["id"]}')
        staff.call(f'/api/returns/equipment/{race_trace["details"][0]["id"]}', 'POST', {'condition_on_return': 'Tot'})
        checks.append('Concurrent counter loans: final unit allocated exactly once; failed transaction rolled back')
        result = {'passed': len(checks), 'checks': checks, 'database': os.environ['NEXUS_DB_NAME']}
        (output / 'circulation-result.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
        print(f'Passed {len(checks)} HTTP checks; atomic counter loans, tracing, roles, returns and inventory balances verified.')
    finally:
        if 'gate' in locals() and gate.poll() is None:
            gate.terminate()
            gate.wait(timeout=10)
        if 'second_server' in locals():
            second_server.terminate()
            second_server.wait(timeout=10)
        server.terminate()
        server.wait(timeout=10)
