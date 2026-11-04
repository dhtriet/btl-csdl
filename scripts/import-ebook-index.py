"""Match a private prebuilt index to the deployed catalog and PDF bytes."""
import hashlib
import json
import os
from pathlib import Path
import sqlite3

root = Path(__file__).resolve().parents[1]
directory = root / 'storage' / 'assistant'
candidate = directory / 'restored-books.sqlite'
manifest = directory / 'restored-index-manifest.json'
if not candidate.exists() or not manifest.exists():
    raise SystemExit(1)
catalog = json.loads((root/'storage/assistant-manifest.json').read_text())
sources = json.loads(manifest.read_text())
targets = {Path(book.get('file_path') or '').name: int(book['id']) for book in catalog if book.get('file_path')}
mapping = {}
for source in sources:
    path = root/'storage/ebooks'/source['filename']
    if source['filename'] not in targets or not path.is_file():
        continue
    if hashlib.sha256(path.read_bytes()).hexdigest() != source['sha256']:
        raise SystemExit('Prebuilt PDF index does not match restored PDF')
    stat = path.stat()
    mapping[int(source['id'])] = (targets[source['filename']], f'{stat.st_size}:{stat.st_mtime_ns}')
with sqlite3.connect(candidate) as conn:
    conn.execute('PRAGMA trusted_schema=OFF')
    for (old_id,) in conn.execute('SELECT id FROM books').fetchall():
        if old_id not in mapping:
            conn.execute('DELETE FROM chunks WHERE book_id=?', (old_id,))
            conn.execute('DELETE FROM books WHERE id=?', (old_id,))
        else:
            conn.execute('UPDATE books SET id=? WHERE id=?', (-old_id, old_id))
            conn.execute('UPDATE chunks SET book_id=? WHERE book_id=?', (-old_id, old_id))
    for old_id, (new_id, fingerprint) in mapping.items():
        conn.execute('UPDATE books SET id=?,fingerprint=? WHERE id=?', (new_id, fingerprint, -old_id))
        conn.execute('UPDATE chunks SET book_id=? WHERE book_id=?', (new_id, -old_id))
os.replace(candidate, directory/'books.sqlite')
print(f'Imported index for {len(mapping)} PDFs')
