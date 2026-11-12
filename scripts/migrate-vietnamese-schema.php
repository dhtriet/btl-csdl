<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/sql_names.php';
require __DIR__.'/lib/database-snapshot.php';
$pdo = new PDO(sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',DB_HOST,DB_PORT,getenv('NEXUS_DB_NAME')?:DB_NAME),DB_USER,DB_PASS,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$mapping=json_decode(file_get_contents(dirname(__DIR__).'/database/vietnamese-identifiers.json'),true,512,JSON_THROW_ON_ERROR);
foreach($argv as $arg){if(str_starts_with($arg,'--table-prefix=')){$prefix=substr($arg,15);if(!preg_match('/^vn_test_[0-9]{6}_$/D',$prefix))throw new RuntimeException('Only an isolated test table prefix is allowed');$mapping['tables']=array_combine(array_map(fn($v)=>$prefix.$v,array_keys($mapping['tables'])),array_map(fn($v)=>$prefix.$v,array_values($mapping['tables'])));}}
$reverse=in_array('--rollback',$argv,true);
if($reverse)foreach($mapping as &$part)$part=array_flip($part);
unset($part);
$expression=static fn(string $sql):string=>str_replace("\\'","'",$sql);
$quote=static fn(string $name):string=>'`'.str_replace('`','``',$name).'`';
$tables=$pdo->query('SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE()')->fetchAll(PDO::FETCH_COLUMN);
$changes=[];$renames=[];$counts=[];$columnCount=0;
$dropCheck=str_contains(strtolower((string)$pdo->getAttribute(PDO::ATTR_SERVER_VERSION)),'mariadb')?'DROP CONSTRAINT':'DROP CHECK';
foreach($mapping['tables'] as $old=>$new){
    $oldExists=in_array($old,$tables,true);$newExists=in_array($new,$tables,true);
    if($oldExists && $newExists)throw new RuntimeException("Both table names exist: $old / $new");
    if(!$oldExists && !$newExists)throw new RuntimeException("Missing table: $old / $new");
    $table=$oldExists?$old:$new;
    $counts[$new]=(int)$pdo->query('SELECT COUNT(*) FROM '.$quote($table))->fetchColumn();
    $q=$pdo->prepare('SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? ORDER BY ORDINAL_POSITION');$q->execute([$table]);$columns=$q->fetchAll(PDO::FETCH_COLUMN);
    $q=$pdo->prepare("SELECT COLUMN_NAME,COLUMN_TYPE,GENERATION_EXPRESSION,EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COALESCE(GENERATION_EXPRESSION,'')<>''");$q->execute([$table]);$generated=$q->fetchAll();$generatedNames=array_column($generated,'COLUMN_NAME');
    $columnCount+=count(array_intersect(array_keys($mapping['columns']),$columns));
    $clauses=[];
    foreach($mapping['columns'] as $from=>$to){
        if(!in_array($from,$columns,true)||in_array($from,$generatedNames,true))continue;
        if(in_array($to,$columns,true))throw new RuntimeException("Both column names exist: $table.$from / $to");
        $clauses[]='RENAME COLUMN '.$quote($from).' TO '.$quote($to);
    }
    if($clauses){
        $q=$pdo->prepare("SELECT tc.CONSTRAINT_NAME,cc.CHECK_CLAUSE FROM information_schema.TABLE_CONSTRAINTS tc JOIN information_schema.CHECK_CONSTRAINTS cc ON cc.CONSTRAINT_SCHEMA=tc.CONSTRAINT_SCHEMA AND cc.CONSTRAINT_NAME=tc.CONSTRAINT_NAME WHERE tc.TABLE_SCHEMA=DATABASE() AND tc.TABLE_NAME=? AND tc.CONSTRAINT_TYPE='CHECK'");$q->execute([$table]);$checks=$q->fetchAll();
        $drops=[];$adds=[];
        foreach($checks as $check){$drops[]=$dropCheck.' '.$quote($check['CONSTRAINT_NAME']);$adds[]='ADD CONSTRAINT '.$quote($check['CONSTRAINT_NAME']).' CHECK ('.SqlNames::translate($expression($check['CHECK_CLAUSE']),false,$mapping['columns']).')';}
        $generatedAdds=[];
        foreach($generated as $g){
            $drops[]='DROP COLUMN '.$quote($g['COLUMN_NAME']);
            $generatedAdds[]='ADD COLUMN '.$quote($mapping['columns'][$g['COLUMN_NAME']]??$g['COLUMN_NAME']).' '.$g['COLUMN_TYPE'].' GENERATED ALWAYS AS ('.SqlNames::translate($expression($g['GENERATION_EXPRESSION']),false,$mapping['columns']).') '.(str_contains($g['EXTRA'],'STORED')?'STORED':'VIRTUAL');
        }
        $q=$pdo->prepare('SELECT INDEX_NAME,COLUMN_NAME,NON_UNIQUE,SEQ_IN_INDEX FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? ORDER BY INDEX_NAME,SEQ_IN_INDEX');$q->execute([$table]);$indexes=[];
        foreach($q as $index)$indexes[$index['INDEX_NAME']][]=$index;
        foreach($indexes as $name=>$parts){if(!array_intersect(array_column($parts,'COLUMN_NAME'),$generatedNames))continue;if(count($parts)!==1)throw new RuntimeException('Composite generated index needs explicit migration');$generatedAdds[]='ADD '.($parts[0]['NON_UNIQUE']?'':'UNIQUE ').'KEY '.$quote($name).' ('.$quote($mapping['columns'][$parts[0]['COLUMN_NAME']]??$parts[0]['COLUMN_NAME']).')';}
        $changes[]=['table'=>$table,'generated'=>$generatedAdds?'ALTER TABLE '.$quote($table).' '.implode(', ',$generatedAdds):null,'rename'=>'ALTER TABLE '.$quote($table).' '.implode(', ',$clauses).', ALGORITHM=INPLACE','drop'=>$drops?'ALTER TABLE '.$quote($table).' '.implode(', ',$drops):null,'add'=>$adds?'ALTER TABLE '.$quote($table).' '.implode(', ',$adds):null,'checks'=>$checks];
    }
    if($oldExists)$renames[]=$quote($old).' TO '.$quote($new);
}
if(!in_array('--apply',$argv,true)){
    echo json_encode(['direction'=>$reverse?'english':'vietnamese','columns_to_rename'=>$columnCount,'tables_to_rename'=>count($renames)],JSON_PRETTY_PRINT),PHP_EOL;exit;
}
if(!$changes && !$renames){echo "Schema names already up to date.\n";exit;}
$backup=database_snapshot($pdo,dirname(__DIR__,2).'/resource-center-backups/vietnamese-schema-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)));
file_put_contents(dirname($backup).'/rename-plan.json',json_encode($changes,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE));
foreach($changes as $change){
    if($change['drop'])$pdo->exec($change['drop']);
    try{$pdo->exec($change['rename']);if($change['generated'])$pdo->exec($change['generated']);if($change['add'])$pdo->exec($change['add']);}
    catch(Throwable $error){
        // Restore checks using whichever column names exist after the failed DDL.
        $q=$pdo->prepare('SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?');$q->execute([$change['table']]);$actual=$q->fetchAll(PDO::FETCH_COLUMN);$available=[];
        foreach($mapping['columns'] as $from=>$to)$available[$from]=in_array($to,$actual,true)?$to:$from;
        foreach($change['checks'] as $check){try{$pdo->exec('ALTER TABLE '.$quote($change['table']).' ADD CONSTRAINT '.$quote($check['CONSTRAINT_NAME']).' CHECK ('.SqlNames::translate($expression($check['CHECK_CLAUSE']),false,$available).')');}catch(Throwable $restore){fwrite(STDERR,'Review constraint '.$check['CONSTRAINT_NAME'].' using backup '.$backup.PHP_EOL);}}
        throw $error;
    }
}
if($renames)$pdo->exec('RENAME TABLE '.implode(', ',$renames));
foreach($counts as $table=>$expected){$actual=(int)$pdo->query('SELECT COUNT(*) FROM '.$quote($table))->fetchColumn();if($actual!==$expected)throw new RuntimeException("Row count changed: $table");}
echo json_encode(['direction'=>$reverse?'english':'vietnamese','renamed_columns'=>$columnCount,'renamed_tables'=>count($renames),'row_counts'=>'preserved','backup'=>$backup],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
