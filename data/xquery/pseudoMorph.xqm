xquery version "3.1";
module namespace morph = "http://www.digitalmishnah.org/morph";
(:declare namespace morph = "http://www.digitalmishnah.org/morph";
:)
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace local = "http://mylocalfunctions.uri";
(:declare option output:method "json";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:media-type "application/json"; :)

(:declare option output:method "xml";:)
import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm";

(: nb: :)
(: initial aleph treated as part of base: much more common in this form :)
(: initial heh treated as article (grouped with prepostions); again more common in this form :)
(: simple final mem/nun is treated as inflexional rather than pronominal:)
(: simple final heh is treated as part of base; but [yod/waw]-heh is in pron suffix :)
(: could change this but would mean testing subgroups; not sure it is worth the gains :)
declare variable $morph:hasWaw := "^(ו)";
declare variable $morph:hasPrepArt := "^((ה)|(של?)|(ב)|(כשה?)|(כ)|(לכש)|(ל)|(מש)|(מה?))";
declare variable $morph:hasInflPref := "^[תימנ]";
declare variable $morph:hasInflSuff := "((נו)|(תי)|(ת)|(תה)|(ת[מם])|(ת[נן])|(נה)|(ו?ן)|(י?ים)|(י?ין)|([םן])|(ות)|(ו))$";
declare variable $morph:hasPronSuff := "((ני)|(נך)|(ך)|(ניך)|(יך)|(נו)|(נכם)|(כם)|(נכן)|(כן)|(נ[םן])|(ה[םן])|(נה)|(נוה)|(הו?)|(י))$";


declare function local:binary-match-and-nonMatch($str as xs:string, $pattern as xs:string) as element()+
(:could be done as array :)
(:inspired by functx:get-matches-and-non-matches but condensed for these purposes:)
{
   let $remainder := if (matches($str, $pattern)) then
      replace($str, $pattern, '')
   else
      $str
   let $matchLength := string-length($str) - string-length($remainder)
   let $matchIndex :=
   (:directly borrowed from functx:index-of-match-first:)
   if ($matchLength > 0) then
      string-length(tokenize($str, $pattern)[1]) + 1
   else
      -1
   return
      (<match>{
            if ($matchLength > 0) then
               substring($str, $matchIndex, $matchLength)
            else
               ''
         }</match>,
      <nonmatch>{$remainder}</nonmatch>)
};

declare function local:checkOrthEndings($endStr as xs:string, $concatStr as xs:string) as xs:string
{
   if (matches($concatStr, "ן$")) then
      concat($endStr, '&amp;ם')
   else if (matches($concatStr, "א$")) then
         concat($endStr, '&amp;ה')
   else if (matches($concatStr, "יה$")) then
            concat($endStr, '&amp;אה')
   else if (matches($concatStr, "אי$")) then
               concat($endStr, '&amp;יי')
   else
               $endStr
};
declare function local:parseStr($str as xs:string) as element()* {
   let $conj := local:binary-match-and-nonMatch($str, $morph:hasWaw)
   let $prepArt := local:binary-match-and-nonMatch($conj[2], $morph:hasPrepArt)
   let $inflPref := local:binary-match-and-nonMatch($prepArt[2], $morph:hasInflPref)
   let $pronSuff := local:binary-match-and-nonMatch($inflPref[2], $morph:hasPronSuff)
   let $inflSuff := local:binary-match-and-nonMatch($pronSuff[2], $morph:hasInflSuff)
   
   let $base := $inflSuff[2]
   return
      (: commented elements are for alternative segmented analysis :)
      (<conj>{string($conj[1])}</conj>,
      <prep>{string($prepArt[1])}</prep>,
      (:<inflPref>{string($inflPref[1])}</inflPref>,
      <base>{
            if (not($pronSuff[1][string(.)]) and not(($inflSuff[1][string(.)])))
            then
               local:checkOrthEndings(string($base), string($base))
            else
               string($base)
         }</base>,:)
      <base>{
            concat(string($inflPref[1]),
            if (not($pronSuff[1][string(.)]) and not(($inflSuff[1][string(.)])))
            then
               local:checkOrthEndings(string($base), string($base))
            else
               string($base))
         }</base> (:,
      <inflSuff>{
            if (normalize-space($inflSuff[1]) and not($pronSuff[1][string(.)]))
            then
               local:checkOrthEndings(string($inflSuff[1]), concat(string($base), string($inflSuff[1])))
            else
               string($inflSuff[1])
         }</inflSuff>,
      <pronSuff>{
            if (normalize-space(string($pronSuff[1])))
            then
               local:checkOrthEndings(string($pronSuff[1]), concat(string($base), string($inflSuff[1]), string($pronSuff[1])))
            else
               ''
         }</pronSuff>:),
      <suff>{
            if (normalize-space(string($pronSuff[1])) or normalize-space($inflSuff[1])) then
               local:checkOrthEndings(concat(string($inflSuff[1]), string($pronSuff[1])), concat(string($base), string($inflSuff[1]), string($pronSuff[1])))
            else
               ''
         }</suff>)
};

declare function local:make-defective($str as xs:string) as xs:string
{
   let $nvStr := if (string-length(translate($str, '""''&#x5f3;&#x5f4;', '')) <= 3) (: remove apostrophe, geresh for testing:)
   then
      let $first:= substring($str, 1, 1)
      let $remainder := translate(substring($str,2),'יו','')
      return concat($first,$remainder)
   else
      concat(substring($str, 1, 1),
      translate(replace(replace(replace(replace($str, '^(.)([\p{IsHebrew}&#x22;&#x27;]+?)(.)$', '$2'), 'יי', 'A'), 'וו', 'B'), '[יו]', ''), 'AB', 'יו'),
      substring($str, string-length($str), 1))
   return
      $nvStr
};

declare function local:do-single-or-group($in as xs:string, $type as xs:string) as element()*{
   let $name:= concat($type,'Grp')
   return
   if (string-length(translate($in,'_ ','')) < string-length($in)) then
      element {$name} {
            for $t in tokenize($in, if ($type = 'token') then '_' else ' ')
            return
               element {$type} {
                  <plene>{local:parseStr($t)}</plene>,
                  <defective>{local:parseStr(local:make-defective($t))}</defective>
               }
         }
   else element {$type}{
         <plene>{local:parseStr($in)}</plene>,
         <defective>{local:parseStr(local:make-defective($in))}</defective>}
      
};

declare function local:toJSON ($seq as element()+) as item()* {
   for $e in $seq return
   typeswitch ($e)
      case element(tokenGrp) return  if ($e/normalize-space()) then map{name($e) : local:toJSON($e/*)} else ()
      case element(expanGrp) return  if ($e/normalize-space()) then map{name($e) : local:toJSON($e/*)} else ()
      case element(expan) return  if ($e/normalize-space()) then map{name($e) : local:toJSON($e/*)} else ()
      case element(token) return if ($e/normalize-space()) then map{name($e) : array{local:toJSON($e/*)}} else ()
      case element(plene) return if ($e/normalize-space()) then map{name($e) : array{local:toJSON($e/*)}} else ()
      case element(defective) return if ($e/normalize-space()) then map{name($e) : array{local:toJSON($e/*)}} else ()
      default return for $el in $e[normalize-space()] return map{name($el) : string($e)} (:if ($e[self::conj|self::pref|self::base|self::suff]) then map{name($e) : string($e)} else ():)
      
      (:let $out := map{string($label) : array{
      for $e in $seq[normalize-space()] return map{name($e) : string($e)}
      }
   }
   return $out:)
   
};

declare function morph:pseudoMorph($tokens as xs:string, $expans as xs:string, $type as xs:string){
   let $out:=
   (local:do-single-or-group($tokens,'token'),
   if (normalize-space($expans)) then local:do-single-or-group($expans,'expan') else ())

   let $outJson:= local:toJSON($out)
     return
     if ($type = "x") then 
         <morph>{$out}</morph>
     else if ($type ="j") then
      serialize(map{"morph" : $outJson},<output:serialization-parameters>
               <output:method>json</output:method>
           </output:serialization-parameters>)
     else <error/>

};

(:(\: main query/function :\)
let $str := "ואע""פ"
let $expan := "ואף על פי"
let $output:= "x"

return morph:pseudoMorph($str,$expan,$output)
:)  

