import importlib.util,json,sqlite3,sys,unittest
from pathlib import Path
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('chat_worker',ROOT/'scripts'/'chat_worker.py')
worker=importlib.util.module_from_spec(spec);spec.loader.exec_module(worker)

class StudyAssistantTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not worker.INDEX.exists():raise unittest.SkipTest('Build the local PDF index first.')
        manifest=ROOT/'storage'/'assistant-manifest.json'
        if not manifest.exists():raise unittest.SkipTest('Export current book catalog first.')
        cls.catalog=json.loads(manifest.read_text(encoding='utf-8'))
        cls.ready=[item for item in worker.index_status(cls.catalog) if item['status']=='ready']

    def test_vietnamese_search_uses_real_selected_pages(self):
        book=self.ready[0]
        sources,_=worker.retrieve('Tóm tắt nội dung và kiến thức nền tảng',[book['id']],'summary',self.catalog)
        self.assertTrue(sources)
        with sqlite3.connect(worker.INDEX) as conn:
            for source in sources:
                self.assertEqual(source['book_id'],book['id'])
                self.assertLessEqual(source['page'],book['pages'])
                self.assertIsNotNone(conn.execute('SELECT 1 FROM chunks WHERE book_id=? AND page=? AND text=?',(book['id'],source['page'],source['excerpt'])).fetchone())

    def test_three_selected_books_all_get_coverage(self):
        ids=[book['id'] for book in self.ready[:3]]
        sources,_=worker.retrieve('Lộ trình học cho người mới',ids,'roadmap',self.catalog)
        self.assertEqual({source['book_id'] for source in sources},set(ids))
        self.assertLessEqual(len(sources),20)

    def test_catalog_without_pdf_is_not_full_text(self):
        books=[book for book in worker.index_status(self.catalog) if book['status']=='no_pdf']
        if not books:self.skipTest('All books have PDFs')
        sources,_=worker.retrieve('Tóm tắt toàn bộ sách',[books[0]['id']],'summary',self.catalog)
        self.assertEqual(sources,[])

    def test_normalization_handles_vietnamese(self):
        self.assertEqual(worker.normalize('CƠ SỞ DỮ LIỆU và Đồ họa'),'co so du lieu va do hoa')

    def test_provider_failure_is_sanitized(self):
        error=worker.urllib.error.HTTPError('https://generativelanguage.googleapis.com',429,'secret-key-must-not-leak',{},None)
        with patch.object(worker,'config',return_value={'api_key':'secret-key-must-not-leak','model':'gemini-3.6-flash'}),patch.object(worker.urllib.request,'urlopen',side_effect=error):
            result=worker.generate({'message':'Kiến thức nền tảng','catalog':self.catalog,'book_ids':[self.ready[0]['id']],'mode':'ask'})
        self.assertEqual(result['error'],'quota');self.assertNotIn('secret-key',json.dumps(result))

    def test_unknown_citations_removed_and_grouped_citations_normalized(self):
        data={'candidates':[{'content':{'parts':[{'text':json.dumps({'answer':'Nội dung [S1, S2] và [S999]','source_ids':['S1','S999'],'grounding':'grounded','follow_ups':['Học tiếp gì?']})}]}}]}
        class Response:
            def __enter__(self):return self
            def __exit__(self,*args):return False
            def read(self):return json.dumps(data).encode()
        with patch.object(worker,'config',return_value={'api_key':'test','model':'gemini-3.6-flash'}),patch.object(worker.urllib.request,'urlopen',return_value=Response()) as call:
            result=worker.generate({'message':'Tóm tắt sách','catalog':self.catalog,'book_ids':[self.ready[0]['id']],'mode':'summary'})
        request_body=json.loads(call.call_args.args[0].data)
        self.assertEqual(request_body['generationConfig']['thinkingConfig'],{'thinkingLevel':'minimal'})
        self.assertNotIn('S999',result['answer'])
        self.assertIn('[S1] [S2]',result['answer'])
        self.assertTrue(all(source['id'] in ['S1','S2'] for source in result['sources']))

    def test_transient_provider_error_retried_then_succeeds(self):
        data={'candidates':[{'content':{'parts':[{'text':json.dumps({'answer':'Test reply [S1]','source_ids':['S1'],'grounding':'grounded','follow_ups':[]})}]}}]}
        class Response:
            def __enter__(self):return self
            def __exit__(self,*args):return False
            def read(self):return json.dumps(data).encode()
        error=worker.urllib.error.HTTPError('https://generativelanguage.googleapis.com',503,'temporary',{},None)
        with patch.object(worker,'config',return_value={'api_key':'test','model':'gemini-3.6-flash'}),patch.object(worker.urllib.request,'urlopen',side_effect=[error,Response()]) as call,patch.object(worker.time,'sleep'):
            result=worker.generate({'message':'Summary','catalog':self.catalog,'book_ids':[self.ready[0]['id']],'mode':'summary'})
        self.assertEqual(call.call_count,2)
        self.assertIn('answer',result)

    def test_connection_failure_has_bounded_retries(self):
        with patch.object(worker,'config',return_value={'api_key':'test','model':'gemini-3.6-flash'}),patch.object(worker.urllib.request,'urlopen',side_effect=TimeoutError()) as call,patch.object(worker.time,'sleep'):
            result=worker.generate({'message':'Summary','catalog':self.catalog,'book_ids':[self.ready[0]['id']],'mode':'summary'})
        self.assertEqual(call.call_count,3)
        self.assertEqual(result['error'],'connection')
        self.assertEqual(result['error_type'],'TimeoutError')


    def test_groq_request_and_response_use_private_auth_and_real_sources(self):
        data={'choices':[{'finish_reason':'stop','message':{'content':json.dumps({'answer':'Tóm tắt 【S1, S2】 và (S3) [S999]','source_ids':['S1','S999'],'follow_ups':[],'grounding':'grounded'})}}]}
        class Response:
            def __enter__(self):return self
            def __exit__(self,*args):return False
            def read(self):return json.dumps(data).encode()
        question='Tóm tắt kiến thức trong sách đã chọn. '
        with patch.object(worker,'config',return_value={'provider':'groq','api_key':'private-test-key','model':'openai/gpt-oss-120b'}),patch.object(worker.urllib.request,'urlopen',return_value=Response()) as call:
            result=worker.generate({'message':question,'catalog':self.catalog,'book_ids':[self.ready[0]['id']],'mode':'summary'})
        request=call.call_args.args[0];body=json.loads(request.data)
        self.assertEqual(request.full_url,'https://api.groq.com/openai/v1/chat/completions')
        self.assertEqual(request.get_header('Authorization'),'Bearer private-test-key')
        self.assertNotIn('private-test-key',request.data.decode())
        self.assertEqual(body['response_format']['json_schema']['strict'],True)
        self.assertLessEqual(sum(len(m['content'].encode('utf-8')) for m in body['messages']),12000)
        context=json.loads(body['messages'][1]['content'])
        self.assertEqual(context['question'],question)
        sent={s['id']:s for s in context['documents']}
        self.assertTrue(result['sources']);self.assertNotIn('S999',result['answer'])
        self.assertIn('[S1] [S2]',result['answer']);self.assertIn('[S3]',result['answer'])
        for source in result['sources']:
            self.assertIn(source['id'],sent)
            self.assertEqual(source['page'],sent[source['id']]['page'])

    def test_groq_prompt_budget_keeps_three_book_coverage_and_latest_question(self):
        ids=[b['id'] for b in self.ready[:3]]
        sources,_=worker.retrieve('Lộ trình học',ids,'roadmap',self.catalog)
        question=('kiến thức dữ liệu '*130)[:2000]
        context={'mode':'roadmap','selected_book_ids':ids,'catalog':self.catalog,'documents':sources,'question':question,'conversation':[{'role':'user','text':'Lịch sử dài '*500} for _ in range(8)]}
        system='Nguyên tắc trợ lý học tập. '*65
        compact,kept=worker.compact_context(system,context,sources)
        self.assertLessEqual(len(system.encode('utf-8'))+len(json.dumps(compact,ensure_ascii=False).encode('utf-8')),12000)
        self.assertEqual({s['book_id'] for s in kept},set(ids))
        self.assertEqual(compact['question'],question)
        self.assertTrue(all(s['excerpt'] for s in compact['documents']))

    def test_groq_invalid_key_not_retried_and_not_exposed(self):
        error=worker.urllib.error.HTTPError('https://api.groq.com',401,'private-test-key',{},None)
        with patch.object(worker,'config',return_value={'provider':'groq','api_key':'private-test-key','model':'openai/gpt-oss-120b'}),patch.object(worker.urllib.request,'urlopen',side_effect=error) as call:
            result=worker.generate({'message':'Tóm tắt sách','catalog':self.catalog,'book_ids':[self.ready[0]['id']],'mode':'summary'})
        self.assertEqual(call.call_count,1);self.assertEqual(result['error'],'invalid_key')
        self.assertNotIn('private-test-key',json.dumps(result))

    def test_groq_environment_does_not_use_gemini_key(self):
        with patch.dict(worker.os.environ,{'NEXUS_AI_PROVIDER':'groq','GROQ_API_KEY':'groq-env-test','GEMINI_API_KEY':'gemini-env-test','GROQ_MODEL':'openai/gpt-oss-20b'},clear=True):settings=worker.config()
        self.assertEqual(settings['api_key'],'groq-env-test')
        self.assertEqual(settings['model'],'openai/gpt-oss-20b')

if __name__=='__main__':unittest.main()
