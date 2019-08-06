xquery version "1.0";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0"; 

let $ch:= request:get-parameter('ch', '')

let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))

let $div3 := $input//tei:div3/id(concat('ref.',$ch))
let $n := $div3/ancestor::tei:div2/@n

return 
    element {fn:QName("http://www.tei-c.org/ns/1.0", "div3")} {
        attribute n {concat(if ($n) then $n/data() else 'Unknown', ' ', replace($div3/@xml:id/data(), '^.*?\.(\d+)$', '$1'))},
        $div3/@*,
        $div3/node()
    }