xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace my="local-functions.uri";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace app="http://www.digitalmishnah.org/templates" at "app.xql";

let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
let $tract-compos := app:index-compos()
for $listWit in $input//tei:listWit[parent::tei:listWit]
return 
    if (some $s in $listWit//tei:witness/@xml:id satisfies some $p in $tract-compos//my:ch-compos//my:wit-compos/text() satisfies $p = $s)
    then map {"key": "value"}
    else ()
(:let $json := transform:transform($input, doc("//exist/apps/digitalmishnah/xsl/extractTokensJson.xsl"), 
                <parameters>
                   <param name="tei-loc" value="{$config:http-data-root}/mishnah/"/>
                   <param name="mcite" value="{request:get-parameter("mcite", '')}"/>
                </parameters>)
return $json:)