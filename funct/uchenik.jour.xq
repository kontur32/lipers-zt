import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

declare variable $params external;
declare variable $ID external;
declare variable $номерЛичногоДела external;

declare function local:main( $data ){  
  let $tables := $data//table[ row[ 1 ]/cell/text() = $номерЛичногоДела ]
  let $имяУченика := 
    ( $tables/row[ 1 ]/cell[ text() = $номерЛичногоДела ]/@label/data() )[ 1 ]
    
  let $оценкиПоПредметам := 
    stud:записиПоВсемПредметамЗаПериод(
      $tables,
      $номерЛичногоДела,
      xs:date( '2020-01-09' ),
      xs:date( '2020-03-23' )
    )  
    
  let $result := 
    <div>
      <p>Журнал успеваемости ученика: { $имяУченика }</p>
      <p><center>Текущие оценки за четверть</center></p>
        <table width="100%" border='1'>
          <tr> 
             <th width="33%">Предмет</th>
             <th width="33%">Текущие оценки</th>
             <th>Средний балл</th>
          </tr>
          {
            for $i in $оценкиПоПредметам[ position() >= 2 ]
            let $оценки := $i?2?2[ number( . ) >0 ]
            return
              <tr>
                <td>{ $i?1 }</td>
                <td>{ string-join( $i?2?2, ', ' ) }</td>
                <td>средний балл: { round( avg( $оценки ), 1 ) }</td>
              </tr>
          }
      </table>
      
   <p><center>Оценки за четверть и год</center></p>
   <table width="100%" border='1'>
     <tr>
           <th width="20%">Предмет</th>
           <th width="10%">Четверть I</th>
           <th width="10%">Четверть II</th>
           <th width="10%">Четверть III</th>
           <th width="10%">Четверть IV</th>
           <th width="10%">Год</th>
        </tr>
     {
      for $p in stud:промежуточнаяАттестацияУченика( $tables, $номерЛичногоДела )
      return 
         <tr> 
           <td> { $p?1 } </td>
           <td> { $p?2[ 1 ] } </td>
           <td> { $p?2[ 2 ] } </td>
           <td> { $p?2[ 3 ] } </td>
           <td> { $p?2[ 4 ] } </td>
           <td> { $p?2[ 5 ] } </td>
         </tr>
      }
    </table>
    </div>
  return
    $result
};

if( $номерЛичногоДела )
then(
  local:main( . )
)
else(
  <p>Надо авторизоваться</p>
)