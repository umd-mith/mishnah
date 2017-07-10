xquery version "3.1";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace local = "http://mylocalfunctions.uri";
(:import module namespace request = "http://exist-db.org/xquery/request";:)



(:these two variables should be replaced by parameters from app  :)
declare variable $mCite := '4.2.3.1';
declare variable $nodes := collection('../tei/w-sep/?select=*.xml')/*/*/*/*/*/*/tei:ab[matches(@xml:id, concat($mCite, '$'))];

(:declare variable $paraNodes :=
let $queryStr := request:get-parameter("query", "all")
return
   if ($queryStr = 'all') then
      () (\: do default respons:\)
   else
      () (\: get requested texts :\);:)


declare variable $addIDs := for $ab in $nodes
(: abs that have additions :)
where $ab//*[self::tei:addSpan[not(@type = "comm")]]
return
   <list
      xmlns="http://mylocalfunctions.uri"
      xml:id="{$ab/@xml:id}">{
         for $val in $ab//*[self::tei:addSpan[not(@type = "comm")]]
         return
            <val>{substring-after($val/@*[name() = 'spanTo']/string(), '#')}</val>
      }</list>;

declare variable $delIDs := for $ab in $nodes
(: abs that have deletions :)
where $ab//*[self::tei:delSpan]
return
   <list
      xmlns="http://mylocalfunctions.uri"
      xml:id="{$ab/@xml:id}">{
         for $val in $ab//*[self::tei:delSpan]
         return
            <val>{substring-after($val/@*[name() = 'spanTo']/string(), '#')}</val>
      }</list>;



declare variable $commIDs := for $ab in $nodes
(: abs that have addition of commentary :)
where $ab//tei:addSpan[@type = "comm"]
return
   <list
      xmlns="http://mylocalfunctions.uri"
      xml:id="{$ab/@xml:id}">{
         for $val in $ab//*[self::tei:addSpan[@type = 'comm']]
         return
            <val>{substring-after($val/@*[name() = 'spanTo']/string(), '#')}</val>
      }</list>;


declare variable $textToFilter :=
(: text nodes that fall between add or comm start/end tags:)
(: For text nodes had to do this by position in document rather than sets:)
for $ab in $nodes
where $ab//*[self::tei:anchor[@type = 'comm' or @type = 'add']]
return
   <filtered
      xml:id="{$ab/@xml:id}"
      xmlns="http://mylocalfunctions.uri">{
         <comm>{
               for $i in
               distinct-values($commIDs[@xml:id = $ab/@xml:id]/local:val)
               return
                  <item>{
                        (: start position :)
                        <s>{count($ab//*[contains(@spanTo, $i)]/preceding::node())}</s>,
                        (: end position :)
                        <e>{count($ab//*[@xml:id = $i]/preceding::node())}</e>
                     }</item>
            }</comm>,
         <add>{
               for $i in
               distinct-values($addIDs[@xml:id = $ab/@xml:id]/local:val)
               return
                  <item>{
                        (: start position :)
                        <s>{count($ab//*[contains(@spanTo, $i)]/preceding::node())}</s>,
                        (: end position :)
                        <e>{count($ab//*[@xml:id = $i]/preceding::node())}</e>
                     }</item>
            }</add>,
         <del>{
               for $i in
               distinct-values($delIDs[@xml:id = $ab/@xml:id]/local:val)
               return
                  <item>{
                        (: start position :)
                        <s>{count($ab//*[contains(@spanTo, $i)]/preceding::node())}</s>,
                        (: end position :)
                        <e>{count($ab//*[@xml:id = $i]/preceding::node())}</e>
                     }</item>
            }</del>
         
      }
   </filtered>
;

declare variable $textForH2 :=
(: text nodes that fall between add or comm start/end tags:)
(: For text nodes had to do this by position in document rather than sets:)
for $ab in $nodes
where $ab//*[self::tei:anchor[@type = 'comm' or @type = 'add']]
return
   <filtered
      xml:id="{$ab/@xml:id}"
      xmlns="http://mylocalfunctions.uri">{
         for $i in
         distinct-values($delIDs[@xml:id = $ab/@xml:id]/local:val | $commIDs[@xml:id = $ab/@xml:id]/local:val)
         return
            <item>{
                  (: start position :)
                  <s>{count($ab//*[contains(@spanTo, $i)]/preceding::node())}</s>,
                  (: end position :)
                  <e>{count($ab//*[@xml:id = $i]/preceding::node())}</e>
               }</item>
      }
   </filtered>
;


declare function local:filter-w-set($w-set as node()*, $case as xs:string) as node()* {
   (: Filters w elements, removing those wholly within the bounding add or del span and anchor tags :)
   (: More efficient than for loop evaluating each w? :)
   (: use global variable :)
   
   let $filtered :=
   switch ($case)
      case 'comm'
         return
            for $i in distinct-values($commIDs[@xml:id = $w-set/@xml:id]/local:val)
            return
               let $spans :=
               $w-set/*[contains(@spanTo, $i)] |
               $w-set//*[contains(@spanTo, $i)]/ancestor::tei:w |
               $w-set/*[contains(@spanTo, $i)]/following-sibling::* |
               $w-set//*[contains(@spanTo, $i)]/ancestor::tei:w/following-sibling::*
               let $anchors :=
               $w-set//tei:anchor[@xml:id = $i]/ancestor::tei:w/preceding-sibling::* |
               $w-set/tei:anchor[@xml:id = $i]/preceding-sibling::* |
               $w-set//tei:anchor[@xml:id = $i]/ancestor::tei:w |
               $w-set/tei:anchor[@xml:id = $i]
               
               return
                  $anchors intersect $spans
      case 'addDel'
         return
            for $i in distinct-values($addIDs[@xml:id = $w-set/@xml:id]/local:val | $delIDs[@xml:id = $w-set/@xml:id]/local:val)
            return
               let $spans := $w-set/*[self::tei:addSpan | self::tei:delSpan][contains(@spanTo, $i)] |
               $w-set//*[self::tei:addSpan | self::tei:delSpan][contains(@spanTo, $i)]/ancestor::tei:w |
               $w-set//*[self::tei:addSpan | self::tei:delSpan][contains(@spanTo, $i)]/ancestor::tei:w/following-sibling::* |
               $w-set/*[self::tei:addSpan | self::tei:delSpan][contains(@spanTo, $i)]/following-sibling::*
               
               let $anchors := $w-set/tei:anchor[@xml:id = $i][not(ancestor::tei:w)] |
               $w-set//tei:anchor[@xml:id = $i]/ancestor::tei:w |
               $w-set//tei:anchor[@xml:id = $i]/ancestor::tei:w/preceding-sibling::* |
               $w-set/tei:anchor[@xml:id = $i]/preceding-sibling::*
               
               return
                  $spans intersect $anchors
      
      
      default return
         ()
return
   $filtered

};

declare function local:w-children($w as node(), $id as xs:string) as item()* {
   for $n in $w/node()
   return
      typeswitch ($n)
         case text()
            return
               if (not(normalize-space($n))) then
                  ()
               else
                  normalize-space($n)
         case element(tei:choice)
            return
               if ($n/tei:abbr) then
                  (local:w-children($n/tei:abbr, $id), <exp>{normalize-space($n/tei:expan/text())}</exp>)
               else
                  if ($n/tei:orig) then
                     (local:w-children($n/tei:orig, $id), <r>{normalize-space($n/tei:reg/text())}</r>)
                  else
                     ()
         case element(tei:damageSpan)
            return
               text {normalize-space('')}
         case element(tei:gap)
            return
               ()
         case element(tei:anchor)
            return
               text {''}
         case element(tei:c)
            return
               $n/text()
         case element(tei:am)
            return
               $n/text()
               
               (: replace typographically :)
         case element(tei:lb)
            return
               text {normalize-space('|')}
               
               (: remove all others :)
         case element()
            return
               ()
         default
            return
               ()
}
;

declare function local:filterTextNodes($t as text(), $id as xs:string, $case as xs:string) as item()* {
   (: identifies text nodes within commentaries, additions, deletions and omits :)
   (: Is there a cleaner way of doing this? :)
   switch ($case)
      case 'comm'
         return
            let $pos := count($t/preceding::node()),
               $cases := $textToFilter[@xml:id = $id]/local:comm/local:item
            return
               if (some $endPt in $cases
                  satisfies ($pos > $endPt/local:s/text() and $pos < $endPt/local:e/text())) then
                  ()
               else
                  $t
      
      default return
         ()

};


declare function local:omitComms($ab as node()+) as node()*
{
   for $elem in $ab/* except local:filter-w-set($ab, 'comm')
   return
      typeswitch ($elem)
         case element(tei:w)
            return
               <w
                  xml:id="{$elem/@xml:id}"
                  xmlns="http://www.tei-c.org/ns/1.0">{
                     for $n in $elem/node()
                     return
                        typeswitch ($n)
                           case (text())
                              return
                                 if (not(normalize-space($n))) then
                                    ()
                                 else
                                    local:filterTextNodes($n, $ab/@xml:id, 'comm')
                           default
                              return
                                 $n
                  }</w>
         case element()
            return
               $elem
         default
            return
               ()
};

declare function local:getAddDelRanges($addDelItems as node()+) as node()+ {
   <groups
      xmlns="http://mylocalfunctions.uri">{
         for $i in 1 to count($addDelItems)
         return
            (
            (: preceding cases :)
            if ($i = 1) then
               <s>{$i}</s>
            else
               if (not($addDelItems[$i]/preceding-sibling::tei:w)) then
                  <s>{$i}</s>
               else
                  if (local:wdNo($addDelItems[$i]/preceding-sibling::tei:w[1]/@xml:id) != local:wdNo(
                  if ($addDelItems[$i - 1][self::tei:w])
                  then
                     $addDelItems[$i - 1]/@xml:id
                  else
                     $addDelItems[$i - 1]/preceding-sibling::tei:w[1]/@xml:id)) then
                     <s>{$i}</s>
                  else
                     (),
            (: following cases :)
            if ($i = count($addDelItems)) then
               <e>{$i}</e>
            else
               if (not($addDelItems[$i]/following-sibling::tei:w)) then
                  <e>{$i}</e>
               else
                  if (local:wdNo($addDelItems[$i]/following-sibling::tei:w[1]/@xml:id) != local:wdNo(
                  if ($addDelItems[$i + 1][self::tei:w])
                  then
                     $addDelItems[$i + 1]/@xml:id
                  else
                     $addDelItems[$i + 1]/following-sibling::tei:w[1]/@xml:id)) then
                     <e>{$i}</e>
                  else
                     ()
            )
      }</groups>
};

declare function local:doAddDel($ab as node()+) as node()+ {
   let $addDel := local:filter-w-set($ab, 'addDel')/.
   return
      <ab
         xmlns="http://www.tei-c.org/ns/1.0">{
            $ab/@xml:id,
            let $groups := local:getAddDelRanges($addDel)
            return
               for $s in $groups/local:s
               return
                  (
                  if (not($s/preceding-sibling::*)) then
                     $addDel[number($s)]/preceding-sibling::*
                  else
                     $addDel[number($s)]/preceding-sibling::* intersect $addDel[number($s/preceding-sibling::local:e[1])]/following-sibling::*,
                  let $addDelGroup :=
                  
                  $addDel[number($s)] |
                  $addDel[number($s)]/following-sibling::* intersect $addDel[number($s/following-sibling::local:e[1])]/preceding-sibling::* |
                  $addDel[number($s/following-sibling::local:e[1])]
                  return
                     (local:h1h2($addDelGroup, 'h1'),
                     local:h1h2($addDelGroup, 'h2')),
                  if (not($s/following-sibling::*)) then
                     $addDel[number($s)]/following-sibling::*
                  else
                     ()
                  )
         }</ab>
};


declare function local:wdNo($str as xs:string) as xs:integer {
   (:replace($str,'[PS]\d{5}\.\d{1}\.\d{1,2}\.\d{1,2}\.\d{1,2}\.',''):)
   xs:integer(replace($str, '^.+\.(\d+)$', '$1'))
};


declare function local:h1h2($h1h2 as node()*, $resp as xs:string) as item()* {
   for $n in $h1h2
   return
      typeswitch ($n)
         case element(tei:w)
            return
               <w
                  xml:id="{$n/@xml:id}"
                  xmlns="http://www.tei-c.org/ns/1.0"
                  resp="{$resp}">{
                     local:h1h2($n/node(), $resp)
                  }</w>
         case element(tei:addSpan)
            return
               ()
         case element(tei:delSpan)
            
            return
               if ($n[@type = 'add'] | $n[@type = 'del']) then
                  ()
               else
                  $n
         case element()
            return
               $n
         case text()
            return
               switch ($resp)
                  case "h1"
                     return
                        if (some $s in $n/following::tei:anchor[@type = 'add']/@xml:id
                           satisfies $n/preceding::*[contains(@spanTo, $s)]) then
                           ()
                        else
                           $n
                  case "h2"
                     return
                        if (some $s in $n/following::tei:anchor[@type = 'del']/@xml:id
                           satisfies $n/preceding::*[contains(@spanTo, $s)]) then
                           ()
                        else
                           $n
                  default return
                     "error"
      default
         return
            $n

};

declare function local:addDelTextEndPts($h1h2 as node()*) as node()* {
   ()
};

(: 
: Main Query
:)
<witnesses>{
      let $noComm := for $ab in $nodes
      (: get only ws and string that is not between comm span and anchor:)
      (: instead do this after ? or don't use global variable? :)
      return
         (:$ab:)
         if (($addIDs[@xml:id = $ab/@xml:id] | $commIDs[@xml:id = $ab/@xml:id])/*) then
            <ab
               xmlns="http://www.tei-c.org/ns/1.0"
               xml:id="{$ab/@xml:id}">{
                  local:omitComms($ab)
               }</ab>
         else
            $ab
      
      return
         for $ab in $noComm
         (: from $noComm extract runs with add/del and deal with :)
         return
            element {"tokens"} {
               attribute {"id"} {substring-before($ab/@xml:id, '.')},
               let $witnessTokens :=
               if ($addIDs[@xml:id = $ab/@xml:id][node()] | $delIDs[@xml:id = $ab/@xml:id][node()]) then
                  local:doAddDel($ab)
               else
                  $ab
               return
                  for $w in $witnessTokens/tei:w
                  return
                     <t
                        id="{$w/@xml:id}">
                        {
                           if ($w/self::tei:w/@resp) then
                              attribute {"resp"} {$w/@resp/string()}
                           else
                              ()
                        }
                        {local:w-children($w, $ab/@xml:id/string())}</t>
            }
   }</witnesses>