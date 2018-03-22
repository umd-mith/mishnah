xquery version "3.1";

module namespace ws2j = "http://www.digitalmishnah.org/ws2j";

(: 
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

declare boundary-space strip;
declare namespace tei = "http://www.tei-c.org/ns/1.0";
(:declare namespace local = "http://www.digitalmishnah.org/ws2j";:)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:method "txt";:)
(::)
(:declare option output:method "json";:)
(:declare option output:media-type "application/json";:)


import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace morph = "http://www.digitalmishnah.org/morph" at "pseudoMorph.xqm";


declare function ws2j:nodes ($mCite as xs:string, $witNames as xs:string*) as element()+ {
for $witName in $witNames
   return
      let $extract := doc(concat($config:data-root, '/mishnah/w-sep/', $witName, '-w-sep.xml'))//tei:ab[@xml:id = concat($witName, '.', $mCite)]
      return
      ws2j:copy($extract/*/parent::*)
      
};

(: makes a local copy to avoid traversing the whole document for processing:)
declare function ws2j:copy($n as node()*) as node()* {
   typeswitch ($n)
      case $e as element()
         return
            element {name($e)}
            {
               $e/@*,
               for $c in $e/(* | text())
               return
                  ws2j:copy($c)
            }
      default
         return
            $n
};

declare function ws2j:addIDs($nodes as element()+) as element()* {
for $ab in $nodes[.//addSpan[not(@type eq "comm")]]
(: abs that have additions :)
return
  
   <list
      xml:id="{$ab/@xml:id}">{
         for $val in $ab//addSpan[not(@type eq "comm")]
         return
            <val>{substring-after($val/@spanTo/string(), '#')}</val>
      }</list>

};

declare function ws2j:delIDs($nodes as element()+) as element()* {
for $ab in $nodes[.//delSpan]
(: abs that have deletions :)
return
   <list
      xml:id="{$ab/@xml:id}">{
         for $val in $ab//delSpan
         return
            <val>{substring-after($val/@spanTo/string(), '#')}</val>
      }</list>
};


declare function ws2j:commIDs($nodes as element()+) as element()* {
for $ab in $nodes[.//addSpan[@type eq "comm"]]
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

};


declare function ws2j:textToFilter ($nodes as element()+) {
  (: text nodes that fall between add or comm start/end tags:)
  let $addIDs := ws2j:addIDs($nodes)
  let $delIDs := ws2j:delIDs($nodes)
  let $commIDs:= ws2j:commIDs($nodes)
let $filtered :=
  (: For text nodes had to do this by position in document rather than sets:)
  let $ab := $nodes[.//*[self::tei:anchor[@type = 'comm' or @type = 'add' or @type="del"]]]
  return
     <filtered
        xml:id="{$ab/@xml:id}">
        {
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
   return $filtered
};

declare function ws2j:filter-w-set($w-set as node()*, $case as xs:string) as node()* {
   (: Filters w elements, removing those wholly within the bounding add or del span and anchor tags :)
   (: More efficient than for loop evaluating each w? :)
   (: use global variable :)
   let $addIDs:= ws2j:addIDs($w-set)
   let $delIDs:= ws2j:delIDs($w-set)
   let $commIDs:= ws2j:commIDs($w-set)
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


declare function ws2j:w-children($wChild as node()+, $id as xs:string) as item()* {
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
                  ws2j:w-children($n/abbr/node(), $id)
               else
                  if ($n/orig) then
                     ws2j:w-children($n/orig/node(), $id)
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

declare function ws2j:filterTextNodes($t as text(), $id as xs:string, $case as xs:string) as item()* {
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

declare function ws2j:regHebr($str as xs:string) as xs:string {
   (: latter borrowed from XSLT version. Better way of doing this? :)
   let $out := translate(translate(translate(replace($str, 'א$', 'ה'), 'ם', 'ן'), '|יו?', ''),'_','')
   return
      if ($out = '') then
         translate($str, ' ', '')
      else
         translate($out, ' ', '')
};

declare function ws2j:omitComms($ab as element()+) as node()+
{
   for $elem in $ab/* except ws2j:filter-w-set($ab, 'comm')
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
                                    let $pos := count($n/preceding::node()),
                                       $cases := ws2j:textToFilter($ab)[@xml:id = $ab/@xml:id]/comm/item
                                    return
                                       if (some $endPt in $cases
                                          satisfies ($pos > $endPt/s/text() and $pos < $endPt/e/text())) then
                                          ()
                                       else
                                          replace($n, '[&#xa;\s+]', '')
                                       
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

declare function ws2j:getAddDelRanges($addDelItems as node()+) as node()+ {
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
                  if (ws2j:wdNo($addDelItems[$i]/preceding-sibling::w[1]/@xml:id) != ws2j:wdNo(
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
                  if (ws2j:wdNo($addDelItems[$i]/following-sibling::w[1]/@xml:id) != ws2j:wdNo(
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

declare function ws2j:doAddDel($ab as node()+) as node()+ {
   let $addDel := ws2j:filter-w-set($ab, 'addDel')/.
   return
   
      <ab >{
            $ab/@xml:id,
            let $groups := ws2j:getAddDelRanges($addDel)
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
                     (ws2j:h1h2($addDelGroup, 'h1'),
                     ws2j:h1h2($addDelGroup, 'h2')),
                  if (not($s/following-sibling::*)) then
                     $addDel[number($s)]/following-sibling::*
                  else
                     ()
                  )
         }</ab>
};


declare function ws2j:wdNo($str as xs:string) as xs:integer {
   (:replace($str,'[PS]\d{5}\.\d{1}\.\d{1,2}\.\d{1,2}\.\d{1,2}\.',''):)
   xs:integer(replace($str, '^.+\.(\d+)$', '$1'))
};


declare function ws2j:h1h2($h1h2 as node()*, $resp as xs:string) as item()* {
   for $n in $h1h2
      return
      typeswitch ($n)
         case element(w)
            return
               <w
                  xml:id="{$n/@xml:id}"
                  resp="{$resp}">{
                     ws2j:h1h2($n/node(), $resp)
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

(: for common word groups, variously written in the witnesses get relevant token ids :)
declare function ws2j:wordGroups($wElems as element()*) {
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

declare function ws2j:getTokenData($mcite as xs:string, $wits as xs:string* ){
let $out := 
let $witNames := 
   if (not($wits) or $wits = '' or $wits = 'all') 
   then doc(concat($config:data-root, "/mishnah/ref.xml"))//tei:witness/@xml:id/string() 
   else tokenize($wits,',')
let $nodes  as element()* := ws2j:nodes($mcite, $witNames)
let $commIDs as element()*:= ws2j:commIDs($nodes)
let $addIDs as element()* := ws2j:addIDs($nodes)
let $delIDs as element()* := ws2j:delIDs($nodes)
let $noComm := 
   for $ab in $nodes
      (: get only ws and string that is not between comm span and anchor:)
   (: instead do this after? or don't use global variable? :)
   return
      (: Do we need to include $addIDs? :)
      
      if (((:$addIDs[@xml:id = $ab/@xml:id] |:) $commIDs[@xml:id = $ab/@xml:id])) then
         let $out := <ab xml:id="{$ab/@xml:id}">{$ab}</ab>
               return
               ws2j:omitComms($out)
            
      else
         $ab
return
    map {
        (: possibly parameterize options :)
        "joined" : false(),
        "witnesses" : for $ab in $noComm 
   return 
      map { "id" : substring-before($ab/@xml:id,'.'),
      "tokens" : array {
      let $witnessTokens := 
         if ($addIDs[@xml:id = $ab/@xml:id][node()] | $delIDs[@xml:id = $ab/@xml:id][node()]) then
                  ws2j:doAddDel($ab)
         else
            $ab
      let $wGroups := ws2j:wordGroups($ab//w)
      
       return
            for $w in $witnessTokens/w[normalize-space()]
            let $tText:= string-join(ws2j:w-children($w/node(), $ab/@xml:id/string()),'')
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
                     "n" :  if (normalize-space(ws2j:regHebr($rText?1))) then ws2j:regHebr($rText?1) else substring($tText,1,1),
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
                           "n" : ws2j:regHebr($rText($i)),
                           "id" : concat($w/@xml:id, '-', string($i))}
                  else
                        () ) else ()
            )
        }
      
   }
}   
   return    serialize($out, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>)
   };