module namespace stud = 'lipers/modules/student';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function stud:date( $date as xs:string ) as xs:date* {
  if( matches( $date, '\d{2}.\d{2}.\d{4}' ) )
  then(
    dateTime:dateParseComaSeparate( $date )
  )
  else(
    if( matches( $date, '\d{5}' ) )
    then(
       dateTime:dateParseExcel( xs:integer( $date ) )
    )
    else( xs:date( '1974-10-28') )
  )
};

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
  let $имяУченика :=  $data/row[ 1 ]/cell[ text() = $идентификаторУченика ]/@label/data()
  let $урокиОтметкиУченика := 
    $data/row[ position() >= 7 ][ cell[ @label = $имяУченика ]/text() ]
  
  for $i in $урокиОтметкиУченика[ cell[ 1 ]/text() != ""  ]
  let $date := stud:date( $i/cell[ 1 ]/text() )
  where not( empty( $date ) )
  where $date >= $начальнаяДата and $date <= $конечнаяДата
  return
    [
      string( stud:date( $i/cell[ 1 ]/text() ) ),
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
  for $i in $data[ row[ 1 ]/cell/text() = $идентификаторУченика ]
  return
    [
      $i/row[ 1 ]/cell[ 1 ]/@label/substring-before( data(), ',' ),
      stud:записиЗаПериод( $i, $идентификаторУченика, $начальнаяДата, $конечнаяДата )
    ]
};