import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

declare variable $params external;
declare variable $ID external;
declare variable $должность external;

let $data := ./file/table

let $date :=
  if( matches( $params?date, '^\d{4}-\d{2}-\d{2}$') )
  then( xs:date( $params?date ) )
  else( current-date() )

let $результат :=
  for $ученик in stud:ученики( $data )
  let $пропуски := 
     stud:количествоПропусковПоПредметам(
       $data,
       $ученик?1,
       xs:date( $date ),
       xs:date( $date )
     )
  where not( empty( $пропуски ) ) and not( empty( $ученик?2 ) )
  order by $ученик?2
  order by number( $ученик?3 )
  let $пропускиПоПредметам := 
    for-each( $пропуски, function( $v ){ $v?1 || ' - ' || $v?2 } )
  return
    <div><p> { $ученик?2 } ({ $ученик?3 }): { string-join( $пропускиПоПредметам, ', ' ) }</p></div>

let $host := 'http://' || request:hostname() || ':' || request:port() 
let $actionURL := 
        $host || '/zapolnititul/api/v2.1/data/publication/' || $ID   
let $dateForm := tokenize( xs:string( $date ), '\+' )[ 1 ] 

return 
  <div>
    <div>
      <form action="{ $actionURL }">
        <input type="date" name="date" value="{ $dateForm }"/>
        <input type="hidden" name="page" value="{ $params?page }"/>
        <input type="submit" value="Выбрать дату"/>
      </form>
    </div>
    <b><center>Количество пропусков уроков за день ({ $dateForm })</center></b>
    { $результат }
  </div>