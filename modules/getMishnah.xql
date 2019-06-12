xquery version "1.0";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0"; 

let $ch:= request:get-parameter('ch', '')

let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))

return
    $input//tei:div3/id(concat('ref.',$ch))