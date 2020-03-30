module namespace stud = 'lipers/modules/student';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare
  %public 
function 
stud:записиЗаПериод(
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

declare
  %public 
function 
stud:записиПоВсемПредметамЗаПериод(
  $data as element( table )*,
  $идентификаторУченика as xs:string,
  $начальнаяДата as xs:date,
  $конечнаяДата as xs:date
)
  as item()*
{
  for $i in $data[ row[1]/cell/text() = $идентификаторУченика ]
  return
    [
      $i/row[1]/cell[1]/@label/substring-before( data(), ',' ),
      stud:записиЗаПериод( $i, $идентификаторУченика, $начальнаяДата, $конечнаяДата )
    ]
};