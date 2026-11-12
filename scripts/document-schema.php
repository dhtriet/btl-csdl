<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli') {http_response_code(404);exit;}
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
$p=Database::connection();
$tables=$p->query("SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME")->fetchAll(PDO::FETCH_COLUMN);
$foreign=$p->query('SELECT TABLE_NAME,COLUMN_NAME,REFERENCED_TABLE_NAME,REFERENCED_COLUMN_NAME,CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL ORDER BY TABLE_NAME,CONSTRAINT_NAME,ORDINAL_POSITION')->fetchAll();
$out="# Lược đồ triển khai Nexus\n\nSinh tự động bằng `php scripts/document-schema.php` từ metadata MySQL; không chứa dữ liệu cá nhân. Nguồn khởi tạo: `database/schema.sql`; CSDL cũ nâng cấp bằng `scripts/migrate-circulation.php --apply` và `scripts/migrate-extension-requests.php --apply`, `scripts/migrate-resource-extensions.php --apply`.\n\nTên bảng/cột vật lý dùng tiếng Việt không dấu; database cũ nâng cấp bằng `php scripts/migrate-vietnamese-schema.php --apply`. Xem [bảng đối chiếu](vietnamese-schema.md).\n\nSố bảng: **".count($tables)."**. Cùng một tập metadata tạo tài liệu này và `database-erd.mmd`; dùng hai tệp này khi cập nhật báo cáo và slide.\n\n";
$diagram="erDiagram\n";
foreach ($tables as $table) {
    $q=$p->prepare('SELECT COLUMN_NAME,COLUMN_TYPE,DATA_TYPE,IS_NULLABLE,COLUMN_KEY,COLUMN_DEFAULT,GENERATION_EXPRESSION FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? ORDER BY ORDINAL_POSITION');$q->execute([$table]);$columns=$q->fetchAll();
    $out.="## `$table`\n\n| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |\n|---|---|---|---|---|\n";
    $diagram.="    $table {\n";
    foreach ($columns as $c) {
        $keys=[];
        if ($c['COLUMN_KEY']==='PRI')$keys[]='PK';
        if ($c['COLUMN_KEY']==='UNI')$keys[]='UK';
        foreach ($foreign as $fk) if ($fk['TABLE_NAME']===$table && $fk['COLUMN_NAME']===$c['COLUMN_NAME']) {$keys[]='FK';break;}
        $value=$c['GENERATION_EXPRESSION']?:($c['COLUMN_DEFAULT']??'—');
        $out.='| `'.$c['COLUMN_NAME'].'` | `'.$c['COLUMN_TYPE'].'` | '.$c['IS_NULLABLE'].' | '.implode(', ',$keys).' | '.str_replace('|','\\|',(string)$value)." |\n";
        $diagram.='        '.$c['DATA_TYPE'].' '.$c['COLUMN_NAME'].($keys?' '.implode(',',$keys):'')."\n";
    }
    $diagram.="    }\n";
    $q=$p->prepare('SELECT tc.CONSTRAINT_NAME,cc.CHECK_CLAUSE FROM information_schema.TABLE_CONSTRAINTS tc JOIN information_schema.CHECK_CONSTRAINTS cc ON cc.CONSTRAINT_SCHEMA=tc.CONSTRAINT_SCHEMA AND cc.CONSTRAINT_NAME=tc.CONSTRAINT_NAME WHERE tc.TABLE_SCHEMA=DATABASE() AND tc.TABLE_NAME=? AND tc.CONSTRAINT_TYPE=\'CHECK\' ORDER BY tc.CONSTRAINT_NAME');$q->execute([$table]);
    foreach ($q as $check) $out.="\n- `{$check['CONSTRAINT_NAME']}`: `{$check['CHECK_CLAUSE']}`\n";
    $out.="\n";
}
$out.="## Liên kết khóa ngoại\n\n| Bảng con / cột | Bảng cha / cột | Ràng buộc |\n|---|---|---|\n";
foreach ($foreign as $fk) {
    $out.="| `{$fk['TABLE_NAME']}.{$fk['COLUMN_NAME']}` | `{$fk['REFERENCED_TABLE_NAME']}.{$fk['REFERENCED_COLUMN_NAME']}` | `{$fk['CONSTRAINT_NAME']}` |\n";
    // Optional child FK has 0..1 parent; all parent entities may have zero children.
    $qnull=$p->prepare('SELECT IS_NULLABLE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?');$qnull->execute([$fk['TABLE_NAME'],$fk['COLUMN_NAME']]);
    $parent=$qnull->fetchColumn()==='YES'?'o|':'||';
    // A single-column unique index establishes 0..1 child; composite PKs do not.
    $unique=$p->prepare('SELECT COUNT(*) FROM (SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND NON_UNIQUE=0 GROUP BY INDEX_NAME HAVING COUNT(*)=1 AND MAX(COLUMN_NAME)=?) u');$unique->execute([$fk['TABLE_NAME'],$fk['COLUMN_NAME']]);
    $child=$unique->fetchColumn()?'o|':'o{';
    $diagram.="    {$fk['REFERENCED_TABLE_NAME']} $parent--$child {$fk['TABLE_NAME']} : {$fk['COLUMN_NAME']}\n";
}
$folder=dirname(__DIR__).'/docs';
file_put_contents($folder.'/database-schema.md',$out);
file_put_contents($folder.'/database-erd.mmd',$diagram);
echo 'Generated schema reference and ERD for '.count($tables).' tables.',PHP_EOL;
