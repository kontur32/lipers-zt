module namespace stud = 'lipers/modules/student';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare 
function 
stud:оценкиУченикаПоПредметуЗаПериод(
  $data as element( table ),
  $идентификаторУченика as xs:string,
  $начальнаяДата as xs:date,
  $конечнаяДата as xs:date
)
  as item()*
{
  let $имяУченика :=  $data/row[1]/cell[ text() = $идентификаторУченика ]/@label/data()
  let $урокиСОценками :=
    $data/row[ position() >= 7 ]
    [ dateTime:dateParseExcel( cell[1]/text() ) >= $начальнаяДата ]
    [ dateTime:dateParseExcel( cell[1]/text() ) <= $конечнаяДата ]
    [ cell[ @label = $имяУченика ]/text() ]
  for $i in $урокиСОценками
  return
    [
      string( dateTime:dateParseExcel( $i/cell[ 1 ]/text() ) ),
      $i/cell[ @label = $имяУченика ]/text()
    ]
};