<?php
require __DIR__.'/../app/config.php';require __DIR__.'/../app/database.php';$p=Database::connection();foreach(['books','rooms','equipment'] as $t){$rows[$t]=$p->query('SELECT id,'.($t==='books'?'title,cover_image':'name').($t==='rooms'?',room_type':'').' FROM '.$t.' WHERE deleted_at IS NULL')->fetchAll();}echo json_encode($rows,JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT);
