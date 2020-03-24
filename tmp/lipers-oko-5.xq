(:~
 : Образовательные результаты.
 :
 : @author Александр Калинин и Сергей Мишуров, Artel 2019-2020, BSD License
 :)

declare default element namespace "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace ss = "urn:schemas-microsoft-com:office:spreadsheet";

declare variable $params external;
declare variable $ID external;
declare variable $rdfData external; 

(:~
 : Создает таблицу "Качество образования по классу".
 : @param  $ученики  строки с данными об успеваемости ученика
 : @param  $видыОценок  возможные оценки (множество)
 : @return html-елемент table
 :)
declare 
  %private
function local:качествоПоКлассу( $ученики as element( Row )*, $видыОценок )
  as element ( table )
{
   element { "table" } {
       attribute { "border" } { "1px" },
       element{ "tr" } {
          element { "td" } { "Класс" },
          local:заголовокТаблицы( $видыОценок )
       },
     
       for $класс in distinct-values( $ученики/Cell[2]/Data/text() )
       let $ученикиКласса := $ученики[ Cell[2]/Data/text() = $класс ]
       let $всеОценкиКласса := $ученикиКласса/Cell[ position() > 2 ]/Data/text()
       return
         element { "tr" }{              
           element { "td" } { $класс },
           local:количествоОценокПоВидам( $всеОценкиКласса, $видыОценок ),
           local:качествоПоКлассу( $ученикиКласса )
         }
     }
};

(:~
 : Создает таблицу "Качество образования по ученикам".
 : @param  $ученики  строки с данными об успеваемости ученика
 : @param  $видыОценок  возможные оценки (множество)
 : @return html-елемент table
 :)
declare 
  %private
function local:качествоПоУченикам( $ученики as element( Row )*, $видыОценок )
  as element ( table )
{
  element {"table"} {
       attribute { "border" } { "1px" },
       element{ "tr" } {
         element { "td" } { "ФИО учащегося" },
         element { "td" } { "Класс" },
         local:заголовокТаблицы( $видыОценок )
       },
       for $r in $ученики
       let $test := 
         if( $params?class )
         then( $r/Cell[2]/Data/text() = $params?class )
         else( true() )
       where $test
       let $оценкиУченика := $r/Cell[ position() > 2 ]/Data/text()
       return
         element { "tr" }{ 
           element { "td" } { $r/Cell [1]/Data/text() } ,
           element { "td" } { $r/Cell [2]/Data/text() } ,
           local:количествоОценокПоВидам( $оценкиУченика, $видыОценок ),
           local:качествоПоУченику( $оценкиУченика )
        }
      }
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
function local:качествоПоУченику( $всеОценки )
  as element( td )*
{
   let $хорошиеОценки := $всеОценки[ . >= 4 ]
   let $положительныеОценки := $всеОценки[ . >= 3 ]
   return
     (
       element{ 'td' }{
         round( sum( $всеОценки ) div count( $всеОценки ), 2 )
       },
       element{ 'td' }{
           round( count( $хорошиеОценки ) div count( $всеОценки ) * 100 )
       },
       element{ 'td' }{
           round( count( $положительныеОценки ) div count( $всеОценки ) * 100 )
       }
   )
};

declare 
  %private
function local:качествоПоКлассу( $ученики )
  as element( td )*
{
   let $успевающиеУченики := $ученики[ not( Cell[ position() > 2 ]/Data/text() = '2' )  ]
   let $всеОценки := $ученики/Cell[ position() > 2 ]/Data/text()
   let $хорошиеОценки := $всеОценки[ . >= 4 ]
   let $положительныеОценки := $всеОценки[ . >= 3 ]
   return
     (
       element{ 'td' }{
         round( sum( $всеОценки ) div count( $всеОценки ), 2 )
       },
       element{ 'td' }{
           round( count( $хорошиеОценки ) div count( $всеОценки ) * 100 )
       },
       element{ 'td' }{
           round( count( $успевающиеУченики ) div count( $ученики ) * 100 )
       }
   )
};

declare 
  %private
function local:заголовокТаблицы( $видыОценок )
  as element( td )*
{
  for $i in  $видыОценок
  order by $i descending
  return
    element { "td" } { "оценок '" || $i || "'" },
    
  element { "td" } { "Средний балл" },
  element { "td" } { "Качество образования" },
  element { "td" } { "Успеваемость" }
};

(: Отчет 4. Сводный отчёт по каждому ученику :)

let $dataRows := .//Worksheet[ @ss:Name = "ОЦЕНКИ" ]/Table/Row[ position() > 1 ]
let $baseURL := '/zapolnititul/api/v2.1/data/public/sources/'
let $видыОценок := ( "2", "3", "4", "5" ) 

let $result3 :=    
     element {"table"} {
       attribute { "border" } { "1px" },
       element{ "tr" } {
         element { "td" } { "Классов всего" },
         local:заголовокТаблицы( $видыОценок )
       },
       let $d := $dataRows 
       let $classes := distinct-values ( $d/Cell[2]/Data/text() )
       return
         element { "tr" }{                     
           element { "td" } { count ( $classes ) },
           for $o in $видыОценок   
           order by $o descending
           return 
             element { "td" }{
               count( $d/Cell[ position() > 2 ]/Data[ text() = $o ])
              },
           
           element { "td" } { round-half-to-even((sum ((sum ((sum (($d/Cell[ position() > 2 ]/Data[ text() = 5 ], $d/Cell[ position() > 2 ]/Data[ text() = 4 ] )), $d/Cell[ position() > 2 ]/Data[ text() = 3 ] )), $d/Cell[ position() > 3 ]/Data[ text() = 2 ] )) div count ($d/Cell[ position() > 2 ]/Data[ text() ] )), 2)  (: Средний балл :) } ,
           element { "td" } { (round-half-to-even((sum ((count($d/Cell[ position() > 2 ]/Data[ text() = 5 ]), count($d/Cell[ position() > 2 ]/Data[ text() = 4 ] ))) div count ($d/Cell[ position() > 2 ]/Data[ text() ] )), 2))*100 (: Качество образования :)} ,
           element { "td" } { (round-half-to-even((sum ((sum ((count($d/Cell[ position() > 2 ]/Data[ text() = 5 ]), count($d/Cell[ position() > 2 ]/Data[ text() = 4 ] ))), count($d/Cell[ position() > 2 ]/Data[ text() = 3 ] ))) div count ($d/Cell[ position() > 2 ]/Data[ text() ] )), 2))*100 (: Успеваемость :)}     
        }
    }

let $menuItems := 
  for $i in distinct-values( $dataRows/Cell[2]/Data/text() )
  let $href := $baseURL || $ID || '/?class=' || $i
  return 
    <a href = '{ $href }'>{ $i }</a>

return
  (
    <rest:response>
        <http:response status="200">
          <http:header name="Content-type" value="text/html"/>
        </http:response>
      </rest:response>,
      <html>
        <link rel="stylesheet" href="http://iro37.ru/res/trac-src/xqueries/saivpds/css/saivpds.css"/>
        <body>
           <h2><b><center>Сводный отчет 2</center></b></h2>
           <div>
             <p><b><center>Качество образования по каждому ученику</center></b></p>
             <p>Выберите класс: { $menuItems } или <a href = '{ $baseURL || $ID  }'>все классы</a></p>
             { local:качествоПоУченикам( $dataRows, $видыОценок ) }
           </div>
           <div>
             <p><b><center>Качество образования по каждому классу</center></b></p>
             <p>
               <a href = 'http://dbx.iro37.ru/zapolnititul/api/v2.1/data/public/sources/11dfcf4d-a9c5-4611-a32f-edba694fb6c5'>Скачать</a>
             </p>
             { local:качествоПоКлассу( $dataRows, $видыОценок ) }
           </div>
           <div>
             <p><b><center>Качество образования по всему Лицею</center></b></p>
              { $result3 }
           </div>
        </body>
      </html>
  )