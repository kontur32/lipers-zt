import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

declare variable $params external;
declare variable $ID external;
declare variable $должность external;

declare function local:ученики( $data as element( table )* ){
   let $журналыПоПредметам := 
    $data/row[ 1 ][ not ( matches( cell[ 1 ]/@label/data(), '!' ) ) ]/cell[ position() >= 3 ][ text() ]

    for $i in distinct-values( $журналыПоПредметам/text() )
    return 
      [ $i, $журналыПоПредметам[ text() = $i ][ 1 ]/@label/data() ]
};

let $data := ./file/table

let $результат :=
  for $i in local:ученики( $data )
  let $пропуски := 
     stud:количествоПропусковПоПредметам( $data, $i?1, xs:date( '2020-03-30' ), xs:date( '2020-05-30' ) )
  where not( empty( $пропуски ) ) and not( empty( $i?2 ) )
  return
    <div><p> { $i?2 } { [ $пропуски  ] }</p></div>

return 
  <div><b><center>Общее количество пропусков за четверть</center></b>
    { $результат }
  </div>