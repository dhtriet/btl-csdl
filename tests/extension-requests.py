"""Renewal workflow HTTP checks against an explicitly isolated test database."""
import datetime, http.cookiejar, json, os, pathlib, re, subprocess, time, urllib.error, urllib.request

assert re.fullmatch(r'resource_center_test_\d+', os.environ.get('NEXUS_DB_NAME', '')), 'Isolated test DB required'
root=pathlib.Path(__file__).resolve().parents[1]
base='http://127.0.0.1:8016'
checks=[]
class Client:
    def __init__(self):
        self.client=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
        self.token=''
    def call(self,path,method='GET',body=None,expected=200,csrf=True):
        headers={'Content-Type':'application/json','X-CSRF-Token':self.token if csrf else ''}
        req=urllib.request.Request(base+path,data=json.dumps(body).encode() if body is not None else None,headers=headers,method=method)
        try:r=self.client.open(req,timeout=20)
        except urllib.error.HTTPError as e:r=e
        data=json.load(r);assert r.code==expected,(path,r.code,data)
        checks.append(f'{method} {path}: {expected}')
        return data.get('data',data)
    def login(self,name):
        data=self.call('/api/login','POST',{'username':name,'password':'12345'})
        self.token=data['csrf_token'];self.user=data['user'];return self

log=(root/'tests/output');log.mkdir(exist_ok=True)
with (log/'extensions-server.log').open('w',encoding='utf-8') as out:
    server=subprocess.Popen(['php','-S','127.0.0.1:8016','-t','public'],cwd=root,stdout=out,stderr=out,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
    try:
        for _ in range(50):
            try:urllib.request.urlopen(base,timeout=1).close();break
            except OSError:time.sleep(.1)
        anon=Client();anon.call('/api/extension-requests',expected=401)
        admin,staff,student,other=[Client().login(n) for n in ['user1','user2','user3','user4']]
        pub=admin.call('/api/manage/options')['publishers'][0]['id']
        book=admin.call('/api/manage/books','POST',{'title':'RENEWAL TEST '+str(time.time_ns()),'publisher_id':pub,'language':'Tiếng Việt','authors':[],'genres':[],'keywords':[]},201)
        for n in range(2):admin.call('/api/manage/copies','POST',{'book_id':book['id'],'barcode':'EXT'+str(time.time_ns()),'storage_location':'TEST','condition_status':'good','status':'available'},201)
        due=(datetime.date.today()+datetime.timedelta(days=7)).isoformat()
        receipt=staff.call('/api/circulation/counter-loans','POST',{'type':'book','student_code':student.user['student_code'],'items':[{'book_id':book['id'],'quantity':2,'requested_due_date':due}]},201)
        trace=student.call('/api/circulation/trace/book/'+str(receipt['id']))
        loan,second=[d['id'] for d in trace['details']]
        def history():return student.call('/api/students/'+student.user['student_code']+'/history')['items']
        def detail():return next(r for r in history() if r.get('loan_detail_id')==loan)
        def body(loan_id=loan,days=14):return {'loan_detail_id':loan_id,'new_due_date':(datetime.date.today()+datetime.timedelta(days=days)).isoformat(),'reason':'Cần hoàn thành bài tập'}
        for c in [staff,admin]:c.call('/api/extension-requests','POST',body(),403)
        student.call('/api/extension-requests','POST',body(),403,csrf=False)
        other.call('/api/extension-requests','POST',body(),403)
        student.call('/api/extension-requests','POST',{**body(),'new_due_date':due},422)
        req=student.call('/api/extension-requests','POST',body(),201)
        assert detail()['due_date']==due and detail()['extension_count']==0
        assert all(r['id']!=req['id'] for r in other.call('/api/extension-requests'))
        student.call('/api/extension-requests','POST',body(),409)
        review=f'/api/extension-requests/{req["id"]}/review'
        student.call(review,'POST',{'status':'approved'},403)
        admin.call(review,'POST',{'status':'approved'},403)
        staff.call(review,'POST',{'status':'approved'},403,csrf=False)
        staff.call(f'/api/loan-details/{loan}/extend','POST',{'new_due_date':body()['new_due_date']},403)
        staff.call(review,'POST',{'status':'approved'})
        assert detail()['due_date']==body()['new_due_date'] and detail()['extension_count']==1
        staff.call(review,'POST',{'status':'approved'},409)
        rejected=student.call('/api/extension-requests','POST',body(days=21),201)
        review=f'/api/extension-requests/{rejected["id"]}/review'
        staff.call(review,'POST',{'status':'rejected'},422)
        staff.call(review,'POST',{'status':'rejected','review_note':'Cần trả sách để phục vụ bạn đọc khác.'})
        assert detail()['extension_count']==1 and detail()['due_date']==body()['new_due_date']
        for count,days in [(2,21),(3,28)]:
            req=student.call('/api/extension-requests','POST',body(days=days),201)
            staff.call(f'/api/extension-requests/{req["id"]}/review','POST',{'status':'approved'})
            assert detail()['extension_count']==count
        student.call('/api/extension-requests','POST',body(days=35),422)
        req=student.call('/api/extension-requests','POST',body(loan_id=second),201)
        staff.call(f'/api/returns/books/{second}','POST',{'condition_on_return':'good'})
        staff.call(f'/api/extension-requests/{req["id"]}/review','POST',{'status':'approved'},409)
        staff.call(f'/api/extension-requests/{req["id"]}/review','POST',{'status':'rejected','review_note':'Sách đã trả.'})
        student.call('/api/extension-requests','POST',body(loan_id=second),422)
        print(json.dumps({'checks':len(checks),'unchanged_until_approved':True,'permissions_csrf_duplicates':True,'rejection_preserves_due':True,'max_three':True,'returned_book_blocked':True}))
    finally:server.terminate();server.wait(timeout=10)
