declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace dm = "org.digitalmishnah";

(: Switch to JSON serialization :)
declare option output:method "text";
declare option output:media-type "text/javascript";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";


(:~
 : This templating function generates tables for comparisons and other apparatus
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function dm:getMishnahTksJSON($mcite as xs:string, $wits as item()*){
    let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
    let $wits := if (count($wits) = 0) then 'all' else $wits
    let $json := transform:transform($input, doc("//exist/apps/digitalmishnah/xsl/extractTokensJson.xsl"), 
                    <parameters>
                       <param name="tei-loc" value="{$config:http-data-root}/mishnah/"/>
                       <param name="mcite" value="{$mcite}"/>
                       <param name="wits" value="{$wits}"/>
                    </parameters>)
    return $json
};

dm:getMishnahTksJSON(request:get-parameter("mcite", ''), ())

