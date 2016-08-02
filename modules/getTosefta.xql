xquery version "1.0";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0"; 

let $ch := request:get-parameter('ch', '')

let $alignment := doc(concat($config:data-root, "/standoff/mt_alignment.xml"))
let $alignData := <data>{$alignment//tei:linkGrp[@xml:id=concat('mt.', $ch)]}</data>

let $links := 
    for $l in $alignData//tei:linkGrp[@xml:id=concat('mt.', $ch)]/tei:link
    return
        replace($l/@target, '^.*?(ref-t\.\d\.\d\.\d)\..*?$', '$1')
        
(:return 
    for $l in distinct-values($links)
    return
        console:log($l):)

let $input := doc(concat($config:data-root, "/tosefta/ref-t.xml"))
let $fullinput := util:expand($input)

return
   <TEI xmlns="http://www.tei-c.org/ns/1.0">{$fullinput//tei:div3[@xml:id=distinct-values($links)]}</TEI>