import module namespace stud = 'lipers/modules/student'
  at 'https://raw.githubusercontent.com/kontur32/lipers-zt/master/modules/stud.xqm';
  
declare variable $params external;
declare variable $ID external;
declare variable $должность external;

declare function local:класс( $data, $class ){
  let $d := $data[ matches( row[ 1 ]/cell[ 1 ]/@label/data(), $class ) ]
  return
  if( $d[1]/row[ 1 ]/cell[ position() >= 3 ]/text() )
  then(
    $d[1]/row[ 1 ]/cell[ position() >= 3 ]/text()
  )
  else(
    local:класс( $data[ position() >= 2 ], $class )
  )
};

let $data :=
  .//table

let $class :=
  if( number( $params?class ) = ( 5 to 11 ) )
  then( $params?class )
  else( 5 )

let $класс := (: идентификаторы учкников класса :)
  $data[ matches( row[ 1 ]/cell[ 1 ]/@label/data(), $class ) ][ 3 ]
    /row[ 1 ]/cell[ position() >= 3 ]/text()

let $класс := local:класс( $data, $class )

let $оценкиУчеников := 
  for $i in stud:ученики( $data )
  where $i?1 = $класс
  return
    [ $i, stud:промежуточнаяАттестацияУченика( $data, $i?1 ) ]

let $предметы := sort( distinct-values( $оценкиУчеников?2?1 ) )

let $промежуткиАттестации := 
  if( $class <= 9 )
  then(
    ( '1-ая четверть', '2-ая четверть', '3-ая четверть', '4-ая четверть', 'Год' )
  )
  else(
    ( '1-ое полугодие', '2-ое полугодие', 'Год' )
  )

let $строки := 
  for $i in $оценкиУчеников
  count $c
  return
    for $промежуток in $промежуткиАттестации
    count $c1
    return
      <tr >
        {
          if( $c1 = 1 )
          then( <td rowspan="{ count( $промежуткиАттестации ) }">{ $i?1?2 }</td> )
          else()
        }
        <td>{ $промежуток }</td>
        {
           for $предмет in $предметы
           return
             <td>{ $i?2[ ?1 = $предмет ]?2[ $c1 ] }</td>
        }
      </tr>
let $таблица := 
  <table border="1px">
    <tr>
      <td>Ученик</td>
      <td>Период</td>
      {
        for $i in $предметы
        return
          <td>{ $i }</td>
      }
    </tr>
    { $строки }
  </table>

return
  <div>
    <h1>Страница с качеством знаний</h1>
    <p>Для пользователя с правами: { $должность }</p>
    {
      let $path := "/zapolnititul/api/v2.1/data/publication/c5d91950-2b53-4cd1-ac25-bcd75c29d602"
      for $i in 5 to 11
      let $href := 
        web:create-url(
          $path,
          map{
            'page' : 'teachers.quality',
            'class' : $i
          }
        )
      return
        <a href = "{ $href }">{ $i } класс</a>
    }
    <h2>Итоги промежуточной аттестации по { $class } классу</h2>
    <div>{ $таблица }</div>
  </div>