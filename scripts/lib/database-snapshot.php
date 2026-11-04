<?php
declare(strict_types=1);

// Snapshot only writable columns: generated columns must be recomputed on restore.
function database_snapshot(PDO $pdo, string $folder): string
{
    if (!is_dir($folder) && !mkdir($folder,0700,true)) throw new RuntimeException('Cannot create backup folder');
    $path=$folder.'/database.sql';$file=fopen($path,'xb');
    if (!$file) throw new RuntimeException('Cannot create database snapshot');
    $write=static function(string $text) use ($file): void {
        if (fwrite($file,$text)!==strlen($text)) throw new RuntimeException('Incomplete database snapshot');
    };
    try {
        $pdo->exec('SET TRANSACTION ISOLATION LEVEL REPEATABLE READ');$pdo->beginTransaction();
        $write("-- Nexus MySQL snapshot. Restore into an explicitly selected database.\nSET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS=0;\n");
        foreach ($pdo->query("SHOW FULL TABLES WHERE Table_type='BASE TABLE'")->fetchAll(PDO::FETCH_NUM) as [$name]) {
            $table='`'.str_replace('`','``',$name).'`';
            $create=$pdo->query('SHOW CREATE TABLE '.$table)->fetch(PDO::FETCH_NUM)[1];
            $write("DROP TABLE IF EXISTS $table;\n$create;\n");
            $q=$pdo->prepare("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COALESCE(GENERATION_EXPRESSION,'')='' ORDER BY ORDINAL_POSITION");$q->execute([$name]);
            $columns=implode(',',array_map(static fn($column)=>'`'.str_replace('`','``',$column).'`',$q->fetchAll(PDO::FETCH_COLUMN)));
            foreach ($pdo->query("SELECT $columns FROM $table") as $row) {
                $values=implode(',',array_map(static fn($value)=>$value===null?'NULL':$pdo->quote((string)$value),array_values($row)));
                $write("INSERT INTO $table ($columns) VALUES ($values);\n");
            }
        }
        $pdo->commit();$write("SET FOREIGN_KEY_CHECKS=1;\n");
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    } finally {fclose($file);}
    return $path;
}
