import module namespace tpl = 'tpl' at 'http://iro37.ru/res/repo/templateHtmlTransform.xqm';

declare variable $params external;
declare variable $ID external;

declare function local:авторизация( $params ){
  if( session:get( 'должность' ) )
  then( session:get( 'должность' ) )
  else(
    let $id := 
      fetch:text(
        web:create-url(
          'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/8cfa7a74-7c15-459c-a804-45211aad90f1',
          map{
            'login' : $params?login,
            'password' : $params?password
          }
        )
      )
    return
      if( not( $id = '' ) )then( $id, session:set( 'должность', $id ) )else()
  )
};

let $data := .

let $должность := local:авторизация( $params )

let $xq := 
  if( $params?page != '' )
  then(
    let $url :=
        'http://iro37.ru/res/trac-src/xqueries/lipers/xq/teachers/' || $params?page || '.xq'
    let $result := http:send-request( <http:request method='get'/>, $url )
    return
      if( $result[ 1 ]/@status/data() = '200' )
      then( $result[ 2 ] )
      else( '<p>Такой страницы нет</p>' )
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
  if( session:get( 'должность' ) and not( $params?logout = 'yes' ) )
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
    <form action="/zapolnititul/api/v2.1/data/publication/c5d91950-2b53-4cd1-ac25-bcd75c29d602">
      <p>Введите логин и пароль</p>
      <input type="text" name="login" value=""/>
      <input type="text" name="password" value=""/>
      <input type="hidden" name="page" value="{ $params?page }"/>
      <input type="submit" value="Отправить"/>
    </form>
  )

let $body := 
  if( session:get( 'должность' ) )
  then(
    xquery:eval(
      $xq,
      map{
        'должность' : session:get( 'должность' ),
        'params' : $params,
        'ID' : $ID, '' : .
      }
    )
  )
  else( <p>надо авторизоваться</p> )
  
  
let $параметрыШаблона :=
   map{
     'body' :  $body,
     'header' : 
       tpl:xhtml(
         $шаблонЗаголовка, 
         map{
           'menu' : 
             <div>
               <h1>Личный кабинет сотрудника</h1>
               <a href = "?page=teachers.quality">Качество знаний</a>
               <a href = "?page=teachers.konduit">Пропуски</a>
               <a href = "?page=teachers.others">Всякое-разное</a>
             </div>,
           'loginForm' : $loginForm
         }
       ),
     'footer' : $шаблонПодвала
   }

return
  tpl:xhtml(  $шаблон, $параметрыШаблона )