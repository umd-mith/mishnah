xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0"; 
declare namespace dm = "org.digitalmishnah";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace util = "http://exist-db.org/xquery/util";

let $alignment := parse-json(util:binary-to-string(request:get-data()))
let $tosefta := doc(concat($config:data-root, "/tosefta/ref-t.xml"))

return <TEI xmlns="http://www.tei-c.org/ns/1.0">{
    for $i in 1 to array:size($alignment)
    return 
        let $abs := distinct-values(
            let $t := $alignment($i)("t")
            for $i in 1 to array:size($t)
            return $tosefta//id($t($i))/ancestor::tei:ab/@xml:id
        )
        for $ab in $abs
        return $tosefta//id($ab)
}</TEI>
