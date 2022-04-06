xquery version "3.1";


import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm"; 

(:import module namespace console="http://exist-db.org/xquery/console";:)

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace cmp = "http://www.digitalmishnah.org/tbl";


declare boundary-space strip;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";



(:declare variable $data-root := "file:///c:/users/hlapin/documents/digitalmishnah-tei";:)
declare variable $mcite := "4.2.5.1";
declare variable $wits := "S07326,S00483,S01520,S00651,S08174,P00001,P179204,S07319,S08010,P00002,S07204,S07106,S07394,S07397";


declare function cmp:w-to-span ($wParts as node()+,$h as xs:string*) as item()*{
   typeswitch ($wParts)
   case text() 
      return cmp:doText($wParts, $h)
   case element (tei:w) return   
      if ($wParts/tei:choice) then 
         cmp:filter($wParts/node(), $h)
      else 
         <span>{
            attribute class {'surface'},
            attribute id {
               (concat($wParts/@xml:id,
               if ($h) then concat('-',$h) else ()))},
            (: conditions based on $h and presense of span/del :)
            if ($h = 'h2' 
                and not($wParts//(tei:addSpan[@type='add']|tei:delSpan|tei:anchor[@type='add' or @type='del']))) 
            then <span class="add">{cmp:filter($wParts/node(), $h)}</span>
            else cmp:filter($wParts/node(), $h)
            }</span> 
   case element (tei:choice) return 
      <span>{ attribute class {'choice'},cmp:filter($wParts/node(), $h)}</span>
   case element (tei:orig) | element (tei:abbr)  return
      <span >{
         attribute class {'surface', $wParts/name()},
         attribute id {concat($wParts/ancestor::tei:w/@xml:id/string(),if ($h) then concat('-',$h) else ())},
         (: conditions based on $h and presense of span/del :)
         if ($h = 'h2' 
                and not($wParts//(tei:addSpan[@type='add']|tei:delSpan|tei:anchor[@type='add' or @type='del']))) 
            then <span class="add">{cmp:filter($wParts/node(), $h)}</span>
            else cmp:filter($wParts/node(), $h)
            }</span> 
   case element(tei:expan) return
      <span class="expan">{cmp:filter($wParts/node(),$h)}</span>   
   case element (tei:anchor) | element(tei:addSpan) | element(tei:delSpan) | element(tei:damageSpan)| element (tei:reg)
      return ''   
   case element(tei:am)
      return cmp:filter($wParts/node(), $h)
   default return ()   
 };

declare function cmp:filter ($in as item()+, $h as xs:string*) as item()* {
   for $out in $in return cmp:w-to-span($out,$h)
};

declare function cmp:doText($txtNode as node(), $h as xs:string*) as item()+ {
   let $addDel as xs:string* := 
             if ($txtNode/following-sibling::tei:anchor[1][@type='add']/@xml:id = substring-after($txtNode/preceding-sibling::tei:addSpan[1]/@spanTo,"#"))
             then 'add'
             else if ($txtNode/following-sibling::tei:anchor[1][@type='add'][not(./preceding-sibling::tei:addSpan[@type='add'])])
             then 'add' 
             else if ($txtNode/preceding-sibling::tei:addSpan[1][@type='add'][not(following-sibling::tei:anchor[@type='add'])])
             then 'add'
             else if ($txtNode/following-sibling::tei:anchor[1][@type='del']/@xml:id = substring-after($txtNode/preceding-sibling::tei:delSpan[1]/@spanTo,"#"))
             then 'del'
             else if ($txtNode/following-sibling::tei:anchor[1][@type='del'][not(./preceding-sibling::tei:delSpan)])
             then 'del'
             else if ($txtNode/preceding-sibling::tei:delSpan[1][not(following-sibling::tei:anchor[@type='del'])])
             then 'del'
             else ()
    let $dam as xs:string* := if ($txtNode/following-sibling::tei:anchor[1][@type='damage']/@xml:id = substring-after($txtNode/preceding-sibling::tei:damageSpan[1]/@spanTo,"#"))
             then 'damage'
             else if ($txtNode/following-sibling::tei:anchor[1][@type='damage'][not(./preceding-sibling::tei:damageSpan)])
             then 'damage'
             else if ($txtNode/preceding-sibling::tei:damageSpan[1][not(following-sibling::tei:anchor[1][@type='damage'])])
             then 'damage'
             else ()
   return 
   if (not(normalize-space($txtNode))) then 
    ''
   else if ($h = 'h2') then
      if ($addDel = 'add') then <span>{attribute class {$addDel, $dam},normalize-space($txtNode)}</span>
      else if ($addDel = 'del') then <span>{attribute class {$addDel, $dam},normalize-space($txtNode)}</span>
      else if ($dam = 'damage') then <span>{attribute class {$dam},normalize-space($txtNode)}</span>
      else normalize-space($txtNode)
   else if ($h='h1') then
      if ($addDel = 'add') then ''
      else if ($addDel = 'del' and not($dam = 'damage')) then normalize-space($txtNode)
      else if ($dam = 'damage') then <span>{attribute class {$dam},normalize-space($txtNode)}</span>
      else normalize-space($txtNode)
   else if ($dam = 'damage') then <span>{attribute class {$dam},normalize-space($txtNode)}</span>
   else normalize-space($txtNode)
  };

declare function cmp:align-table($mcite as xs:string, $wits as xs:string) as element()+{
let $apps := doc(concat($config:data-root,'mishnah/collations/',$mcite,'.xml'))//tei:ab
(:let $data := for $wit in tokenize($wits,',') return
   doc(concat($config:data-root,'mishnah/w-sep/',$wit,'-w-sep.xml'))/id(concat($wit,'.',$mcite))
:)   return
let $cols := $apps//tei:app
(: each tei:app is a variation locus :)
let $rows := tokenize($wits,',')
(: source is organized by locus, with readings for each witness grouped by similarity,
 : we want to pivot the data to yield a table with row for each witness. :)
return 
   for $row in $rows return
      <tr>{
      for $col in $cols return
        (: each rdg is a cell in table :)
        let $tempCells := 
         $col//tei:rdg[@wit = concat('#',$row)]
             (:(\:let $currRdg := $col//tei:ptr[contains(@target,$row)]:\)
             let $currRdg := for $ptr in $col//tei:ptr return if (contains($ptr/@target, $row)) then $ptr else ()
             let $grp := $currRdg/ancestor::tei:rdgGrp/@n
            return
               (
                if (not($grp)) then ()else attribute class {concat('group-',$grp)},   
               for $wdId in $currRdg/@target
               return 
                  let $idParts := tokenize($wdId,'-') return
                  
                     let $w := $data/id(substring-after ($idParts[1],'#'))
                     return (
                        cmp:filter($w,$idParts[2])
                        )
                ):)
          
          return 
            for $cell in $tempCells return
            let $data := doc(concat($config:data-root,'mishnah/w-sep/',$row,'-w-sep.xml'))/id(concat($row,'.',$mcite))
            return <td>{
               attribute class {concat('group-',$cell/parent::*/@n)},
            for $id in $cell//@target return 
               let $idParts := tokenize($id,'-') return
                  
                     let $w := $data/id(substring-after ($idParts[1],'#'))
                     return 
                        cmp:filter($w,$idParts[2])

            
            }</td>
          
      }</tr>
      
 };
<table>{cmp:align-table($mcite, $wits)}</table>