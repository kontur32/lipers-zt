import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

declare variable $params external;
declare variable $ID external;
declare variable $должность external;

let $data := ./file/table

let $результат :=
  let $ученики := stud:ученики( $data ) (: получает список учеников из журналов :)
  for $ученик in $ученики
  let $пропуски := 
     stud:количествоПропусковПоПредметам( (: получает все записи журанала по ученику за период :)
       $data,
       $ученик?1,
       xs:date( '2020-03-30' ),
       xs:date( '2020-05-30' )
     )
  where not( empty( $пропуски ) ) and not( empty( $ученик?2 ) )
  order by $ученик?2 (: сортировка по фамилии :)
  order by number( $ученик?3 ) (: сортировка по классу :)
  let $пропускиПоПредметам := (: формирует строку с записями о пропусках по предметам :)
    for-each( $пропуски, function( $v ){ $v?1 || ' - ' || $v?2 } )
  return
    <div><p> { $ученик?2 } ({ $ученик?3 }): { string-join( $пропускиПоПредметам, ', ' ) }</p></div>

return 
  <div><b><center>Общее количество пропусков за четверть</center></b>
    { $результат }
  </div>