import module namespace stud = 'lipers/modules/student' 
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';

declare variable $params external;
declare variable $ID external;
declare variable $номерЛичногоДела external;

declare
  %private
function 
  local:оценкиПоПредметамИтоговые(
     $tables as element( table )*,
     $идентификакторУченика as xs:string
  )
{
  for $i in $tables
    let $имяУченикаТекущее := $i/row[ 1 ]/cell[ text() = $идентификакторУченика ]/@label/data()
    let $предмет := 
      normalize-space( tokenize( $i/row[ 1 ]/cell[ 1 ]/@label/data(), ',' )[ 1 ] )
    order by $предмет
    return
     let $оценкиИтоговые1 := 
        $i/row[ position() = 2 ]/cell[ @label = $имяУченикаТекущее ]/text()
     let $оценкиИтоговые2 := 
        $i/row[ position() = 3 ]/cell[ @label = $имяУченикаТекущее ]/text()
     let $оценкиИтоговые3 := 
        $i/row[ position() = 4 ]/cell[ @label = $имяУченикаТекущее ]/text()
     let $оценкиИтоговые4 := 
        $i/row[ position() = 5 ]/cell[ @label = $имяУченикаТекущее ]/text()
     let $оценкиГодовые := 
        $i/row[ position() = 6 ]/cell[ @label = $имяУченикаТекущее ]/text()  
     return
        [ $предмет, $оценкиИтоговые1, $оценкиИтоговые2, $оценкиИтоговые3, $оценкиИтоговые4, $оценкиГодовые ]
};

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
    
  let $оценкиПоПредметамИтоговые := 
    local:оценкиПоПредметамИтоговые( $tables, $номерЛичногоДела )
    
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
       <tr>{
         for $p in $оценкиПоПредметамИтоговые[ position() = 1 ]
         return
           (
             <th width="20%"> { $p?1 } </th>,
             <th width="10%"> { $p?2 } </th>,
             <th width="10%"> { $p?3 } </th>,
             <th width="10%"> { $p?4 } </th>,
             <th width="10%"> { $p?5 } </th>,
             <th width="10%"> { $p?6 } </th>
           )
       }</tr>
       {
        for $p in $оценкиПоПредметамИтоговые[ position() >= 2 ]
        return 
           <tr> 
             <td> { $p?1 } </td>
             <td> { $p?2 } </td>
             <td> { $p?3 } </td>
             <td> { $p?4 } </td>
             <td> { $p?5 } </td>
             <td> { $p?6 } </td>
           </tr>
        }
        </table>
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
      for $p in stud:промежуточнаяАттестацияУченика( $data, $номерЛичногоДела )
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