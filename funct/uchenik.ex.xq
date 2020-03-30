declare variable $params external;
declare variable $ID external;
declare variable $номерЛичногоДела external;

declare 
  %private
function local:заголовокТаблицы(  $дата )
  as element( td )*
{
  for $i in $дата
  order by $i
  return
    element { "td" } { $i },
    
  element { "td" } { "Средний балл" }
};

let $data := .
  
let $tables := $data//table[ row[ 1 ]/cell/text() = $номерЛичногоДела ]
let $имяУченика := 
  ( $tables/row[ 1 ]/cell[ text() = $номерЛичногоДела ]/@label/data() )[ 1 ]

return
  <p>Здесь будет журнал заданий для ученика: { $имяУченика }</p>