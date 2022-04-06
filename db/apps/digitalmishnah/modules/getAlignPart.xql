xquery version "1.0";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0"; 

let $ch := request:get-parameter('ch', '')

let $alignment := doc(concat($config:data-root, "/standoff/mt_alignment.xml"))

return
   <data>{$alignment//tei:linkGrp[@xml:id=concat('mt.', $ch)]}</data>