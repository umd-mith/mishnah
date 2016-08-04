declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: Switch to JSON serialization :)
declare option output:method "text";
declare option output:media-type "text/javascript";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
let $json := transform:transform($input, doc("//exist/apps/digitalmishnah/xsl/extractTokensJson.xsl"), 
                <parameters>
                   <param name="tei-loc" value="{$config:http-data-root}/mishnah/"/>
                   <param name="mcite" value="{request:get-parameter("mcite", '')}"/>
                </parameters>)
return $json