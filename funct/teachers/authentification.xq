declare variable $params external;
declare variable $ID external;

let $data := .

let $result :=  $data//row
  [ cell[ @label = 'Логин'] = $params?login and cell[ @label = 'Пароль'] = $params?password ]
  /cell[ @label = 'Должность']/text()
  
return
 $result