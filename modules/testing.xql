xquery version "3.1";

declare namespace test = "http://www.digitalmishnah.org/test";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm";



import module namespace console = "http://exist-db.org/xquery/console";


let $mcite := "4.2.5.1"
let $wits := "S07397,S07326,S00651,S00483,S01520,S08174,P00001,P179204,S07319,S08010,P00002,S07204,S07106,S07394"
let $src := <src>{
      doc("//exist/digitalmishnah-tei/mishnah/collations/4.2.5.1.xml"),
      for $w in tokenize($wits, ',')
      return
         doc(concat($config:data-root, 'mishnah/w-sep/', $w, '-w-sep.xml'))/id(concat($w, '.', $mcite))
   }</src>
let $xsl := doc(concat($config:app-root, "/xsl/teiAppToApparatus.xsl"))
let $params :=
<parameters>
   <param
      name="mcite"
      value="{$mcite}"/>
   <param
      name="wits"
      value="{$wits}"/>
</parameters>
let $attribs := <attributes>
   <attribute name="http://saxon.sf.net/feature/optimizationLevel" value="0"></attribute>
</attributes>

return
   
   transform:transform($src, $xsl, $params, $attribs, ())
   (:for $w in tokenize($wits,',') return doc(concat($config:data-root,'mishnah/w-sep/', $w, '-w-sep.xml'))/id(concat($w, '.', $mcite)):)

