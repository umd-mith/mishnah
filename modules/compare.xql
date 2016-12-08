xquery version "3.1";

module namespace cmp="http://www.digitalmishnah.org/templates/compare";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace httpc="http://exist-db.org/xquery/httpclient";
import module namespace content="http://exist-db.org/xquery/contentextraction"
    at "java:org.exist.contentextraction.xquery.ContentExtractionModule";
    
import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace dm = "org.digitalmishnah" at "getMishnahTksJSON.xql";

(:import module namespace console="http://exist-db.org/xquery/console";:)

declare namespace tei="http://www.tei-c.org/ns/1.0"; 

(:~
 : This templating function generates tables for comparisons and other apparatus
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function cmp:compare-view($node as node(), $model as map(*)){
    if (not($model("path") = "/compare"))
    then 
        let $compare_path_parts := tokenize($model("path"), "/")
        let $mcite := $compare_path_parts[last()-2]
        let $wits := tokenize($compare_path_parts[last()-1], ',')
        let $mode := $compare_path_parts[last()]
        
        (: Determine whether there is a curated collation for this mcite :)
        let $collation := concat($config:data-root, "/mishnah/collations/", $mcite, ".xml")
        let $coll_available := doc-available($collation)
        
        return 
            if ($coll_available)
            then cmp:compare-align($collation, $mcite, $wits) 
            else 
                (: Use Collatex :)
                let $tokens := dm:getMishnahTksJSON($mcite, $wits)
                let $headers := <headers>
                    <header name="Accept" value="application/json"/> 
                    <header name="Content-type" value="application/json"/>
                </headers>
                let $results := parse-json(
                    content:get-metadata-and-content(
                    httpc:post(xs:anyURI('http://54.152.68.192/collatex/collate'), $tokens, false(), $headers) 
                  ))
                return 
                    element div {(
                        $node/@*[not(starts-with(name(), 'data-'))],
                        if ($mode = 'apparatus')
                        then () (:cmp:compare-app($results):)
                        else if ($mode = 'synopsis')
                             then () (:cmp:compare-syn($results):)
                             else cmp:compare-align-collatex($results)
                    )}
    else <div class="text-center">choose passage and sources and click compare...</div>
};

(:~
 : This templating function generates a table of variants from a TEI stand-off collation
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function cmp:compare-align($collation as xs:string, $mcite as xs:string, $wits as item()+){
    let $coll := doc($collation)
    return <div class="alignment-table"><table class="alignment-table" dir="rtl">{
        for $wit in $wits
        let $src := doc(concat($config:data-root, "mishnah/w-sep/", $wit, "-w-sep.xml"))//tei:ab[@xml:id=concat($wit,'.',$mcite)]
        return
            <tr>
            <td class="wit">{$wit}</td>
            {
                for $rdg in $coll//tei:rdg[@wit=concat("#", $wit)]
                return
                    <td>{(
                        attribute class {
                            if (count($rdg/ancestor::tei:app/tei:rdgGrp[not(@n='empty')]) = 1) 
                            then 'invariant' 
                            else 'variant' 
                          },
                        $src//tei:w[@xml:id=substring-after($rdg/tei:ptr/@target, "#")]
                    )}</td>
            }</tr>
    }</table></div>
};


(:~
 : This templating function generates a table of variants from a CollateX JSON collation
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function cmp:compare-align-collatex($results as item()){
    let $wits := $results("witnesses")
    let $table := $results("table")
    return <table class="alignment-table" dir="rtl">{
        for $i in 1 to array:size($wits)
        return
            <tr>
                <td class="wit">{$wits($i)}</td>
                {
                    for $j in 1 to array:size($table)
                    return 
                        let $col := $table($j)
                        let $isVariant := 
                            count(distinct-values(
                                for $c in 1 to array:size($col)
                                return if (array:size($col($c))) then $col($c)(1)("n") else ()
                            )) > 1
                        let $data := $col($i)
                            return element td {
                                if (array:size($data) > 0)
                                then ( 
                                    attribute class {if ($isVariant) then 'variant' else 'invariant'},
                                    $data(1)("n")
                                    )
                                else ()
                            }
                } 
            </tr>
    }</table>
};

