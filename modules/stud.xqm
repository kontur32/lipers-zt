module namespace stud = 'lipers/modules/student';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function stud:date( $date as xs:string ) as xs:date* {
  if( matches( $date, '\d{2}.\d{2}.\d{4}$' ) )
  then(
    dateTime:dateParseComaSeparate( $date )
  )
  else(
    if( matches( $date, '\d{5}' ) )
    then(
       dateTime:dateParseExcel( xs:integer( $date ) )
    )
    else(
      if( matches( $date, '\d{4}-\d{2}-\d{2}$' ))
      then( xs:date( $date ) )
      else( xs:date( '1974-10-28') )
    )
  )
};

(:~
 : Возвращает список учеников из массива журналов
 : @param  $данные  данные журналов по предметам
 : @return неименованный массив [ идентификатор, ФИО, класс ]
 :)
declare
  %public
function stud:ученики( $данные as element( table )* ){ 
  let $журналыПоПредметам := 
    $данные/row[ 1 ][ not ( matches( cell[ 1 ]/@label/data(), '!' ) ) ][ text() ]
    
  let $идентификаторы := 
    distinct-values( $журналыПоПредметам/cell[ position() >= 3 ]/text() )
    
  for $i in $идентификаторы
  let $a := $журналыПоПредметам/cell
  let $класс := 
    substring-after(
      $журналыПоПредметам[ cell[ text() = $i ] ][ 1 ]/cell[ 1 ]/@label/data(), ',' 
    )
  return 
    [
      normalize-space( $i ),
      normalize-space( $a[ text() = $i ][ 1 ]/@label/data() ),
      normalize-space( $класс )
    ]
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

(:~
 : Возвращает записи журналов по всем предметам по ученику за период
 : @param  $данные  данные журналов по предметам
 : @param  $ученик идентификатор ученик
 : @param  $начальнаДата начальная дата
 : @param  $конечнаяДата конечная дата
 : @return неименованный массив [ 'предмет', ( множество( записи журнала ) ) ]
 :)
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
  let $предмет :=
    normalize-space( tokenize(  $i/row[ 1 ]/cell[ 1 ]/@label/data(), ',' )[ 1 ] )
  order by $предмет
  return
    [
      $предмет,
      stud:записиЗаПериод( $i, $идентификаторУченика, $начальнаяДата, $конечнаяДата )
    ]
};


(:~
 : Возвращает количество пропусков по всем предметам по ученику за период
 : @param  $данные  данные журналов по предметам
 : @param  $идентификаторУченика идентификатор ученик
 : @param  $начальнаДата начальная дата
 : @param  $конечнаяДата конечная дата
 : @return неименованный массив [ 'предмет', количествоПропусков ]
 :)
declare 
  %public
function stud:количествоПропусковПоПредметам(
    $данные as element( table )*,
    $идентификаторУченика as xs:string,
    $начальнаДата as xs:date,
    $конечнаяДата as xs:date
  ){
  let $записиПоПредметам := 
    stud:записиПоВсемПредметамЗаПериод(
      $данные, $идентификаторУченика, $начальнаДата, $конечнаяДата
    )
  
  for $поПредмету in $записиПоПредметам
  let $предмет := $поПредмету?1
  let $количествоПропусков := count( $поПредмету?2[ ?2 = 'н' ] )
  where $количествоПропусков > 0
  return
        [ $предмет, $количествоПропусков ]
};


(:~
 : Возвращает итоги промежуточной аттестации по ученику по всем предметам
 : @param  $данные  данные журналов по предметам
 : @param  $идентификаторУченика идентификатор ученик
 : @return множество неименованных массивов ["Литература", ("4", "4", "3", "", "")] ["Русский язык", ("3", "4", "3", "", "")]
 :)
declare
  %public 
function
  stud:промежуточнаяАттестацияУченика(
     $данные as element( table )*,
     $идентификаторУченика as xs:string
   )
{
  let $table := $данные[ row[ 1 ]/cell[ text() = $идентификаторУченика ] ]
  
  let $имяУченика :=  $table/row[ 1 ]/cell[ text() = $идентификаторУченика ]/@label/data()
   
  for $i in $table
  let $предмет := tokenize( $i/row[ 1 ]/cell[ 1 ]/@label/data(), ',' )[ 1 ]
  where not ( matches( $предмет, '!' ) )
  order by $предмет  
  return
    [ $предмет, $i/row[ position() = ( 2 to 6 ) ]/cell[ @label = $имяУченика ]/data() ]
};

(:~
 : Возвращает итоги промежуточной аттестации по ученику по предмету
 : @param  $данные  данные журналов по предметам
 : @param  $идентификаторУченика идентификатор ученик
 : @return множество неименованных массивов ["Русский язык", (3, 4, 3, "0", "0")]
:)
declare 
  %private
function stud:ОценкиПромежуточнойАттестацииПоУченикуПоПредмету (
    $data as element( table ),
    $идентификаторУченика as xs:string
)
{
  let $ФИОУченика :=
    stud:ученики( $data )[ ?1 = $идентификаторУченика ]?2
  let $записиПоУченику := 
    $data/row[ position() = 2 to 6 ]/cell[ @label = $ФИОУченика ]
  for $i in $записиПоУченику
  return
    if( $i/text() != "" )then( $i/text() )else( '0' )
};

declare
  %public
function stud:ОценкиПромежуточнойАттестацииПоУченикуПоПредметам(
  $data as element( table )*,
  $идентификаторУченика as xs:string
)
{
  for $i in $data
  let $предмет := $i/row[ 1 ]/cell[ 1 ]/@label/substring-before( data(), ',' )
  let $оценки := 
    stud:ОценкиПромежуточнойАттестацииПоУченикуПоПредмету( $i, $идентификаторУченика )
  where not( empty( $оценки ) )
  return
    [ $предмет, $оценки ]
};