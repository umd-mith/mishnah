xquery version "3.1";

declare namespace test = "http://www.digitalmishnah.org/test";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";


import module namespace console="http://exist-db.org/xquery/console";


let $mcite := "4.2.5.1"
let $wits := "S07397,S07326,S00651,S00483,S01520,S08174,P00001,P179204,S07319,S08010,P00002,S07204,S07106,S07394"
let $src := doc("/db/digitalmishnah-tei/mishnah/collations/4.2.5.1.xml")
let $xsl := doc("/db/apps/digitalmishnah/xsl/teiAppToAppView.xsl")
let $params := <parameters><param name="mcite" value="{$mcite}"/>
<param name="wits" value="{$wits}"/>
    <param name="data-root" value="/db/digitalmishnah-tei"/>
</parameters>

return
<out>{transform:transform($src,$xsl,$params)}</out>
 
