import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

import module namespace list = 'lipers/modules/list'at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/list.xqm';
  
import module namespace jour = 'jour' at 'http://iro37.ru/res/trac-src/xqueries/lipers/modules/jour.xqm';

import module namespace tpl = 'tpl' at 'http://iro37.ru/res/repo/templateHtmlTransform.xqm';

declare variable $params external;
declare variable $ID external;
declare variable $должность external;
declare variable $номерЛичногоДела external;
declare variable $data external;

declare function local:b( $data, $личноеДелоУченика, $начальнаяДата, $конечнаяДата ){
  for $i in stud:записиПоВсемПредметамЗаПериод( $data, $личноеДелоУченика, $начальнаяДата, $конечнаяДата )
  where $i?2?2 = 'н'
  let $a:= [ $i?1, $i?2[ ?2 = 'н' ], count( $i?2[ ?2 = 'н' ] ) ]
  return
        [ $a?1, $a?3 ]
};
let $c :=
let $data := ./file/table

let $журналыПоПредметам := 
  $data/row[ 1 ][ not ( matches( cell [1]/@label/data(), '!' ) ) ]/cell[ position() >= 3 ][ text() ]

let $ученики :=
  for $i in distinct-values( $журналыПоПредметам/text() )
  return 
    [ $i, $журналыПоПредметам[ text() = $i ][ 1 ]/@label/data() ]

for $i in $ученики
let $пропуски := local:b( $data, $i?1, xs:date( '2020-03-30' ), xs:date( '2020-05-30' ) )
where not( empty( $пропуски ) ) and not( empty( $i?2 ) )
return
<div><p> {$i?2} { [ $пропуски  ] }</p>
</div>
return 
<div><b><center>Общее количество пропусков за четверть</center></b>
{$c}
</div>

  
  
  





