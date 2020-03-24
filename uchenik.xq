import module namespace tpl = 'tpl' at 'http://iro37.ru/res/repo/templateHtmlTransform.xqm';

declare variable $params external;
declare variable $ID external;

declare function local:номерЛичногоДела( $params ){
  if( session:get( 'номерЛичногоДела' ) )
  then( session:get( 'номерЛичногоДела' ) )
  else(
    let $id := 
      fetch:text(
        web:create-url(
          'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/89f04528-a845-4153-9c25-87a35ab466e8',
          map{
            'login' : $params?login,
            'password' : $params?password
          }
        )
      )
    return
      if( not( $id = '' ) )then( $id, session:set( 'номерЛичногоДела', $id ) )else()
  )
};

let $data := .

let $номерЛичногоДела := local:номерЛичногоДела( $params )

let $xq := 
  if( $params?page != '' )
  then(
    try{
      fetch:text(
        'http://iro37.ru/res/trac-src/xqueries/lipers/xq/' || $params?page || '.xq'
    )
    }
    catch*{ '<p></p>' }
  )
  else('<p></p>')

let $actionURL := 
  web:create-url(
    '/zapolnititul/api/v2.1/data/publication/' || $ID,
    map{ 'page' : $params?page }
  )

let $шаблон := 
  fetch:text(
    "http://iro37.ru/res/trac-src/xqueries/lipers/html.tpl/main.tpl.html"
  )

let $шаблонЗаголовка := 
  fetch:text(
    "http://iro37.ru/res/trac-src/xqueries/lipers/html.tpl/header.tpl.html"
  )
   
let $шаблонФормыЛогина := 
  fetch:text(
    "http://iro37.ru/res/trac-src/xqueries/lipers/html.tpl/loginForm.tpl.html"
  )   
   
let $шаблонПодвала := 
  fetch:xml(
    "http://iro37.ru/res/trac-src/xqueries/lipers/html.tpl/footer.tpl.html"
  )

let $loginForm := 
  if( session:get( 'номерЛичногоДела' ) and not( $params?logout = 'yes' ) )
  then(
    let $href := 
      web:create-url(
        "/zapolnititul/api/v2.1/data/publication/" || $ID,
        map{
          'logout' : 'yes',
          'page' : $params?page
        }
      )
    return
      <a href = '{ $href }'>Выйти</a>
  )
  else(
    session:close(),
    <form action="/zapolnititul/api/v2.1/data/publication/66b0e40b-a284-4837-a98d-deda16f644ca">
      <p>Введите логин и пароль</p>
      <input type="text" name="login" value=""/>
      <input type="text" name="password" value=""/>
      <input  type="hidden" name="page" value="{ $params?page }"/>
      <input type="submit" value="Отправить"/>
    </form>
  )

let $body := 
  xquery:eval(
    $xq,
    map{
      'номерЛичногоДела' : session:get( 'номерЛичногоДела' ),
      'params' : $params,
      'ID' : $ID, '' : .
    }
  )
  
let $параметрыШаблона :=
   map{
     'body' :  $body,
     'header' : 
       tpl:xhtml(
         $шаблонЗаголовка, 
         map{
           'menu' : 
             <div>
               <a href = "?page=uchenik.jour">Журнал оценок</a>
               <a href = "?page=uchenik.quality">Успеваемость ученика</a>
               <a href = "?page=uchenik.ex">Журнал индивидуальных заданий</a>
             </div>,
           'loginForm' : $loginForm
         }
       ),
     'footer' : $шаблонПодвала
   }

return
  tpl:xhtml(  $шаблон, $параметрыШаблона )