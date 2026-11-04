from pathlib import Path
import subprocess,json,unicodedata,hashlib,shutil,urllib.request
root=Path.cwd(); rows=json.loads(subprocess.check_output(['php','scripts/list-resource-images.php']).decode('utf-8-sig')); source=Path(r'E:\dhtriet\OneDrive - ptit.edu.vn\Desktop')
def norm(s):return ''.join(c for c in unicodedata.normalize('NFD',s.casefold().replace('đ','d')) if not unicodedata.combining(c)).strip()
manifest=[]
for b in rows['books']:
 for f in source.iterdir():
  if f.suffix.lower() in ['.jpg','.png','.webp'] and norm(f.stem)==norm(b['title']):
   target='/uploads/covers/'+hashlib.md5(f.read_bytes()).hexdigest()+f.suffix.lower();dest=root/'public'/target.lstrip('/');dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(f,dest);manifest.append(dict(table='books',id=b['id'],path=target,source=str(f),title=b['title']));break
stock=[('classroom','1565057748808-18c797216b0c','Barry Zhou','https://unsplash.com/photos/empty-classroom-khjwIW9HH5s'),('meeting','1505845753232-f74a87b62db6','ål nik','https://unsplash.com/photos/white-chair-lot-J5XqX-qvEZE'),('electronics','1649959238869-ffa1b63ec661','Vishnu Mohanan','https://unsplash.com/photos/an-electronic-device-with-a-micro-board-attached-to-it-3d2AY-7uyoI'),('laptop','1615852993296-b42d4dbb5555','Vadim Bozhko','https://unsplash.com/photos/black-laptop-computer-on-white-table-SM_hz_zkXxM')]
photos={}
for key,photo,author,page in stock:
 url='https://images.unsplash.com/photo-'+photo+'?auto=format&fit=crop&fm=jpg&w=1000&q=80';data=urllib.request.urlopen(url,timeout=35).read();target='/uploads/resources/'+hashlib.md5(data).hexdigest()+'.jpg';dest=root/'public'/target.lstrip('/');dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data);photos[key]=dict(path=target,source=page,author=author,license='https://unsplash.com/license')
for room in rows['rooms']:
 photo=photos['meeting' if room['room_type']=='meeting_room' else 'classroom'];manifest.append(dict(table='rooms',id=room['id'],**photo))
for item in rows['equipment']:
 key='electronics' if item['id'] in [2,7,9] else 'laptop' if item['id']==5 else None
 if key:manifest.append(dict(table='equipment',id=item['id'],**photos[key]))
Path('docs').mkdir(exist_ok=True);Path('docs/resource-image-import.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8');print('Matched book covers:',sum(x['table']=='books' for x in manifest));print('Seeded illustrative assets:',len(photos))
