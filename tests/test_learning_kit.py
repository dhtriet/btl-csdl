import sys, unittest, json
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
import learning_kit as kit
import chat_worker as worker

CATALOG=[{'id':1,'title':'Database System Concepts','genres':'Cơ sở dữ liệu','summary':'Thiết kế cơ sở dữ liệu','authors':'A'},
         {'id':2,'title':'Văn học tuổi thơ','genres':'Văn học','summary':'Một câu chuyện','authors':'B'}]
SOURCES=[{'id':'S1','book_id':1,'title':'Database System Concepts','page':4,'excerpt':'test'},
         {'id':'S2','book_id':2,'title':'Văn học tuổi thơ','page':1,'excerpt':'test'}]

def reply():
    return {'answer':'Gợi ý học tập [S1]','source_ids':['S1'],'follow_ups':[],'grounding':'partial',
            'books':[{'book_id':1,'reason':'Phù hợp mục tiêu [S1]','reading_focus':'Thiết kế bảng','source_ids':['S1']}],
            'weeks':[{'week':1,'focus':'Thiết kế','task':'Vẽ mô hình và kiểm tra khóa','book_ids':[1],'source_ids':['S1']}]}

class LearningKitTests(unittest.TestCase):
    def test_vietnamese_goal_ranks_real_catalog(self):
        found=kit.candidates('Tôi muốn làm đồ án cơ sở dữ liệu',CATALOG,worker.normalize)
        self.assertEqual([b['id'] for b in found],[1])

    def test_unrelated_goal_has_no_invented_fallback(self):
        self.assertEqual(kit.candidates('quantum astrophysics zzz',CATALOG,worker.normalize),[])

    def test_invalid_and_duplicate_books_removed(self):
        data=reply();data['books'] += [dict(data['books'][0]),dict(data['books'][0],book_id=999)]
        self.assertEqual(len(kit.sanitize(data,CATALOG,SOURCES,1)['books']),1)

    def test_cross_book_and_unknown_sources_removed(self):
        data=reply();data['books'][0]['source_ids']=['S1','S2','S999'];data['books'][0]['reason']='A [S1] B [S2] C [S999]'
        result=kit.sanitize(data,CATALOG,SOURCES,1)['books'][0]
        self.assertEqual(result['source_ids'],['S1']);self.assertNotIn('S2',result['reason']);self.assertNotIn('S999',result['reason'])

    def test_missing_schedule_rejected(self):
        with self.assertRaises(ValueError):kit.sanitize(reply(),CATALOG,SOURCES,3)

    def test_unverified_chapter_numbers_not_presented_as_reading_instructions(self):
        data=reply();data['books'][0]['reading_focus']='Chương IV: SQL (xem S1) và Chapter 99: indexes [S999]'
        result=kit.sanitize(data,CATALOG,SOURCES,1)['books'][0]
        self.assertNotIn('Chương',result['reading_focus']);self.assertNotIn('Chapter',result['reading_focus'])
        self.assertEqual(result['source_ids'],['S1'])

    def test_wrong_week_sequence_rejected(self):
        data=reply();data['weeks'][0]['week']=2
        with self.assertRaises(ValueError):kit.sanitize(data,CATALOG,SOURCES,1)

    def test_week_cannot_reference_nonrecommended_book(self):
        data=reply();data['weeks'][0]['book_ids']=[1,2,999]
        self.assertEqual(kit.sanitize(data,CATALOG,SOURCES,1)['weeks'][0]['book_ids'],[1])

    def test_kit_schema_stays_strict_and_chat_schema_unchanged(self):
        for provider in ['groq','gemini']:
            request=worker.provider_request({'provider':provider,'api_key':'private','model':'test'},'system',{'mode':'kit'})
            body=json.loads(request.data)
            schema=body['response_format']['json_schema']['schema'] if provider=='groq' else body['generationConfig']['responseSchema']
            self.assertIn('books',schema['required']);self.assertFalse(schema['properties']['weeks']['items']['additionalProperties'])
        self.assertNotIn('books',worker.response_schema()['properties'])

    def test_generation_uses_catalog_ids_and_returns_verified_sources(self):
        class Response:
            def __enter__(self):return self
            def __exit__(self,*args):return False
            def read(self):return json.dumps({'choices':[{'finish_reason':'stop','message':{'content':json.dumps(reply())}}]}).encode()
        with patch.object(worker,'config',return_value={'provider':'groq','api_key':'private','model':'test'}),patch.object(worker,'retrieve',return_value=(SOURCES,[])),patch.object(worker.urllib.request,'urlopen',return_value=Response()):
            result=worker.generate({'mode':'kit','catalog':CATALOG,'message':'Đồ án cơ sở dữ liệu','weeks':1,'minutes':45,'level':'Mới bắt đầu'})
        self.assertEqual(result['books'][0]['book_id'],1)
        self.assertEqual([s['id'] for s in result['sources']],['S1'])
        self.assertNotIn('private',json.dumps(result))

if __name__=='__main__':unittest.main()
