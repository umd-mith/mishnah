xquery version "3.1";

(: Hayim Lapin, 7/26/19
 : Fixed some h1h2 problms 
 : Hayim Lapin, 7/23/19
 : Added handling of transpositions
 : Hayim Lapin 8/24/18
 : Updated to improve selection of h1/h2 segments
 : better output of resultant w elements
 : Hayim Lapin 4/9/18
 : Updated to integrate into app.
 : Fixed residual issues in how tokens treated
 : Hayim Lapin 4/5/2018
 : Revised again to simplify and avoid truncated lists of tokens
 : Also removes morph analysis per conversations with Raff V.
 : Hayim Lapin 3/6/2018 
 : Rewritten to copy nodes of interest to memory, to allow faster processing.
 : Hayim Lapin, 3/1/2018 
 : Adapted to be utilized as module within app
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
module namespace ws2j = "http://www.digitalmishnah.org/ws2j";

import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm"; 
(:  import module namespace morph = "http://www.digitalmishnah.org/morph" at "pseudoMorph.xqm"; :)
  import module namespace console="http://exist-db.org/xquery/console";

declare boundary-space strip;
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace functx = "http://www.functx.com";

(: parameters need to be changed to map from templating function :)
(:declare variable $mCite as xs:string :=  request:get-parameter('mcite', '4.2.6.3');
declare variable $wits as item()* := request:get-parameter('wits', 'S00483');:)
(:declare variable $mCite as xs:string := '4.2.5.1';:)
(:declare variable $wits as item()* := 'all';:)

(:declare variable $m as item()* := if (not($mCite ='')) then $mCite else '2.3.10.3';:)

(:declare variable $witNames as xs:string* := 
   if (not($wits) or $wits = '' or $wits = 'all')
   then doc(concat($config:data-root, "/mishnah/ref.xml"))//tei:witness[@corresp]/@xml:id/string() 
   else tokenize($wits,',');:)


(::::::::::::::::::::::::::::::::::::::::::)
(: These utility functions for revising IDs :)
(:  get tokenized text  :)
declare function functx:pad-integer-to-length
  ( $integerToPad as xs:anyAtomicType? ,
    $length as xs:integer )  as xs:string {

   if ($length < string-length(string($integerToPad)))
   then error(xs:QName('functx:Integer_Longer_Than_Length'))
   else concat
         (functx:repeat-string(
            '0',$length - string-length(string($integerToPad))),
          string($integerToPad))
 } ;
declare function functx:repeat-string
  ( $stringToRepeat as xs:string? ,
    $count as xs:integer )  as xs:string {

   string-join((for $i in 1 to $count return $stringToRepeat),
                        '')
 } ;
(::::::::::::::::::::::::::::::::::::::::::)


declare function ws2j:nodes ($mCite as xs:string, $witNames as xs:string*) as element()+ {
for $witName in $witNames
   return
      let $doc := doc(concat($config:data-root, 'mishnah/w-sep/', $witName, '-w-sep.xml')) return
          (: if instead of try-catch? :)
         if ($doc/id(concat($witName,'.',$mCite))) then
             let $extract := (id(concat($witName, '.', $mCite), $doc))
             let $localCopy := ws2j:copy($extract/*/parent::*) (: why is this axis necessary? :)
             let $transpLists := $doc//tei:transpose[concat('#',@xml:id) = $extract//tei:milestone/@corresp]
            return
            if ($transpLists) then 
                let $transpNodes := ws2j:getTransp($localCopy,ws2j:copy($transpLists))
                    return ws2j:insertTrsToText($localCopy,$transpNodes)
                    (:$transpNodes:)
            else $localCopy
            
         else ()
};


(: makes a local copy to avoid traversing the whole document for processing:)
declare function ws2j:copy($n as node()*) as node()* {
   if ($n) then
   typeswitch ($n)
      case $e as element()
         return
            (:if ($e/name() eq 'note') then ()
            else:) element {name($e)}
            {
               $e/@*,
               for $c in $e/(* | text())
               return
                  ws2j:copy($c)
            }
      default
         return
            $n
   else ()        
};
(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
declare function ws2j:getTransp($nodes as node()+, $transpSets as element()+){
    for $set in $transpSets
    return
    <transpose id="{$set/@xml:id}">{
        (: get the nodes pointed to in the header :)
        let $tgtNodes := for $tgt in $set/*/@target return $nodes/*[@xml:id= substring-after($tgt,'#')]
        return (
        <transpOrder>{$tgtNodes}</transpOrder>,
        <origOrder>{$nodes//*[@xml:id = $tgtNodes/@xml:id]}</origOrder>,
        if ($tgtNodes[self::anchor]) then 
            for $anch in $tgtNodes[self::anchor] 
            return
                <group id="{$anch/@xml:id}">{
                    let $milest := $anch/preceding::milestone[contains(@spanTo,$anch/@xml:id)]
                    return
                        $milest/following-sibling::node() intersect $anch/preceding-sibling::node()
                }</group>
        else ()
        )
        }</transpose>
};

declare function ws2j:insertTrsToText($extract as node()+,$transpNodes as element()+ ){
    (:for $nodes in $transpNodes return:)
    for $n in $extract return
        (: parent node :)
        if ($n[self::ab]) 
        then 
        <ab>{$n/@*,ws2j:insertTrsToText($n/*,$transpNodes)}</ab>
        (: beginnings and ends of virtual seg or w containing transposition :)
        else if (substring-after($n[self::milestone]/@corresp,'#') = $transpNodes[1]/@id) 
        (: the milestone element starting a transposition :)
        then 
            () (:omit:)
        else if (
                   $n[self::anchor]/preceding-sibling::milestone[@spanTo = concat('#',$n/@xml:id)] intersect 
                   $n/preceding-sibling::milestone[substring-after(@corresp,'#') = $transpNodes/@id]
                ) 
        (: the anchor element ending a transposition :)           
        then             
             () (:omit:)
        (: need case for finding w with transposed cs :)
        else if (substring-after($n[self::w]/@corresp,'#') = $transpNodes[1]/@id)
        (: assume w with a corresp pointing to listTranspose :)
        (: recurse for contents of w :)
            then <w>{$n/@*, ws2j:insertTrsToText($transpNodes, $n/node())}</w> 
        
        else if ($n[self::w|self::c][. = $transpNodes//origOrder/*[self::w|self::c]])
        (: individual words in a word-level transposition :)
        (: individual chars in a char-level transposition :)
            then 
                let $pos := ws2j:getPos($n, $transpNodes/origOrder)
                return
                    (<milestone unit="transp" subtype="orig" spanTo="{concat('#',$transpNodes/@id,'-orig')}"/>,
                    ws2j:transpUpdateIDs($n,'-orig'),
                    <anchor type="transp" xml:id="{concat($transpNodes/@id,'-orig-',$pos)}"/>,
                    <milestone unit="transp" subtype="repl" spanTo="{concat('#',$transpNodes/@id,'-repl')}"/>,
                    ws2j:transpUpdateIDs($transpNodes/transpOrder/*[$pos],'-repl'),
                    <anchor type="transp" subtype="repl" xml:id="{concat($transpNodes/@id,'-repl')}"/>)
        else if ($n[self::anchor][. = $transpNodes//origOrder/anchor])
        (: end of transpGrp: extended transposition :)
        (: insert original text, ids updated :)
        (: insert modified milestone :)
        (: insert block of transposed ids updated :)
        (: insert modidfied anchor :)
            then 
                let $pos := ws2j:getPos($n, $transpNodes/origOrder) 
                let $pos2 := ws2j:getPos($n, $transpNodes/transpOrder)
                return (
                 ws2j:transpUpdateIDs($transpNodes/group[$pos]/*,'-orig'),
                 <anchor type="transp" subtype="orig" xml:id="{concat($n/@xml:id,'-orig')}"/>,
                 <milestone unit="transp" subtype="repl" spanTo="{concat('#',$transpNodes/group[$pos]/@id,'-repl-',$pos2)}"/>,
                 ws2j:transpUpdateIDs($transpNodes/group[$pos2]/*,'-repl'),
                 <anchor type="transp" subtype="repl" xml:id="{concat($transpNodes/group[$pos2]/@id,'-repl-',$pos)}"/>
                )
        else if ($n[self::milestone]/following-sibling::anchor[contains($n/@spanTo,@xml:id)][. = $transpNodes//origOrder/anchor])
        (: beg of transpGrp: extended transposition :)
            then 
                let $pos := ws2j:getPos($n, $transpNodes/origOrder)
                return (<milestone unit="transp" subtype="orig" spanTo="{concat($n/@spanTo,'-orig')}"/>)
                
        else if ($transpNodes//group/*/@xml:id = $n/@xml:id) 
            (: omit nodes between milestone/anchor to be replaced with in previous step :)
            then ()
        else 
            $n 
};

declare function ws2j:getPos($test as element(), $list as element()+) as xs:integer  {
    let $nodeToTest := 
        if ($test[self::milestone]) 
        then $test/following-sibling::anchor[contains($list/@spanTo,@xml:id)]
        else $test
    return count($list/*[@xml:id = $nodeToTest/@xml:id]/preceding-sibling::*) + 1
};

declare function ws2j:transpUpdateIDs ($in as node()*, $suff as xs:string) {
  for $n in $in return
   typeswitch ($n)
      case $e as element()
         return
            element {name($e)}
            {
               
               if ($e[self::w]) then 
               attribute {'type'} {substring-after($suff,'-')}
               else (),
               $e/@*[name() != 'xml:id'],
               if ($e/@xml:id ) then 
               attribute {'xml:id'} {concat($e/@xml:id, $suff)}
               else (),
               for $c in $e/(* | text())
               return
                  ws2j:transpUpdateIDs($c,$suff)
            }
      default
         return
            $n      
    };
    
  (:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
(: With nodes copied, and transpositions duplicated continue :)
declare function ws2j:filter-w-set($w-set as node()*, $case as xs:string) as node()* {
   (: Filters w elements, selecting that contain or  those wholly within the bounding add or del span and anchor tags :)
   (: More efficient than for loop evaluating each w? :)
   (: use global variable :)
   
   let $filtered :=
   switch ($case)
      case 'comm'
         return
            for $i in distinct-values(for $a in $w-set//anchor[@type='comm']/@xml:id return string($a))
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
      
      case 'del'
         return
            for $i in distinct-values(for $a in $w-set//anchor[@type='del']/@xml:id return string($a))
            return
               let $spans := $w-set/*[self::delSpan][contains(@spanTo, $i)] |
               $w-set//*[self::delSpan][contains(@spanTo, $i)]/ancestor::w |
               $w-set//*[self::delSpan][contains(@spanTo, $i)]/ancestor::w/following-sibling::* |
               $w-set/*[self::delSpan][contains(@spanTo, $i)]/following-sibling::*
               
               let $anchors := $w-set/anchor[@xml:id = $i][not(ancestor::w)] |
               $w-set//anchor[@xml:id = $i]/ancestor::w |
               $w-set//anchor[@xml:id = $i]/ancestor::w/preceding-sibling::* |
               $w-set/anchor[@xml:id = $i]/preceding-sibling::*
               
               return
                  $spans intersect $anchors
      
      case 'add'
         return
         
            for $i in distinct-values(for $a in $w-set//anchor[@type='add']/@xml:id return string($a))
            return
                let $spans := $w-set/*[self::addSpan][contains(@spanTo, $i)] |
               $w-set//*[self::addSpan][contains(@spanTo, $i)]/ancestor::w |
               $w-set//*[self::addSpan][contains(@spanTo, $i)]/ancestor::w/following-sibling::* |
               $w-set/*[self::addSpan][contains(@spanTo, $i)]/following-sibling::*
               
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


declare function ws2j:regHebr($str as xs:string) as xs:string {
   (: latter borrowed from XSLT version. Better way of doing this? :)
   let $out := translate(translate(translate(replace($str, 'א$', 'ה'), 'ם', 'ן'), '|יו?', ''), '_', '')
   return
      if ($out = '') then
         translate($str, ' ', '')
      else
         translate($out, ' ', '')
};


declare function ws2j:h1h2($h1h2 as node()*, $resp as xs:string) as item()* {
   ((:console:log($h1h2),:)
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
               if ($resp = 'h2') then
                  if ($n[@subtype = 'w-sep']) then '*' 
                  else ()
               else ()
         case element(delSpan)
            return
               if ($resp = 'h1') then
                  ((:console:log($n/ancestor::node()),:)
                  if ($n[ancestor::w][@extent]) then 
                     for $i in 1 to xs:integer($n/@extent) return '-' 
                  else if ($n[not(ancestor::w)][@extent]) then
                     <w xml:id="{substring-after($n/@spanTo,'#')}" 
                     resp="h1"
                     type="del">
                     {for $i in 1 to xs:integer($n/@extent) return '-' }</w>
                  else ()
                  )
               else ()
               
         case element(anchor)
            
            return
               if ($n[@type = 'add'] | $n[@type = 'del']) then
                  ()
               else
                  $n
         case element()
            return
               $n
         case text()
            return replace($n, '[&#xa;\s+]', '')
      default
         return
            $n 
        )
};

declare function ws2j:wdNo($str as xs:string) as xs:integer {
   (:replace($str,'[PS]\d+\.\d{1}\.\d{1,2}\.\d{1,2}\.\d{1,2}\.',''):)
   xs:integer(replace($str, '^.+\.(\d+)$', '$1'))
};


declare function ws2j:processWTokens($ab as element()+) as node()+ {
   let $add := ws2j:filter-w-set($ab, 'add')
   let $del := ws2j:filter-w-set($ab, 'del')
   let $addDel := $add union $del
   return
      
      for $items in $ab
      return
         (: starting with first w iterate through and group adjacent add dels:)
         let $firstH1H2 := $items/*[1]
         let $groupedAddDel := ws2j:recurseAddDel($firstH1H2, $addDel)
         (:take grouped elements and differentiate on h1/h2:)
         let $processedAddDel :=
         for $el in $groupedAddDel
         return
            if ($el/name() = 'h1h2') then
               (:process twice:)
               let $h1 := for $w in $el/*
                     return
                     
                        if (ws2j:keepOrSkip($w, 'h1')) then 
                        
                           if ($w[self::w]) then
                             <w resp='h1'>{($w/@*, 
                                for $c in $w/node() return ws2j:keepOrSkip($c, 'h1')) 
                             }</w>
                           else 
                           $w
                        else ()
                    
               let $processedH1 := ws2j:h1h2($h1,'h1')
               let $h2 := for $w in $el/*
                     return
                        if (ws2j:keepOrSkip($w, 'h2')) then
                           if ($w[self::w]) then
                             <w resp='h2'>{$w/@*, 
                             for $c in $w/node() return ws2j:keepOrSkip($c, 'h2') 
                             }</w>
                           else 
                           $w
                      else ()
               let $processedH2 := ws2j:h1h2($h2,'h2')
               return 
               ($processedH1, $processedH2)
            else
               $el
         return
            (
            <ab>{
                  ($items/@*, $processedAddDel)
               }
            </ab>
      )
};

declare function ws2j:keepOrSkip($test as node(),$resp as xs:string) as item()* {
    
    if ($resp = 'h1') 
    then 
        (: $test is between addSpan and anchor :)
        if (some $a in $test/following::anchor/@xml:id
            satisfies some $s in $test/preceding::addSpan/@spanTo
            satisfies contains($s,$a)) 
        then () (: omit :)
        else $test
    else if($resp='h2')
    then 
        (: $test is between delSpan and anchor :)
        if (some $a in $test/following::anchor/@xml:id
            satisfies some $s in $test/preceding::delSpan/@spanTo
            satisfies contains($s,$a))
        then () (: omit :)
        else $test
    else ()
    
};


(: NOT USING ..... :)
declare function ws2j:doWsForH1H2($w as element(w), $resp as xs:string){
    if ($resp = 'h1') 
    then 
        (: omit any additions that are the whole of the $w, include any deletions :)
        (: $w is between addSpan and anchor :)
        if (some $a in $w/following::anchor[@type='add']/@xml:id
            satisfies some $s in $w/preceding::addSpan[@type='add']/@spanTo
            satisfies contains($s,$a)) 
        then () 
        (: $w contains anchor in last position, but no span preceded by text :)
        else if (not(some $a in $w/anchor[@type='add'][not(following-sibling::node()/normalize-space())]/@xml:id 
            satisfies some $s in $w/addSpan[@type='add']/@spanTo
            satisfies contains($s,$a)))
        then ()   
        (: $w contains span in first position, but no anchor :)
        else if (not(some $s in $w/addSpan[@type='add'][not(preceding-sibling::node()/normalize-space())]/@spanTo
            satisfies some $a in $w/anchor[@type='add']/@xml:id 
            satisfies contains($s,$a)))
        then ()
        else
        <w resp="{$resp}">{($w/@xml:id, $w/node())}</w>
    else if ($resp = 'h2') 
        then 
        if (some $a in $w/following::anchor[@type='del']/@xml:id
            satisfies some $s in $w/preceding::delSpan/@spanTo
            satisfies contains($s,$a))
        then ()
        (: $w contains anchor in last position, but no span preceded by text :)
        else if (not(some $a in $w/anchor[@type='del'][not(following-sibling::node()/normalize-space())]/@xml:id 
            satisfies some $s in $w/addSpan[@type='del']/@spanTo
            satisfies contains($s,$a)))
        then ()   
        (: $w contains span in first position, but no anchor :)
        else if (not(some $s in $w/addSpan[@type='del'][not(preceding-sibling::node()/normalize-space())]/@spanTo
            satisfies some $a in $w/anchor[@type='del']/@xml:id 
            satisfies contains($s,$a)))
        then ()   else <w resp="{$resp}">{($w/@xml:id, $w/node())}</w>
        (: omit any deletions, include any additions :)
    else ()
};

(: Exist does not support grouping in xq :)
(: These two functions borrow from a method for positional grouping by Michael Kay :)
(: Iterates w by w testing if should be grouped :)
declare function ws2j:recurseAddDel($w as element()?, $addDel as element()*) as element()* {
   let $next := $w/following-sibling::*[1]
   return
      
      if ($w) then
         if ($addDel intersect $w) then
            (: start a group :)
            ( 
            <h1h2>{$w, ws2j:groupAddDel($w, $addDel)}</h1h2>,
            ws2j:recurseAddDel($w/following-sibling::*[not(. intersect $addDel)][1], $addDel)
            )
         else
            (: do not start a group, just keep going :)
            ($w, ws2j:recurseAddDel($next, $addDel))
      else
         ()
};

(: Adds to group as necessary  :)
declare function ws2j:groupAddDel($w as element()?, $addDel as element()*) as element()* {
    let $next := $w/following-sibling::*[1]
    return 
   if ($w)  
   then   
        ((:console:log('continue group: '),:)
         if ($next intersect $addDel) then ((:console:log($next),:)$next, ws2j:groupAddDel($next, $addDel))
           else ()
                 )
   else ()         
};


declare function ws2j:w-children($wChild as node()+, $id as xs:string) as item()* {
   (: $id is not necessary --remove? :)
   for $n in $wChild
   return
      typeswitch ($n)
         case text()
            return
               if (not(normalize-space($n))) then
                  ()
               else if (some $s in $n/following::anchor[@type = 'comm']/@xml:id
                     satisfies $n/preceding::*[contains(@spanTo, $s)]) then
                     (: checking for residual comment strings that might be within w :)
                     ()
               else if ($n/parent::expan) then
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
         case element(span) 
             (: necessary for case of unclear, esp reason="writ" :)
             return
               ()
         case element(gap)
            return
               ()
         case element(anchor)
            return
               if ($n/@type='add' or $n/@type='del' or $n/@type='comm') then $n
               else ()
         case element(c)
            return
               (:(\: not sure what this is supposed to do :\)
               if ($n/preceding-sibling::node()[1][self::c]) then (1)
               else ():)
               $n/text()
         case element(am)
            return
               (:replace($n/text(), '\s+', ''):)
               $n/text()
               
         case element(lb)
            (: replace typographically if it appears within a word:)
            return
               text {'|'}
               
         case element()
            (: remove all other elements :)
            return
               ()
         default
            return
               ()
}
;


(: for common word groups, variously written in the witnesses get relevant token ids :)
declare function ws2j:wordGroups($wElems as element()*) {
   for $w in $wElems
   (: identify the text of this w as well as 1, 2, [3] following :)
   let $this :=
   if ($w/expan) then
      $w/expan
   else
      if ($w/reg) then
         $w/reg/text()
      else
         $w/text()
   let $thisPlus1 := if ($w/following-sibling::w[1]/expan) then
      $w/following-sibling::w[1]/expan
   else
      if ($w/following-sibling::w[1]/reg) then
         $w/following-sibling::w[1]/reg
      else
         $w/following-sibling::w[1]/text()
   let $thisPlus2 :=
   if ($w/following-sibling::w[2]/expan) then
      $w/following-sibling::w[2]/expan
   else
      if ($w/following-sibling::w[2]/reg) then
         $w/following-sibling::w[2]/reg
      else
         $w/following-sibling::w[2]/text()
         (:  :)
   let $joined2 := normalize-space(string-join($this | $thisPlus1))
   let $joinedOut2 := normalize-space(string-join($this | $thisPlus1, '_'))
   let $joined3 := normalize-space(string-join($this | $thisPlus1 | $thisPlus2))
   let $joinedOut3 := normalize-space(string-join($this | $thisPlus1 | $thisPlus2, '_'))
   
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
      else
         if (matches($this, '^.?אי?ז[הו]{1,2}[וי]א?$'))
         then
            ()
         else
            if (matches($joined2, '^.?אי?ז[הו]{1,2}[וי]א?$'))
            then
               (<keep
                  
                  xml:id="{$w/@xml:id}">{$joinedOut2}</keep>,
               <omit
                  
                  xml:id="{$w/following-sibling::w[1]/@xml:id}"/>)
            else
               if (matches($joined3, '^.?אי?ז[הו]{1,2}[וי]א?$'))
               then
                  (<keep
                     
                     xml:id="{$w/@xml:id}">{$joinedOut3}</keep>,
                  <omit
                     
                     xml:id="{$w/following-sibling::w[1]/@xml:id}"/>,
                  <omit
                     
                     xml:id="{$w/following-sibling::w[2]/@xml:id}"/>)
               else
                  if (matches($joined2, '^כא?יצד$|^כא?יזהצד$'))
                  then
                     (<keep
                        
                        xml:id="{$w/@xml:id}">{$joinedOut2}</keep>,
                     <omit
                        
                        xml:id="{$w/following-sibling::w[1]/@xml:id}"/>)
                  else
                     if (matches($joined3, '^כא?יצד$|^כא?יזהצד$'))
                     then
                        (<keep
                           
                           xml:id="{$w/@xml:id}">{$joinedOut3}</keep>,
                        <omit
                           
                           xml:id="{$w/following-sibling::w[1]/@xml:id}"/>,
                        <omit
                           
                           xml:id="{$w/following-sibling::w[2]/@xml:id}"/>
                        )
                     else
                        if (matches($joined2, '^ו?לפי?כך$'))
                        then
                           (<keep
                              
                              xml:id="{$w/@xml:id}">{normalize-space(string-join($this | $thisPlus1, '_'))}</keep>,
                           <omit
                              
                              xml:id="{$w/following-sibling::w[1]/@xml:id}"/>)
                        else
                           ()
};

declare function ws2j:splitToken($w as element()) as item()* {
   let $idStub := replace($w/@xml:id,'\d+$','')
   let $abNum := xs:integer(tokenize($w/@xml:id,'\.')[last()])
   let $t := tokenize($w,'\*')
   let $num := count($t)
   return 
      ((:console:log($w),:)
      for $n in 1 to $num 
      return <w>{
         ($w/@resp, attribute xml:id {
            concat($idStub,functx:pad-integer-to-length($abNum + (($n - 1) * 10),5))
         },$t[$n])
      }</w>)
};

declare function ws2j:fixIDsInTokenList($wSequence as element()+) as element()+ {
   (: reassigns IDs for tokens needing special handling :)
   for $ab in $wSequence 
      return <ab xml:id="{$ab/@xml:id}">{
      for $w in $ab/* 
      return
         (: tried with switch statement and kept getting errors. reverted to concatenated if-else :)
         if ($w[self::w[contains(.,'*')]]) then ws2j:splitToken($w)
         else $w
    }</ab>
    
};

declare function ws2j:buildJSON($wSequence as element()+) as map(*){
   map{ 
   (:  could paramterize settings :)
   "joined" : false(),
   "witnesses" : for $ab in $wSequence 
   
   return 
    let $pref := 
         (:adapts functx:index-of-node:) 
         (:is this better than using index-of?:)
            for $seq in (1 to count($wSequence))
            return 
            $seq[$wSequence[$seq] is $ab]
            
         return 
         (
         map { "id" : concat(string(format-number($pref,"000")),'-',substring-before($ab/@xml:id,'.')), 
         "tokens" : array {
         
         let $wGroups := ws2j:wordGroups($ab//w)
             return
                for $w in $ab/w[normalize-space()]
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
                      replace($tText, '[&#xa;\s+]', '') }         
                return (
                   if (string($tText)) then 
                   (let $tMap:=
                   (: want to make sure we avoid possible empty n values:)
                   (: if n would otherwise be empty we use the first character of t :)
                   (: also want to add suffix -h1 or -h2 to ids in order to disambiguate:)
                      map {"t":  $tText ,
                         "n" :  if (normalize-space(ws2j:regHebr($rText?1))) then ws2j:regHebr($rText?1) else substring($tText,1,1),
                         "id" : string-join(($w/@xml:id/string(),$w/@resp/string()),'-')} 
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
                   let $transpMap := 
                      if ($w/@type) then 
                        map{"transp":$w/@type/string()} 
                      else ()
                   return 
                   let $tokens:= if (contains($wGrpMap?wGrp,'_')) then $wGrpMap?wGrp else $tMap?t
                   let $expans:= if ($expMap?expan) then $expMap?expan else ''
                   return
                      map:merge(($tMap, 
                         $respMap, 
                         $transpMap,
                         $expMap, 
                         $wGrpMap
                         (:,
                         if (not($rText = '--')) 
                            then
                            (\: get pseudomorphological analysis of tokens and expans; j = json output, x = xml output :\)
                            morph:pseudoMorph($tokens,$expans,"j") 
                         else ():)
                         )),
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
                      }}
                      )}
};


declare function ws2j:getTokenData($mcite as xs:string, $wits as xs:string*) {
   (: get only ws and string that are not between comm span and anchor:)
   (: instead do this after? :)
   (: get nodes :)
   let $out := 
      let $m := if (not($mcite) or $mcite = '') then '1.1.1.1' else $mcite
      let $witNames  as xs:string* :=
         if (count($wits) > 1) then $wits
         else if (not($wits) or $wits = '' or $wits = 'all') 
            then 
            doc(concat($config:data-root, "/mishnah/index-m.xml"))//tei:ab[@xml:id = concat('index-m.',$m)]/tei:ptr/@n/string() 
         else tokenize($wits,',')
      let $nodes := ws2j:nodes($m, $witNames)
      let $noComm := for $ab in $nodes
      return
         ((:console:log(string-join($witNames,',')),:)           
         <ab
              xml:id="{$ab/@xml:id}">{
                 $ab/* except ws2j:filter-w-set($ab, 'comm')
              }</ab>
              )
        
   (:simplifiy list, removing elements not required for alignment:)
   
   (: get list of tokens with separation of add/del into h1/h2 :)
   let $listOfTokens :=
      for $srcTokens in $noComm
      return
         ws2j:processWTokens($srcTokens)
   return
      (: Needed to do cleanup in second pass. Should be fixed. :)
      let $revListOfTokens := ws2j:fixIDsInTokenList($listOfTokens)
      return
      ws2j:buildJSON($revListOfTokens)
         (: Needed to do cleanup in second pass bec XQ does not nec know preceding or following id :)
      (: Should be fixed.:)
   return
      (:(console:log($out),:)
      serialize(
      $out, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>)   
        (:):)
(:$out:)
};
