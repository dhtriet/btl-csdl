"""Run against the isolated PHP test server on port 8016; never production."""
import http.cookiejar,json,os,re,time,urllib.error,urllib.request
assert re.fullmatch(r'resource_center_test_\d+',os.environ.get('NEXUS_DB_NAME','')), 'Isolated test database required'
base='http://127.0.0.1:8016'
checks=[]
class Client:
    def __init__(self,name):
        self.http=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()));self.token=''
        self.token=self.call('/api/login','POST',{'username':name,'password':'12345'})['csrf_token']
    def call(self,path,method='GET',body=None,expected=200,csrf=True):
        req=urllib.request.Request(base+path,data=json.dumps(body).encode() if body is not None else None,method=method,headers={'Content-Type':'application/json','X-CSRF-Token':self.token if csrf else ''})
        try:r=self.http.open(req,timeout=20)
        except urllib.error.HTTPError as e:r=e
        d=json.load(r);assert r.code==expected,(path,r.code,d);checks.append(r.code);return d.get('data',d)
staff,student=Client('user2'),Client('user3')
stamp=str(time.time_ns())
publisher=staff.call('/api/manage/options')['publishers'][0]['id']
book=staff.call('/api/manage/books','POST',{'title':'DELETE TEST '+stamp,'publisher_id':publisher,'language':'Tiếng Việt','authors':[],'genres':[],'keywords':[]},201)
copy=staff.call('/api/manage/copies','POST',{'book_id':book['id'],'barcode':'DEL'+stamp,'storage_location':'TEST','condition_status':'good','status':'available'},201)
room=staff.call('/api/manage/rooms','POST',{'name':'DELETE ROOM '+stamp,'room_type':'classroom','location':'TEST','capacity':10,'status':'available'},201)
equipment=staff.call('/api/manage/equipment','POST',{'name':'DELETE EQUIPMENT '+stamp,'equipment_type':'TEST','total_quantity':1,'status':'available'},201)
for kind,row in [('copies',copy),('books',book),('rooms',room),('equipment',equipment)]:
    path=f'/api/manage/{kind}/{row["id"]}'
    version=staff.call(path)['version']
    student.call(path,'DELETE',{'version':version},403)
    staff.call(path,'DELETE',{'version':version},403,csrf=False)
    staff.call(path,'DELETE',{'version':'stale'},409)
    assert staff.call(path,'DELETE',{'version':version})['deleted']
    staff.call(path,expected=404)
# A seeded book has an active loan. Permission to delete must not bypass this rule.
path='/api/manage/books/1';version=staff.call(path)['version']
staff.call(path,'DELETE',{'version':version},409)
print(json.dumps({'checks':len(checks),'four_types_deleted_by_librarian':True,'student_csrf_stale_blocked':True,'active_loan_protected':True}))
