"""Restore private PDF assets on disposable hosting containers."""
import os
from pathlib import Path
import shutil
import tempfile
import urllib.request
import zipfile

url = os.environ.get('NEXUS_EBOOK_BUNDLE_URL', '')
token = os.environ.get('NEXUS_EBOOK_BUNDLE_TOKEN', '')
if not url:
    raise SystemExit(0)
if not url.startswith('https://') or not token:
    raise SystemExit('Private ebook source requires HTTPS and a token')
root = Path(__file__).resolve().parents[1] / 'storage' / 'ebooks'
root.mkdir(parents=True, exist_ok=True)
request = urllib.request.Request(url, headers={'Authorization': 'Bearer ' + token})
with tempfile.TemporaryFile() as archive:
    with urllib.request.urlopen(request, timeout=180) as response:
        shutil.copyfileobj(response, archive)
    archive.seek(0)
    with zipfile.ZipFile(archive) as bundle:
        entries = bundle.infolist()
        if sum(item.file_size for item in entries) > 512 * 1024 * 1024:
            raise SystemExit('Ebook bundle exceeds size limit')
        count = 0
        for item in entries:
            if item.is_dir():
                continue
            name = Path(item.filename).name
            if name == item.filename and name in ('books.sqlite', 'index-manifest.json'):
                index_root = root.parent / 'assistant'
                index_root.mkdir(parents=True, exist_ok=True)
                with bundle.open(item) as source, (index_root / ('restored-' + name)).open('wb') as output:
                    shutil.copyfileobj(source, output)
                continue
            if name != item.filename or not name.lower().endswith('.pdf'):
                raise SystemExit('Invalid ebook bundle entry')
            with bundle.open(item) as source:
                if source.read(5) != b'%PDF-':
                    raise SystemExit('Invalid PDF in ebook bundle')
            target = root / name
            with bundle.open(item) as source, target.open('wb') as output:
                shutil.copyfileobj(source, output)
            target.chmod(0o600)
            count += 1
        print(f'Restored {count} private PDFs')
