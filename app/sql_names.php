<?php
declare(strict_types=1);

/** Physical SQL names are Vietnamese; API keys remain stable for existing clients. */
final class SqlNames
{
    public static function mapping(): array
    {
        static $mapping;
        return $mapping ??= json_decode(file_get_contents(dirname(__DIR__).'/database/vietnamese-identifiers.json'),true,512,JSON_THROW_ON_ERROR);
    }

    public static function identifier(string $name): string
    {
        $map=self::mapping();
        return $map['tables'][$name]??$map['columns'][$name]??$name;
    }

    public static function translate(string $sql, bool $metadata=false, ?array $identifiers=null): string
    {
        // Tokenize SQL: never change bound parameters, comments, or stored data values.
        $pattern='~\'(?:\'\'|\\\\.|[^\'\\\\])*\'|"(?:""|\\\\.|[^"\\\\])*"|--[^\r\n]*|\#[^\r\n]*|/\*[\s\S]*?\*/|:[A-Za-z_]\w*|`[^`]+`|\b[A-Za-z_]\w*\b~';
        return preg_replace_callback($pattern,static function(array $match)use($metadata,$identifiers):string {
            $token=$match[0];$first=$token[0];
            $translate=static fn(string $name):string=>$identifiers===null?self::identifier($name):($identifiers[$name]??$name);
            if($first===':' || $first==='/' || $first==='#' || str_starts_with($token,'--'))return $token;
            if($first==='\'' || $first==='"')return $metadata?$first.$translate(substr($token,1,-1)).$first:$token;
            if($first==='`')return '`'.$translate(substr($token,1,-1)).'`';
            return $translate($token);
        },$sql);
    }

    public static function apiRow(mixed $row): mixed
    {
        if(!is_array($row))return $row;
        static $reverse;
        $map=self::mapping();$reverse??=array_flip($map['tables']+$map['columns']);
        $result=[];
        foreach($row as $key=>$value)$result[$reverse[$key]??$key]=$value;
        return $result;
    }
}

final class NexusStatement extends PDOStatement
{
    protected function __construct(private NexusPDO $connection) {}
    private function metadataValue(mixed $value):mixed
    {
        return $this->connection->vietnamese() && stripos($this->queryString,'information_schema.')!==false && is_string($value) ? SqlNames::identifier($value) : $value;
    }
    public function execute(?array $params=null):bool
    {
        return parent::execute($params===null?null:array_map(fn($value)=>$this->metadataValue($value),$params));
    }
    public function bindValue(string|int $param,mixed $value,int $type=PDO::PARAM_STR):bool
    {
        return parent::bindValue($param,$this->metadataValue($value),$type);
    }
    public function fetch(int $mode=PDO::FETCH_DEFAULT,int $cursorOrientation=PDO::FETCH_ORI_NEXT,int $cursorOffset=0):mixed
    {
        return SqlNames::apiRow(parent::fetch($mode,$cursorOrientation,$cursorOffset));
    }
    public function fetchAll(int $mode=PDO::FETCH_DEFAULT,mixed ...$args):array
    {
        $rows=parent::fetchAll($mode,...$args);
        return array_map([SqlNames::class,'apiRow'],$rows);
    }
    public function getIterator():Iterator
    {
        while(($row=$this->fetch())!==false)yield $row;
    }
}

final class NexusPDO extends PDO
{
    private ?bool $translated=null;
    public function vietnamese():bool
    {
        if($this->translated===null){
            $q=parent::query("SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='tai_khoan'");
            $this->translated=(bool)$q->fetchColumn();
        }
        return $this->translated;
    }
    private function sql(string $query):string
    {
        $metadata=stripos($query,'information_schema.')!==false;
        if($this->vietnamese())return SqlNames::translate($query,$metadata);
        $map=SqlNames::mapping();
        return SqlNames::translate($query,$metadata,array_flip($map['tables']+$map['columns']));
    }
    public function prepare(string $query,array $options=[]):PDOStatement|false
    {
        return parent::prepare($this->sql($query),$options);
    }
    public function query(string $query,?int $fetchMode=null,mixed ...$fetchModeArgs):PDOStatement|false
    {
        $query=$this->sql($query);
        return $fetchMode===null?parent::query($query):parent::query($query,$fetchMode,...$fetchModeArgs);
    }
    public function exec(string $statement):int|false
    {
        // A full schema import declares its physical names explicitly.
        $sql=preg_match('/\bCREATE\s+DATABASE\b/i',$statement)?$statement:$this->sql($statement);
        $result=parent::exec($sql);
        if(preg_match('/\b(?:USE|CREATE|ALTER|RENAME|DROP)\b/i',$statement))$this->translated=null;
        return $result;
    }
}
