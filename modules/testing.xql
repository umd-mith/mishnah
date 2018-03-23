xquery version "3.1";

declare namespace cmp="http://www.digitalmishnah.org/templates/compare";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace httpc="http://exist-db.org/xquery/httpclient";
import module namespace content="http://exist-db.org/xquery/contentextraction"
    at "java:org.exist.contentextraction.xquery.ContentExtractionModule";
import module namespace app="http://www.digitalmishnah.org/templates" at "app.xql";
    
import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace dm = "org.digitalmishnah" at "getMishnahTksJSON.xql";
import module namespace ws2j = "http://www.digitalmishnah.org/ws2j" at "w-sep-to-json.xqm";

(:import module namespace console="http://exist-db.org/xquery/console";:)

declare namespace tei="http://www.tei-c.org/ns/1.0"; 

declare function cmp:compare-align-collatex($results as item(), $orderedWits as xs:string*){
    let $wits := $results("witnesses")
    let $table := $results("table")
    return <table class="alignment-table" dir="rtl">{
        for $orderedWit in $orderedWits
        let $wit := array:filter($wits, function($w) {upper-case(substring-before($w, '.xml')) = $orderedWit})
        let $i := index-of($wits, $wit)
        return
            <tr>
                <td class="wit">{$wit}</td>
                {
                    for $j in 1 to array:size($table)
                    return 
                        let $col := $table($j)
                        let $isVariant := 
                            count(distinct-values(
                                for $c in 1 to array:size($col)
                                return if (array:size($col($c))) then $col($c)(1)("t") else ()
                            )) > 1
                        let $data := $col($i)
                            return element td {
                                if (array:size($data) > 0)
                                then ( 
                                    attribute class {if ($isVariant) then 'variant' else 'invariant'},
                                    $data(1)("t")
                                    )
                                else ()
                            }
                } 
            </tr>
    }</table>
};



  let $url := "http://localhost:8080/exist/apps/digitalmishnah/compare/4.1.2.1/S00483,S07326/align"
         let $compare_path_parts := tokenize($url, "/")
         let $mcite := $compare_path_parts[last()-2]
         let $wits := tokenize($compare_path_parts[last()-1], ',')
         let $mode := $compare_path_parts[last()]
        (: dm:getMishnahTksJSON :)
    
    let $input := ws2j:getTokenData($mcite, $wits) 

    (:let $toJson := serialize($input, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>):)
     let $headers := <headers>
                    <header name="Accept" value="application/json"/> 
                    <header name="Content-type" value="application/json"/>
                </headers>
                let $results := parse-json(
                    content:get-metadata-and-content(
                    httpc:post(xs:anyURI('http://54.152.68.192/collatex/collate'), $input, false(), $headers))
                )
      return cmp:compare-align-collatex($results, $wits)


    
