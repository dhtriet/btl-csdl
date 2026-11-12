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


with (root/'tests/output/resource-extensions-server.log').open('w',encoding='utf-8') as out:
    server=subprocess.Popen(['php','-S','127.0.0.1:8016','-t','public'],cwd=root,stdout=out,stderr=out,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
    try:
        for _ in range(50):
            try:urllib.request.urlopen(base,timeout=1).close();break
            except OSError:time.sleep(.1)
        Client().call('/api/resource-extension-requests',expected=401)
        admin,staff,student,other=[Client().login(n) for n in ['user1','user2','user3','user4']]
        stamp=str(time.time_ns())
        eq=admin.call('/api/manage/equipment','POST',{'name':'RENEW '+stamp,'equipment_type':'TEST','total_quantity':5,'status':'available'},201)
        due=(datetime.date.today()+datetime.timedelta(days=7)).isoformat()
        proposed=(datetime.date.today()+datetime.timedelta(days=14)).isoformat()
        loan=staff.call('/api/circulation/counter-loans','POST',{'type':'equipment','student_code':student.user['student_code'],'items':[{'equipment_id':eq['id'],'quantity':2,'requested_due_date':due}]},201)
        trace=student.call('/api/circulation/trace/equipment/'+str(loan['id']))
        target=trace['details'][0]['id']
        body={'resource_type':'equipment','target_id':target,'new_due_date':proposed}
        for client in [staff,admin,other]:client.call('/api/resource-extension-requests','POST',body,403)
        student.call('/api/resource-extension-requests','POST',body,403,csrf=False)
        student.call('/api/resource-extension-requests','POST',{**body,'new_due_date':due},422)
        req=student.call('/api/resource-extension-requests','POST',body,201)
        def equipment():return next(r for r in staff.call('/api/returns/equipment') if r['equipment_detail_id']==target)
        assert equipment()['due_date']==due
        assert admin.call('/api/manage/equipment/'+str(eq['id']))['available_quantity']==3
        assert not any(r['id']==req['id'] for r in other.call('/api/resource-extension-requests'))
        student.call('/api/resource-extension-requests','POST',body,409)
        review='/api/resource-extension-requests/'+str(req['id'])+'/review'
        student.call(review,'POST',{'status':'approved'},403)
        staff.call(review,'POST',{'status':'approved'})
        assert equipment()['due_date']==proposed
        assert admin.call('/api/manage/equipment/'+str(eq['id']))['available_quantity']==3
        staff.call(review,'POST',{'status':'approved'},409)
        # A returned device cannot be renewed and an outstanding request can be rejected.
        body['new_due_date']=(datetime.date.today()+datetime.timedelta(days=21)).isoformat()
        req=student.call('/api/resource-extension-requests','POST',body,201)
        staff.call('/api/returns/equipment/'+str(target),'POST',{'late_days':0})
        review='/api/resource-extension-requests/'+str(req['id'])+'/review'
        staff.call(review,'POST',{'status':'approved'},409)
        staff.call(review,'POST',{'status':'rejected'},422)
        staff.call(review,'POST',{'status':'rejected','review_note':'Thiết bị đã trả.'})
        assert admin.call('/api/manage/equipment/'+str(eq['id']))['available_quantity']==5
        # Three approved renewals is also enforced for equipment; review requires staff+CSRF.
        loan2=staff.call('/api/circulation/counter-loans','POST',{'type':'equipment','student_code':student.user['student_code'],'items':[{'equipment_id':eq['id'],'quantity':1,'requested_due_date':due}]},201)
        target2=student.call('/api/circulation/trace/equipment/'+str(loan2['id']))['details'][0]['id']
        for days in [14,21,28]:
            b={'resource_type':'equipment','target_id':target2,'new_due_date':(datetime.date.today()+datetime.timedelta(days=days)).isoformat()}
            r=student.call('/api/resource-extension-requests','POST',b,201)
            url='/api/resource-extension-requests/'+str(r['id'])+'/review'
            if days==14:
                admin.call(url,'POST',{'status':'approved'},403)
                staff.call(url,'POST',{'status':'approved'},403,csrf=False)
            staff.call(url,'POST',{'status':'approved'})
        student.call('/api/resource-extension-requests','POST',{**b,'new_due_date':(datetime.date.today()+datetime.timedelta(days=35)).isoformat()},422)
        # Room deadlines remain on the booking day; a later reservation can block approval.
        room=admin.call('/api/manage/rooms','POST',{'name':'RENEW ROOM '+stamp,'room_type':'classroom','location':'TEST','capacity':12,'status':'available'},201)
        day=(datetime.date.today()+datetime.timedelta(days=3)).isoformat()
        def book(start,end,client=student):
            r=client.call('/api/room-requests','POST',{'room_id':room['id'],'use_date':day,'start_time':start,'end_time':end,'purpose':'Gia hạn kiểm thử'},201)
            staff.call('/api/borrow-requests/room/'+str(r['id'])+'/review','POST',{'decision':'approved'})
            return r['id']
        booking=book('08:00','10:00')
        body={'resource_type':'room','target_id':booking,'new_end_time':'12:00'}
        other.call('/api/resource-extension-requests','POST',body,403)
        for end in ['09:00','25:00','12:99']:
            student.call('/api/resource-extension-requests','POST',{**body,'new_end_time':end},422)
        req=student.call('/api/resource-extension-requests','POST',body,201)
        def booking_row():return next(r for r in student.call('/api/room-requests?status=approved') if r['id']==booking)
        assert booking_row()['end_time']=='10:00:00'
        student.call('/api/resource-extension-requests','POST',body,409)
        conflict=book('11:00','13:00',other)
        review='/api/resource-extension-requests/'+str(req['id'])+'/review'
        staff.call(review,'POST',{'status':'approved'},409)
        assert booking_row()['end_time']=='10:00:00'
        staff.call(review,'POST',{'status':'rejected','review_note':'Trùng lịch phòng.'})
        student.call('/api/resource-extension-requests','POST',body,409)
        req=student.call('/api/resource-extension-requests','POST',{**body,'new_end_time':'11:00'},201)
        staff.call('/api/resource-extension-requests/'+str(req['id'])+'/review','POST',{'status':'approved'})
        assert booking_row()['end_time']=='11:00:00'
        # Inclusive end-of-day limit is supported, and three approved requests is the cap.
        late=book('20:00','21:00')
        for end in ['22:00','23:00','24:00']:
            r=student.call('/api/resource-extension-requests','POST',{'resource_type':'room','target_id':late,'new_end_time':end},201)
            staff.call('/api/resource-extension-requests/'+str(r['id'])+'/review','POST',{'status':'approved'})
        late_row=next(r for r in student.call('/api/room-requests?status=approved') if r['id']==late)
        assert late_row['end_time']=='24:00:00'
        staff.call('/api/returns/rooms/'+str(booking),'POST',{})
        student.call('/api/resource-extension-requests','POST',{**body,'new_end_time':'11:30'},409)
        assert any(r.get('resource_type')=='room' for r in staff.call('/api/extension-requests'))
        print(json.dumps({'checks':len(checks),'equipment_stock_unchanged':True,'room_conflict_rechecked':True,'midnight_supported':True,'permissions_csrf_ownership':True}))
    finally:server.terminate();server.wait(timeout=10)
