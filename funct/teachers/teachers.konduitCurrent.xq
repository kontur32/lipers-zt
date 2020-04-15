import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

declare function local:dateParseComa( $date as xs:string )  as xs:date {
  xs:date( replace( $date, '(\d{2}).(\d{2}).(\d{4})', '$3-$2-$1') )
};

declare function local:dateParseExcel( $date as xs:integer )  as xs:date {
  xs:date( "1900-01-01" ) + xs:dayTimeDuration("P" || $date - 2 || "D")
};

declare function local:dateParse( $date as xs:string ){
  if( matches( $date, '^\d{2,2}.\d{2}.\d{4}$') )
  then(
    local:dateParseComa( $date )
  )
  else(
    if( try{ xs:integer( $date ) }catch*{ false() } )
    then(
      local:dateParseExcel( xs:integer( $date ) )
    )
    else( false() )
  )
};

declare variable $params external;
declare variable $ID external;
declare variable $должность external;
declare variable $date external;

let $data := ./file/table

let $host := 'http://' || request:hostname() || ':' || request:port() 

let $date := $params?date

let $результат :=
  for $ученик in stud:ученики( $data )
  let $пропуски := 
     stud:количествоПропусковПоПредметам(
       $data,
       $ученик?1,
       xs:date( current-date() ),
       xs:date( current-date() )
     )
  where not( empty( $пропуски ) ) and not( empty( $ученик?2 ) )
  order by $ученик?2
  order by number( $ученик?3 )
  let $пропускиПоПредметам := 
    for-each( $пропуски, function( $v ){ $v?1 || ' - ' || $v?2 } )
  return
    <div><p> { $ученик?2 } ({ $ученик?3 }): { string-join( $пропускиПоПредметам, ', ' ) }</p></div>

let $actionURL := 
        $host || '/zapolnititul/api/v2.1/data/publication/' || $ID   
    
return 
  <div>
    <b><center>Количество пропусков уроков за день ({current-date()})</center></b>
    { $результат }
  </div>