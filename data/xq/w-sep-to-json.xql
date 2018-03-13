xquery version "3.1";

(: 
 : Hayim Lapin 3/6/2018 
 : Rewritten to copy nodes of interest to memory, to allow faster processing.
 : Hayim Lapin, 3/1/2018 
 : Adapted to be utilized as function within app
 : Hayim Lapin, 12/10/2017 
 : takes word separated data from multiple files based on their common location in Mishnah ($mCite)
 : and creates a single json file that serves as input to CollateX                                 
 : For CollateX each token has a reading surface reading "t";  
 : we provide "n" (normalized) as an alternative basis for alignent. 
 : The remaining attributes are passed through collatex. We use: 
 :    "expan" for the expanded reading of inscriptions 
 :    "wGroup" for the reading of word groups that appear as one, two, or three tokens 
 :    "resp" for identifying h1 and h2 
 :  
 : The source data is separated into <w>s, which can have children that need to be processed. 
 : Additions, deletions, and damage are marked using *Span and anchor; these can appear either as children or siblings of w. 
 : This xquery reconstructs "h1" (as written by the original files) and a nominal "h2" (incorporating any number of interventions) 
 : by using the addSpan|delSpan and corresponding anchors to identify the the added and deleted text. 
 : In addition, the xquery looks for word groups that occur as one or more tokens, but iterating through each token  
 :)

import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace morph = "http://www.digitalmishnah.org/morph" at "pseudoMorph.xqm";

declare boundary-space strip;
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace local = "http://mylocalfunctions.uri";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:method "txt";:)

declare option output:method "json";
declare option output:media-type "application/json";



(: parameters need to be changed to map from templating function :)
declare variable $mCite as xs:string :=  request:get-parameter('mcite', '');
declare variable $wits as item()* := request:get-parameter('wits', '');

declare variable $m as item()* := if (not($mCite ='')) then $mCite else '4.1.1.1';
declare variable $witNames as xs:string* := 
   if (not($wits) or $wits = '' or $wits = 'all') 
   then doc(concat($config:data-root, "/mishnah/ref.xml"))//tei:witness/@xml:id/string() 
   else tokenize($wits,',');
   
(:  create local copy of nodes  :)
declare variable $nodes :=
let $abs :=
for $witName in $witNames
return
   doc(concat($config:data-root, 'mishnah/w-sep/', $witName, '-w-sep.xml'))//tei:ab[@xml:id eq concat($witName,'.', $m)]
return
   for $ab as element() in $abs
   return
      local:copy($ab);



declare variable $addIDs := for $ab in $nodes[.//addSpan[not(@type eq "comm")]]
(: abs that have additions :)
return
   (
   <list
      xml:id="{$ab/@xml:id}">{
         for $val in $ab//addSpan[not(@type eq "comm")]
         return
            <val>{substring-after($val/@spanTo/string(), '#')}</val>
      }</list>);

declare variable $delIDs := for $ab in $nodes[.//delSpan]
(: abs that have deletions :)
return
   <list
      xml:id="{$ab/@xml:id}">{
         for $val in $ab//delSpan
         return
            <val>{substring-after($val/@spanTo/string(), '#')}</val>
      }</list>;


declare variable $commIDs := for $ab in $nodes[.//addSpan[@type eq "comm"]]
(: abs that have addition of commentary :)
return
   <list
      xml:id="{$ab/@xml:id}">
      {
         for $val in $ab//addSpan[@type = 'comm']
         return
            <val>{substring-after($val/@spanTo, '#')}</val>
      }
   </list>

;


declare variable $textToFilter :=
(: text nodes that fall between add or comm start/end tags:)
(: For text nodes had to do this by position in document rather than sets:)

   for $ab in $nodes[.//anchor[@type = 'comm' or @type = 'add' or @type = "del"]]
   return
      <filtered
         xml:id="{$ab/@xml:id}">{
            
            <add>{
                  for $i in
                  distinct-values($addIDs[@xml:id eq $ab/@xml:id]/val)
                  return
                     
                     <item>{
                           (: start position :)
                           <s>{count($ab//addSpan[contains(@spanTo, $i)]/preceding::node())}</s>,
                           (: end position :)
                           <e>{count($ab//anchor[@xml:id eq $i]/preceding::node())}</e>
                        }</item>
               }</add>,
            <del>{
                  for $i in
                  distinct-values($delIDs[@xml:id = $ab/@xml:id]/val)
                  return
                     <item>{
                           (: start position :)
                           <s>{count($ab//delSpan[contains(@spanTo, $i)]/preceding::node())}</s>,
                           (: end position :)
                           <e>{count($ab//anchor[@xml:id eq $i]/preceding::node())}</e>
                        }</item>
               }</del>,
            <comm>{
                  for $i in
                  distinct-values($commIDs[@xml:id = $ab/@xml:id]/val)
                  return
                     <item>{
                           (: start position :)
                           <s>{count($ab//addSpan[contains(@spanTo, $i)]/preceding-sibling::node())}</s>,
                           (: end position :)
                           <e>{count($ab//anchor[@xml:id eq $i]/preceding-sibling::node())}</e>
                        }</item>
               }</comm>
            
         }
      </filtered>
;

(: makes a local copy to avoid traversing the whole document for processing:)
declare function local:copy($n as node()) as node() {
   typeswitch ($n)
      case $e as element()
         return
            element {name($e)}
            {
               $e/@*,
               for $c in $e/(* | text())
               return
                  local:copy($c)
            }
      default
         return
            $n
};

declare function local:omitComms($ab as node()+) as node()*
{
   for $elem in $ab/* except local:filter-w-set($ab, 'comm')
   return
      typeswitch ($elem)
         case element(w)
            return
               <w
                  xml:id="{$elem/@xml:id}">{
                     for $n in $elem/node()
                     return
                        typeswitch ($n)
                           case text()
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

declare function local:filter-w-set($w-set as node()*, $case as xs:string) as node()* {
   (: Filters w elements, removing those wholly within the bounding add or del span and anchor tags :)
   (: More efficient than for loop evaluating each w? :)
   (: use global variable :)
   
   let $filtered :=
   switch ($case)
      case 'comm'
         return
            for $i in distinct-values($commIDs[@xml:id = $w-set/@xml:id]/val)
            return
               let $spans :=
               $w-set/*[contains(@spanTo, $i)] |
               $w-set//*[contains(@spanTo, $i)]/ancestor::w |
               $w-set/*[contains(@spanTo, $i)]/following-sibling::* |
               $w-set//*[contains(@spanTo, $i)]/ancestor::w/following-sibling::*
               let $anchors :=
               $w-set//anchor[@xml:id = $i]/ancestor::w/preceding-sibling::* |
               $w-set/anchor[@xml:id = $i]/preceding-sibling::* |
               $w-set//anchor[@xml:id = $i]/ancestor::w |
               $w-set/anchor[@xml:id = $i]
               
               return
                  $anchors intersect $spans
      case 'addDel'
         return
            for $i in distinct-values($addIDs[@xml:id = $w-set/@xml:id]/val | $delIDs[@xml:id = $w-set/@xml:id]/val)
            return
               let $spans := $w-set/*[self::addSpan | self::delSpan][contains(@spanTo, $i)] |
               $w-set//*[self::addSpan | self::delSpan][contains(@spanTo, $i)]/ancestor::w |
               $w-set//*[self::addSpan | self::delSpan][contains(@spanTo, $i)]/ancestor::w/following-sibling::* |
               $w-set/*[self::addSpan | self::delSpan][contains(@spanTo, $i)]/following-sibling::*
               
               let $anchors := $w-set/anchor[@xml:id = $i][not(ancestor::w)] |
               $w-set//anchor[@xml:id = $i]/ancestor::w |
               $w-set//anchor[@xml:id = $i]/ancestor::w/preceding-sibling::* |
               $w-set/anchor[@xml:id = $i]/preceding-sibling::*
               
               return
                  $spans intersect $anchors
      
      
      default return
         ()
return
   $filtered

};


declare function local:regHebr($str as xs:string) as xs:string {
   (: latter borrowed from XSLT version. Better way of doing this? :)
   let $out := translate(translate(translate(replace($str, 'א$', 'ה'), 'ם', 'ן'), '|יו?', ''),'_','')
   return
      if ($out = '') then
         translate($str, ' ', '')
      else
         translate($out, ' ', '')
};


declare function local:filterTextNodes($t as text(), $id as xs:string, $case as xs:string) as item()* {
   (: identifies text nodes within commentaries, additions, deletions and omits :)
   (: Is there a cleaner way of doing this? :)
   switch ($case)
      case 'comm'
         return
            let $pos := count($t/preceding::node()),
               $cases := $textToFilter[@xml:id = $id]/comm/item
            return
               if (some $endPt in $cases
                  satisfies ($pos > $endPt/s/text() and $pos < $endPt/e/text())) then
                  ()
               else
                  replace($t, '[&#xa;\s+]', '')
      
      default return
         ()

};

declare function local:h1h2($h1h2 as node()*, $resp as xs:string) as item()* {
   for $n in $h1h2
   return
      typeswitch ($n)
         case element(w)
            return
               <w
                  xml:id="{$n/@xml:id}"
                  resp="{$resp}">{
                     local:h1h2($n/node(), $resp)
                  }</w>
         case element(addSpan)
            return
               ()
         case element(delSpan)
            
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
                        if (some $s in $n/following::anchor[@type = 'add']/@xml:id
                           satisfies $n/preceding::*[contains(@spanTo, $s)]) then
                           ()
                        else
                           replace($n, '[&#xa;\s+]', '')
                  case "h2"
                     return
                        if (some $s in $n/following::anchor[@type = 'del']/@xml:id
                           satisfies $n/preceding::*[contains(@spanTo, $s)]) then
                           ()
                        else
                           replace($n, '[&#xa;\s+]', '')
                  default return
                     "error"
      default
         return
            $n

};

declare function local:wdNo($str as xs:string) as xs:integer {
   (:replace($str,'[PS]\d{5}\.\d{1}\.\d{1,2}\.\d{1,2}\.\d{1,2}\.',''):)
   xs:integer(replace($str, '^.+\.(\d+)$', '$1'))
};

declare function local:getAddDelRanges($addDelItems as node()+) as node()+ {
   <groups >{
         for $i in 1 to count($addDelItems)
         return
            (
            (: preceding cases :)
            if ($i = 1) then
               <s>{$i}</s>
            else
               if (not($addDelItems[$i]/preceding-sibling::w)) then
                  <s>{$i}</s>
               else
                  if (local:wdNo($addDelItems[$i]/preceding-sibling::w[1]/@xml:id) != local:wdNo(
                      if ($addDelItems[$i - 1][self::w])
                      then
                         $addDelItems[$i - 1]/@xml:id
                      else
                         $addDelItems[$i - 1]/preceding-sibling::w[1]/@xml:id)) then
                         <s>{$i}</s>
                  else
                     (),
            (: following cases :)
            if ($i = count($addDelItems)) then
               <e>{$i}</e>
            else
               if (not($addDelItems[$i]/following-sibling::w)) then
                  <e>{$i}</e>
               else
                  if (local:wdNo($addDelItems[$i]/following-sibling::w[1]/@xml:id) != local:wdNo(
                  if ($addDelItems[$i + 1][self::w])
                  then
                     $addDelItems[$i + 1]/@xml:id
                  else
                     $addDelItems[$i + 1]/following-sibling::w[1]/@xml:id)) then
                     <e>{$i}</e>
                  else
                     ()
            )
      }</groups>
};


declare function local:doAddDel($ab as node()+) as node()+ {
   let $addDel := local:filter-w-set($ab, 'addDel')/.
   return
      <ab >{
            $ab/@xml:id,
            let $groups := local:getAddDelRanges($addDel)
            return
               for $s in $groups/s
               return
                  (
                  if (not($s/preceding-sibling::*)) then
                     $addDel[number($s)]/preceding-sibling::*
                  else
                     $addDel[number($s)]/preceding-sibling::* intersect $addDel[number($s/preceding-sibling::e[1])]/following-sibling::*,
                  let $addDelGroup :=
                        $addDel[number($s)] |
                        $addDel[number($s)]/following-sibling::* intersect $addDel[number($s/following-sibling::e[1])]/preceding-sibling::* |
                        $addDel[number($s/following-sibling::e[1])]
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


declare function local:w-children($wChild as node()+, $id as xs:string) as item()* {
   for $n in $wChild
   return
      typeswitch ($n)
         case text()
            return
               if (not(normalize-space($n))) then
                  ()
               else
                  (:$n:)
                  if ($n/parent::expan) then
                     normalize-space($n)
                  else
                     string-join(normalize-space(replace($n, '[&#xa;\s+]', '')), '')
         case element(choice)
            return
               if ($n/abbr) then
                  local:w-children($n/abbr/node(), $id)
               else
                  if ($n/orig) then
                     local:w-children($n/orig/node(), $id)
                  else
                     ()
         case element(damageSpan)
            return
               ()
               (:text {normalize-space('')}:)
         case element(gap)
            return
               ()
         case element(anchor)
            return
               ()
               (:text {''}:)
         case element(c)
            return
               $n/text()
         case element(am)
            return
               (:replace($n/text(), '\s+', ''):)
               $n/text()
               
               (: replace typographically :)
         case element(lb)
            return
               text {'|'}
               
               (: remove all others :)
         case element()
            return
               ()
         default
            return
               ()
}
;


(: for common word groups, variously written in the witnesses get relevant token ids :)
declare function local:wordGroups($wElems as element()*) {
for $w in $wElems
   (: identify the text of this w as well as 1, 2, [3] following :)
   let $this := 
      if ($w/expan) then
         $w/expan
      else if ($w/reg) then
         $w/reg/text()
      else
         $w/text()
   let $thisPlus1 := if ($w/following-sibling::w[1]/expan) then
         $w/following-sibling::w[1]/expan
      else if ($w/following-sibling::w[1]/reg) then
         $w/following-sibling::w[1]/reg
      else
         $w/following-sibling::w[1]/text()
   let $thisPlus2 := 
      if ($w/following-sibling::w[2]/expan) then
         $w/following-sibling::w[2]/expan
      else if ($w/following-sibling::w[2]/reg) then
         $w/following-sibling::w[2]/reg
      else
         $w/following-sibling::w[2]/text()
   (:  :)      
   let $joined2 := normalize-space(string-join($this | $thisPlus1))
   let $joinedOut2 := normalize-space(string-join($this | $thisPlus1,'_'))
   let $joined3 := normalize-space(string-join($this | $thisPlus1 | $thisPlus2))
   let $joinedOut3 := normalize-space(string-join($this | $thisPlus1 | $thisPlus2,'_'))

      return
         (: shel :)
         if (matches($w/text(), '^ו?של$'))
            then
              (<keep
                 
                 xml:id="{$w/@xml:id}">{$joinedOut2}</keep>,
              <omit
                 
                 xml:id="{$w/following-sibling::w[1]/@xml:id}"/>)
         (: ezehu :)
         (: why is the first condition even necessary? :)
         (: For single word rendering was matched by $joined2; should have been ignored:)
         else if (matches($this, '^.?אי?ז[הו]{1,2}[וי]א?$'))
            then
            ()
         else if (matches($joined2, '^.?אי?ז[הו]{1,2}[וי]א?$'))
            then
               (<keep
                  
                  xml:id="{$w/@xml:id}">{$joinedOut2}</keep>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[1]/@xml:id}"/>) 
         else if (matches($joined3, '^.?אי?ז[הו]{1,2}[וי]א?$'))
            then
               (<keep
                  
                  xml:id="{$w/@xml:id}">{$joinedOut3}</keep>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[1]/@xml:id}"/>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[2]/@xml:id}"/>)
         else if (matches($joined2, '^כא?יצד$|^כא?יזהצד$'))
            then
               (<keep
                  
                  xml:id="{$w/@xml:id}">{$joinedOut2}</keep>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[1]/@xml:id}"/>) 
         else if (matches($joined3, '^כא?יצד$|^כא?יזהצד$'))
            then
               (<keep
                  
                  xml:id="{$w/@xml:id}">{$joinedOut3}</keep>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[1]/@xml:id}"/>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[2]/@xml:id}"/>   
                  ) 
         else if (matches($joined2, '^ו?לפי?כך$'))
            then
               (<keep
                  
                  xml:id="{$w/@xml:id}">{normalize-space(string-join($this | $thisPlus1,'_'))}</keep>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[1]/@xml:id}"/>) 
         else
               ()
};


declare function local:buildJSON($wSequence as element()+) as map(*){
   map{ "witnesses" : for $ab in $wSequence return 
     map { "id" : substring-before($ab/@xml:id,'.'), 
     "tokens" : array {
     let $witnessTokens := 
         if ($addIDs[@xml:id = $ab/@xml:id][node()] | $delIDs[@xml:id = $ab/@xml:id][node()]) then
                  local:doAddDel($ab)
         else
            $ab
     let $wGroups := local:wordGroups($witnessTokens//w)
         return
            for $w in $witnessTokens/w[normalize-space()]
            let $tText:= string-join(local:w-children($w/node(), $ab/@xml:id/string()),'')
            let $rText := array {
               if ($w/@xml:id = $wGroups[self::keep]/@xml:id) then 
                  string($wGroups[self::keep][@xml:id = $w/@xml:id])
               else if ($w/@xml:id = $wGroups[self::omit]/@xml:id) then 
                  '--'
               else if ($w/*/expan) then
                  tokenize($w/*/expan/text(), '\s+')
               else if ($w/*/reg) then
                  $w/*/reg
               else
                  $tText }         
            return (
               if (string($tText)) then 
               (let $tMap:=
               (: want to make sure we avoid possible empty n values:)
               (: if n would otherwise be empty we use the first character of t :)
               (: also want to add suffix -h1 or -h2 to ids in order to disambiguate:)
                  map {"t":  $tText ,
                     "n" :  if (normalize-space(local:regHebr($rText?1))) then local:regHebr($rText?1) else substring($tText,1,1),
                     "id" : if ($w/self::w/@resp) then concat($w/@xml:id/string(),'-',$w/@resp/string()) else $w/@xml:id/string()} 
               let $respMap:= 
                  if ($w/self::w/@resp) then
                     map {"resp": $w/@resp/string()}
                  else ()
               let $expMap:= 
                  if ($w/*/expan) then 
                     map {"expan" : string-join($w/*/expan/text(),' ')} 
                  else () 
               let $wGrpMap:= if ($w/@xml:id = $wGroups[self::keep]/@xml:id) then 
                  map {"wGrp" : $rText?1}
               else 
                  ()
               return 
               (:morph:pseudoMorph() adds pseudo morphological data for grouping :)
               let $tokens:= if (contains($wGrpMap?wGrp,'_')) then $wGrpMap?wGrp else $tMap?t
               let $expans:= if ($expMap?expan) then $expMap?expan else ''
               return
                  map:merge(($tMap, 
                     $respMap, 
                     $expMap, 
                     $wGrpMap,
                     if (not($rText = '--')) 
                        then
                        (: get pseudomorphological analysis of tokens and expans; j = json output, x = xml output :)
                        morph:pseudoMorph($tokens,$expans,"j") 
                     else ())),
                  if (array:size($rText) > 1)
                     then
                        for $i in 2 to array:size($rText)
                        return
                        map{ "t" : "--",
                           "n" : local:regHebr($rText($i)),
                           "id" : concat($w/@xml:id, '-', string($i))}
                  else
                        () ) else ()
            )
                  }}}
};


let $noComm := for $ab in $nodes
(: get only ws and string that is not between comm span and anchor:)
(: instead do this after? or don't use global variable? :)
return
   (: Do we need to include $addIDs? :)
   
   if (((: $addIDs[@xml:id = $ab/@xml:id] |:) $commIDs[@xml:id = $ab/@xml:id])/*) then
      <ab xml:id="{$ab/@xml:id}">{
            local:omitComms($ab)
         }</ab>
   else
      $ab
   return 
   
     (: process as json :)
         let $array as map(*) := local:buildJSON($noComm)
         return $array
       



