xquery version "3.1";

module namespace cmp="http://www.digitalmishnah.org/templates/compare";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace httpc="http://exist-db.org/xquery/httpclient";
import module namespace content="http://exist-db.org/xquery/contentextraction"
    at "java:org.exist.contentextraction.xquery.ContentExtractionModule";
import module namespace app="http://www.digitalmishnah.org/templates" at "app.xql";
    
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
        
        (: Is this a chapter or a mishnah? :)
        return
            if (count(tokenize($mcite, '\.')) = 3)
            then cmp:compare-chapter($node, $mcite, $wits, $mode)
            else cmp:compare-mishnah($node, $mcite, $wits, $mode)
    else <div class="text-center">choose passage and sources and click compare...</div>
};

declare function cmp:compare-chapter($node as node(), $mcite as xs:string, $wits as xs:string*, $mode as xs:string){

    (: Determine the number of mishnahs contained :)
    for $ab in doc(concat($config:data-root, "/mishnah/ref.xml"))//tei:div3[@xml:id=concat("ref.", $mcite)]/tei:ab
    let $mishnah := substring-after($ab/@xml:id, 'ref.')
    return cmp:compare-mishnah($node, $mishnah, $wits, $mode)

};

declare function cmp:compare-mishnah($node as node(), $mcite as xs:string, $wits as xs:string*, $mode as xs:string){    
    if ($mode = 'synopsis')
    then cmp:compare-syn($mcite, $wits)
    else 
        (: Determine whether there is a curated collation for this mcite :)
        let $collation := concat($config:data-root, "/mishnah/collations/", $mcite, ".xml")            
        let $coll_available := doc-available($collation)
        return
            if ($coll_available)            
            then  
                if ($mode = 'apparatus')
                then cmp:compare-app($collation, $mcite, $wits) 
                else cmp:compare-align($collation, $mcite, $wits)
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
                if ($mode = 'apparatus')
                then cmp:compare-app-collatex($mcite, $results, $wits)
                else
                  (<h2>{app:expand-mcite($mcite)}</h2>,
                  element div {(
                      $node/@*[not(starts-with(name(), 'data-'))],
                      cmp:compare-align-collatex($results, $wits)
                  )})
};

(:~
 : This templating function generates a table of variants from a TEI stand-off collation
 :)
declare function cmp:compare-align($collation as xs:string, $mcite as xs:string, $wits as item()+){
    let $coll := doc($collation)
    return
      (<h2>{app:expand-mcite($mcite)}</h2>,
      <div class="alignment-table" dir="rtl"><table class="alignment-table" dir="rtl">{
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
    }</table></div>)
};


(:~
 : This templating function generates a table of variants from a CollateX JSON collation
 :)
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

(:~
 : This templating function generates a synoptic table of a given mishnah or chapter
 :)
declare function cmp:compare-syn($mcite as xs:string, $wits as item()+){
     (<h2>{app:expand-mcite($mcite)}</h2>,
     <div class="synopsis" dir="rtl"><table class="synopsis-table" dir="rtl">{
        <tr>{
            for $wit in $wits
            return                
                <th class="text-column-head">{$wit}</th>
        }</tr>,
        <tr class="synopsis">{
            for $wit in $wits
            let $src := doc(concat($config:data-root, "mishnah/", $wit, ".xml"))//tei:ab[@xml:id=concat($wit,'.',$mcite)]
            return                
                <td class="text-col">{
                    transform:transform($src, doc("//exist/apps/digitalmishnah/xsl/synopsis.xsl"), ())
                }</td>
        }</tr>
    }</table></div>)
};

(:~
 : This templating function generates apparatus for a given mishnah of chapter. Needs a TEI collation.
 :)
declare function cmp:compare-app($collation as xs:string, $mcite as xs:string, $wits as item()+){
    let $coll := doc($collation)
    let $src := 
        <div xmlns="http://www.tei-c.org/ns/1.0">{
            for $wit in $wits
            return doc(concat($config:data-root, "mishnah/w-sep/", $wit, "-w-sep.xml"))//tei:ab[@xml:id=concat($wit,'.',$mcite)]
        }</div>        
    return 
     (<h2>{app:expand-mcite($mcite)}</h2>,
     transform:transform($src, doc("//exist/apps/digitalmishnah/xsl/apparatus.xsl"), ()),
     <div class="apparatus" dir="rtl">{
        for $appEntry in $coll//tei:app            
        return 
            (: It needs to go ahead only if there are multiple readings involving the REQUESTED WITS :)
            (: For example <rdgGrp n="1"><rdg wit="#A"/><rdg wit="#B"/></rdgGrp><rdgGrp><rdg wit="#C"/></rdgGrp>
               should not count if the wits required are just A and B (they agree!) :)
            if (count($appEntry//tei:rdgGrp[tei:rdg[contains($wits, substring-after(@wit, '#'))]]) > 1)                   
            then
            <span class="reading-group">{
                let $baseRdgGrp := data($appEntry/tei:rdgGrp[tei:rdg[@wit=concat("#", $wits[1])]]/@n)
                return (
                <span class="lemma">{
                    let $target := substring-after($appEntry//tei:rdg[@wit=concat("#", $wits[1])]/tei:ptr/data(@target), '#')
                    return $src//tei:w[@xml:id=$target]/text()
                }</span>,
                <span class="matches">{
                    for $matchingRdg in $appEntry/tei:rdgGrp[@n=$baseRdgGrp]/tei:rdg
                    return $matchingRdg[not(@wit=concat("#", $wits[1])) and 
                                        contains($wits, substring-after(@wit, '#'))]/substring-after(@wit, '#')
                }</span>,
                for $rdg in $appEntry/tei:rdgGrp[not(@n=$baseRdgGrp)]/tei:rdg[contains($wits, substring-after(@wit, '#'))]
                return
                    (<span class="readings">{
                        $src//tei:w[@xml:id=substring-after($rdg/tei:ptr/data(@target), '#')]/text()
                    }</span>,
                    <span class="witnesses">{data(substring-after($rdg/@wit, '#'))}</span>)
            )}</span>
            else ()
     }</div>
     )
};

(:~
 : This templating function generates apparatus for a given mishnah of chapter using data computed by Collatex
 :)
declare function cmp:compare-app-collatex($mcite as xs:string, $results as item(), $orderedWits as xs:string*){
    let $wits := $results("witnesses")
    let $table := $results("table")
    let $src := 
        <div xmlns="http://www.tei-c.org/ns/1.0">{
            for $wit in $orderedWits
            return doc(concat($config:data-root, "mishnah/w-sep/", $wit, "-w-sep.xml"))//tei:ab[@xml:id=concat($wit,'.',$mcite)]
        }</div>    
    return 
        (<h2>{app:expand-mcite($mcite)}</h2>,
        transform:transform($src, doc("//exist/apps/digitalmishnah/xsl/apparatus.xsl"), ()),
        <div class="apparatus" dir="rtl">{
            for $token in $table?*
                let $relevantTokens := 
                    <map>{
                        for $orderedWit in $orderedWits
                        let $wit := array:filter($wits, function($w) {upper-case(substring-before($w, '.xml')) = $orderedWit})
                        let $i := index-of($wits, $wit)
                        return
                            if (array:size($token($i)) > 0)
                            then <pair><key>{$token($i)(1)("t")}</key> <value>{$i}</value></pair>
                            else ()
                    }</map>
                    
                return
                    if (count(distinct-values($relevantTokens//key)) > 1)
                    then
                        <span class="reading-group">{(
                            <span class="lemma">{$relevantTokens/pair[1]/key/text()}</span>,
                            <span class="matches">{
                                for $rt in $relevantTokens/pair[position()>1]
                                return
                                    if ($rt/key = $relevantTokens/pair[1]/key)
                                    then ($orderedWits[position() = $rt/value])
                                    else()
                            }</span>,
                            for $rt in $relevantTokens/pair[position()>1]
                            return
                                if ($rt/key != $relevantTokens/pair[1]/key)
                                then
                                    (<span class="readings">{
                                        $rt/key/text()
                                    }</span>,
                                    <span class="witnesses">{$orderedWits[position() = $rt/value]}</span>)
                                else ()
                        )}</span>
                    else ()
        }</div>)
};