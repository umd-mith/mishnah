xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace my="local-functions.uri";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace app="http://www.digitalmishnah.org/templates" at "app.xql";

let $mcite := request:get-parameter('mcite', '')
let $unit := if (count(tokenize($mcite, '\.')) = 4) then "m" 
             else if (count(tokenize($mcite, '\.')) = 3) then "ch"
             else "all"

let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
let $tract-compos := app:index-compos($unit, $mcite)
let $subset := if ($unit = "ch" or $unit = "all") then $tract-compos//my:ch-compos//my:wit-compos/text() 
               else $tract-compos//my:m-active-compos//my:wit-compos/text()
for $listWit in $input//tei:listWit[parent::tei:listWit]
return 
    if (some $s in $listWit//tei:witness/@xml:id satisfies some $p in $subset satisfies $p = $s)
    then  
        for $w in $listWit/tei:witness
        return 
            if (contains($subset, $w/@xml:id)) 
            then data($w/@xml:id)
            else ()
    else ()
    
    (: more complex output (requires 3.1) :)
    (:then map {
        "collection": if ($listWit/@n) then data($listWit/@n) else data($listWit/@xml:id),
        "witnesses": [
            for $w in $listWit/tei:witness
            return 
                if (some $p in $subset satisfies $p = $w/@xml:id) then 
                map {
                    "siglum" : data($w/@xml:id),
                    "title" : normalize-space($w/text()),
                    "file" : data($w/@corresp)
                }
                else ()
        ]
    }:)