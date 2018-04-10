xquery version "3.1";

import module namespace ws2j = "http://www.digitalmishnah.org/ws2j" at "w-sep-to-json-new.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0"; 

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";



  let $url := "http://localhost:8080/exist/apps/digitalmishnah/compare/1.1.1.1/S00483,S07326/synopsis"
         let $compare_path_parts := tokenize($url, "/")
         let $mcite := $compare_path_parts[last()-2]
         let $wits := tokenize($compare_path_parts[last()-1], ',')
         let $mode := $compare_path_parts[last()]
        (: dm:getMishnahTksJSON :)
    
   
      return 
          let $array as map(*) := ws2j:getTokenData($mcite,$wits)
         return $array
