module namespace list = 'lipers/modules/list';

declare 
  %private
function 
list:списокУникальныхЗначений(
   $данные as element( file )*,
   $порядок as xs:integer
){
  let $объекты :=
    for $i in $данные/table/row[ 1 ]/cell[ 1 ]/@label
      let $объект := tokenize( $i, ',' )[ $порядок]
      order by number( $объект )
      return
        normalize-space( $объект )
     return
       distinct-values( $объекты )
};

declare 
  %public
function list:списокПредметов( $данные as element( file )* ){
   list:списокУникальныхЗначений( $данные, 1 )
};

declare
  %public
function list:списокКлассов( $данные as element( file )* ){
   list:списокУникальныхЗначений( $данные, 2 )
};

declare
  %public
function list:списокУчеников( $данные as element( file )* ){
    let $ученики := 
        $данные/table/row[ 1 ]/cell[ position() >= 2 ][ text() ]
    let $идентификаторыУчеников :=  distinct-values( $ученики/text() )
    for $i in $идентификаторыУчеников
    return
      [ $i,
        $ученики[ normalize-space( text() ) = normalize-space( $i ) ][ 1 ]/@label/data()
      ]
};