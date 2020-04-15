import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

declare variable $params external;
declare variable $ID external;
declare variable $должность external;

declare function local:списокПропусковЗаПериод( $data, $начальнаяДата, $конечнаяДата ){
  let $ученики := stud:ученики( $data ) (: получает список учеников из журналов :)
  for $ученик in $ученики
  let $пропуски := 
     stud:количествоПропусковПоПредметам( (: получает все записи журанала по ученику за период :)
       $data,
       $ученик?1,
       $начальнаяДата,
       $конечнаяДата
     )
  where not( empty( $пропуски ) ) and not( empty( $ученик?2 ) )
  order by $ученик?2 (: сортировка по фамилии :)
  order by number( $ученик?3 ) (: сортировка по классу :)
  let $пропускиПоПредметам := (: формирует строку с записями о пропусках по предметам :)
    for-each( $пропуски, function( $v ){ $v?1 || ' - ' || $v?2 } )
  return
    <div>
      <p>{ $ученик?2 } (ЛД: { $ученик?1 }, класс: { $ученик?3 }): { string-join( $пропускиПоПредметам, ', ' ) }</p>
    </div>
};

let $data := ./file/table

let $date :=
  if( matches( $params?date, '^\d{4}-\d{2}-\d{2}$') )
  then( xs:date( $params?date ) )
  else( current-date() )
let $host := 'http://' || request:hostname() || ':' || request:port() 
let $actionURL := 
        $host || '/zapolnititul/api/v2.1/data/publication/' || $ID   
let $dateForm := tokenize( xs:string( $date ), '\+' )[1]

return 
  <div>
    <div>
      <div>
        <form action="{ $actionURL }">
          <input type="date" name="date" value="{ $dateForm }"/>
          <input type="hidden" name="page" value="{ $params?page }"/>
          <input type="submit" value="Выбрать дату"/>
        </form>
      </div>
      <b><center>Количество пропусков уроков за день ({ $dateForm })</center></b>
      {
        local:списокПропусковЗаПериод( 
            $data, $date, $date
          )
      }
    </div>
    
    <b><center>Общее количество пропусков за четверть</center></b>
    {
      local:списокПропусковЗаПериод( 
        $data, xs:date( '2020-03-30' ), xs:date( '2020-05-30' )
      )
    }
  </div>