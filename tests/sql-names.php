<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/sql_names.php';
$sql="SELECT a.id,a.username FROM accounts a WHERE a.username=:username AND a.role='student' AND a.full_name='books status id' /* accounts.id */ -- due_date\nORDER BY a.id";
$translated=SqlNames::translate($sql);
foreach(['a.ma','a.ten_dang_nhap','FROM tai_khoan',':username',"'student'","'books status id'",'/* accounts.id */','-- due_date'] as $part)if(!str_contains($translated,$part))throw new RuntimeException('SQL token changed incorrectly: '.$part);
$map=SqlNames::mapping();
if(SqlNames::translate($translated,false,array_flip($map['tables']+$map['columns']))!==$sql)throw new RuntimeException('SQL identifier round trip failed');
if(SqlNames::apiRow(['ma'=>3,'ten_dang_nhap'=>'books','trang_thai'=>'borrowed'])!==['id'=>3,'username'=>'books','status'=>'borrowed'])throw new RuntimeException('API keys changed');
if(SqlNames::translate("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_NAME='books'",true)!=="SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_NAME='dau_sach'")throw new RuntimeException('Metadata lookup failed');
echo "Passed SQL identifiers, literals, placeholders, comments, metadata and API key mapping.\n";
