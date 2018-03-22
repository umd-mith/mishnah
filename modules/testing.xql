xquery version "3.1";

declare namespace temp="http://www.digitalmishnah.org/templates/compare";
import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace httpc="http://exist-db.org/xquery/httpclient";
import module namespace content="http://exist-db.org/xquery/contentextraction"
    at "java:org.exist.contentextraction.xquery.ContentExtractionModule";
import module namespace app="http://www.digitalmishnah.org/templates" at "app.xql";
import module namespace ws2j = "http://www.digitalmishnah.org/ws2j" at "w-sep-to-json.xqm";
import module namespace dm = "org.digitalmishnah" at "getMishnahTksJSON.xql";

(:import module namespace console="http://exist-db.org/xquery/console";:)
 

  
        (: dm:getMishnahTksJSON :)
    
    let $input := ws2j:getTokenData("4.1.1.1", "all") 

    (:let $toJson := serialize($input, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>):)
     let $headers := <headers>
                    <header name="Accept" value="application/json"/> 
                    <header name="Content-type" value="application/json"/>
                </headers>
                let $results := parse-json(
                    content:get-metadata-and-content(
                    httpc:post(xs:anyURI('http://54.152.68.192/collatex/collate'), $input, false(), $headers))
                )
      return $results  


