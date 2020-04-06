declare variable $params external;
declare variable $ID external;
declare variable $номерЛичногоДела external;

declare 
  %private
function local:заголовокТаблицы( $tables )
  as element( tr )
{
  <tr>
    <th>Четверть</th>
    <th>Всего оценок</th>
    {
      for $i in 2 to 5
      order by $i descending
      return
          <th>оценок { $i }</th>
    }
    <th>Средний балл</th>
    <th>Качество образования</th>
    <th>Успеваемость</th>
   </tr>
};

declare 
  %private
function local:количествоОценокПоВидам( $всеОценки, $видыОценок )
  as element( td )*
{
  for $оценка in $видыОценок
  order by $оценка descending
  return 
    element { "td" } {
     count( $всеОценки[ . = $оценка ] )
    }
};

declare 
  %private
function local:качествоПоКлассу( $всеОценкиЗаЧетверть )
  as element( td )*
{
   let $хорошиеОценки :=  count( $всеОценкиЗаЧетверть[ . >= 4 ] )
   let $положительныеОценки :=  count( $всеОценкиЗаЧетверть[ . >= 3 ] )
   let $количествоОценокЗаЧетверть := count( $всеОценкиЗаЧетверть )
   return
     (
        element{ 'td' }{
         if( $количествоОценокЗаЧетверть )
         then(
           round( sum( $всеОценкиЗаЧетверть ) div $количествоОценокЗаЧетверть, 2 )
         )
         else( 'н/д' )
       },
       element{ 'td' }{
           if( $количествоОценокЗаЧетверть )
           then(
             round( $хорошиеОценки div $количествоОценокЗаЧетверть * 100 )
           )
           else( 'н/д' )
       },
       element{ 'td' }{
         if( $количествоОценокЗаЧетверть )
         then(
           round( $положительныеОценки div $количествоОценокЗаЧетверть * 100 )
         )
         else( 'н/д' )
       }
   )
};

let $видыОценок := ( "2", "3", "4", "5" ) 

let $data := .
  
let $tables := $data//table[ row[ 1 ]/cell/text() = $номерЛичногоДела ]

let $имяУченика := 
  ( $tables/row[ 1 ]/cell[ text() = $номерЛичногоДела ]/@label/data() )[ 1 ]

let $номерЧетверти := 
      $tables[ 1 ]/row[ position() = 2 to 6 ]/cell[ @label = $имяУченика ][ 1 ]/text()

return
  <div>
    <p>Качественные и количественные показатели успеваемости лицеиста: { $имяУченика }</p>
    <table border='1'>
      { local:заголовокТаблицы( $tables ) }
      {
        for $i in 2 to 6
        let $итоговыеОценки := 
          $tables[ position() > 2 ]/row[ position() = $i ]/cell[ @label = $имяУченика ]/text()
        count $c
        return
          <tr>
            <td>{ $номерЧетверти [ $c ] }</td>
            <td>
              { sum ( local:количествоОценокПоВидам( $итоговыеОценки, $видыОценок ) ) }
            </td>
            { local:количествоОценокПоВидам( $итоговыеОценки, $видыОценок ) }
            { local:качествоПоКлассу( $итоговыеОценки ) }
          </tr>
      }
    </table>
  </div>