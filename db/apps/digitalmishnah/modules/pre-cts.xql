(: urn:cts:ancJewLit:hebBible.chronicles_2.leningrad-cons:1.1 :)
import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console";

declare namespace tei="http://www.tei-c.org/ns/1.0"; 
declare namespace cts="http://www.digitalmishnah.org/cts";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization"; 
declare option output:method "xml";

declare variable $input-param := request:get-parameter('GetPassage', 'ref-t.1.1.1.1.4-ref-t.1.1.1.1.5');

(: change to variable based on parameters from URL :) 
declare variable $folder as xs:string :=
    let $ref := substring-before($input-param,'.')
    return
    switch ($ref)
    case "ref-bible" return "/bible/"
    case "ref-m" return "/mishnah/"
    case "ref-t" return "/tosefta/"
    case "mek"  return "/mekhilta/"
    case "sifra"  return "/sifra/"
    case "sifre-n"  return "/sifre-n/"
    case "sifre-d"  return "/sifre-d/"
    case "ref-y" return "/yerushalmi/"
    case "ref-b" return "/bavli/"
    case "ref" return "/mishnah/"
    default return "/mishnah/w-sep/"
    
;

declare variable $doc as  document-node() := doc(concat($config:data-root,$folder, substring-before($input-param,'.'),if ($folder = "/mishnah/w-sep/") then '-w-sep' else (),'.xml'));
declare function cts:analyze-ref($refStr as xs:string) as xs:string+{
    let $bits := tokenize($refStr,'\.')
    let $n := count($bits)
    return 
        for $e in 1 to $n - 1 
        return string-join(for $b in 1 to $e +1  return $bits[$b] ,'.')
};

declare function cts:build-tree($start as xs:string+, $end as xs:string+) as item()* {
    let $docname as xs:string := concat(substring-before($start,'.'),'.xml')
    return 
    if (cts:analyze-ref($start)[2] = cts:analyze-ref($end)[2])
    then 
        doc(concat($config:data-root,'/mishnah/',$docname))/id(cts:analyze-ref($start)[2])
    else
        'no'
};

declare function cts:tree-switch($start as xs:string+, $end as xs:string+){
    if ($start[1] = $end[1]) then
        let $elem := $doc/id($start[1])
         return element {$elem/name()} {
            $elem/@*,
            cts:tree-switch($start[position() > 1],$end[position() > 1])
            }
    else if (not($doc/id($end[last()]) = $doc/id($start[last()])/following-sibling::*))
        then
            let $s-ancestor := $doc/id($start[1])
            let $s := $doc/id($start[last()])
            let $e-ancestor := $doc/id($end[1])
            let $e := $doc/id($end[last()])
            return 
            (
            console:log(($s-ancestor/name(),$s,$e-ancestor/name(),$e)),
            cts:ancestorsOfStartEnd($start,"first"),
            cts:ancestorsOfStartEnd($end,"last")
            )
    else if ($doc/id($end[last()]) = $doc/id($start[last()])/following-sibling::*)
        then
            let $s := $doc/id($start[1])
            let $e := $doc/id($end[1])
            return (
                
                $s|$s/following-sibling::* intersect $e/preceding-sibling::*|$e
            )
    else 
        <problem>{($start,$end)}</problem>  
 };

declare function cts:ancestorsOfStartEnd($in as xs:string+,$firstLast as xs:string*) as element()*{
    ((:console:log($in),:)
    let $highest := $doc/id($in[1])
    let $lowest := $highest/id($in[last()])
    return
    if (count($in) = 1 and not($firstLast))
        (: we are dealing with a single ref above the word level :)
        then 
            $highest
        else 
    if ($highest/tei:w)
        then (
        element {$highest/name()} {
            $highest/@*,
            if 
                ($firstLast = 'last') 
            then 
                 $highest/$lowest/preceding-sibling::* 
                 else (),
            $lowest,     
            if ($firstLast = 'first') 
                then 
            $highest/$lowest/following-sibling::* 
                else ()
          }
        )
    else 
        element {$highest/name()} {
            $highest/@*,
                cts:ancestorsOfStartEnd($in[position() > 1],$firstLast)
            }
    )        
};

    let $s as xs:string+ := tokenize(replace($input-param, '^(\w.+\.\d+)\-(\w.+\.\d+?)$','$1,$2'),',')
        
    return
        
        <TEI>{$doc/tei:TEI/@*,$doc/tei:TEI/tei:teiHeader}<text><body>{
        if (count($s) = 1 ) then 
            (: single ref :)
             cts:ancestorsOfStartEnd(cts:analyze-ref($s),'')
        else if (count($s) = 2)
        then 
            (: reference range :)
            cts:tree-switch(cts:analyze-ref($s[1]),cts:analyze-ref($s[2]))
        else 
        (: error message :)
        error(xs:QName('local:InputError'),"Problem with input") 
        }</body></text></TEI>
        
    