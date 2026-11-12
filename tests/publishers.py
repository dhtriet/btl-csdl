"""Custom publishers: run only against the isolated test server on port 8016."""
import http.cookiejar,json,os,re,time,urllib.error,urllib.request
assert re.fullmatch(r'resource_center_test_\d+',os.environ.get('NEXUS_DB_NAME','')), 'Isolated database required'
base='http://127.0.0.1:8016';checks=[]
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
name='Publisher test '+str(time.time_ns())
body={'title':'Publisher integration test','publisher_id':'__new__','publisher_name':name,'language':'Tiếng Việt','authors':[],'genres':[],'keywords':[]}
student.call('/api/manage/books','POST',body,403)
staff.call('/api/manage/books','POST',body,403,csrf=False)
staff.call('/api/manage/books','POST',{**body,'publisher_name':''},422)
staff.call('/api/manage/books','POST',{**body,'pages':-1},422)
assert not any(p['name']==name for p in staff.call('/api/manage/options')['publishers']), 'Invalid book must not leave a publisher behind'
book=staff.call('/api/manage/books','POST',body,201)
other=staff.call('/api/manage/books','POST',{**body,'publisher_name':'  '+name.upper()+'  '},201)
assert book['publisher_id']==other['publisher_id']
assert sum(p['name']==name for p in staff.call('/api/manage/options')['publishers'])==1
row=staff.call('/api/manage/books/'+str(book['id']))
updated=staff.call('/api/manage/books/'+str(book['id']),'PUT',{**body,'publisher_name':name+' edit','version':row['version']})
assert updated['publisher_id']!=book['publisher_id']
existing=staff.call('/api/manage/books','POST',{**body,'publisher_id':book['publisher_id']},201)
assert existing['publisher_id']==book['publisher_id']
print(json.dumps({'checks':len(checks),'custom_publisher':True,'reuses_existing_name':True,'atomic_rollback':True,'edit_and_existing_selection':True,'roles_csrf':True}))
