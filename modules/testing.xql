xquery version "3.1";

import module namespace cmp="http://www.digitalmishnah.org/templates/compare" at "compare.xql";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace httpc="http://exist-db.org/xquery/httpclient";
import module namespace content="http://exist-db.org/xquery/contentextraction"
    at "java:org.exist.contentextraction.xquery.ContentExtractionModule";
import module namespace app="http://www.digitalmishnah.org/templates"at "app.xql";
    
import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace dm = "org.digitalmishnah" at "getMishnahTksJSON.xql";
import module namespace ws2j = "http://www.digitalmishnah.org/ws2j" at "w-sep-to-json.xqm";

(:import module namespace console="http://exist-db.org/xquery/console";:)

declare namespace tei="http://www.tei-c.org/ns/1.0"; 




  let $url := "http://localhost:8080/exist/apps/digitalmishnah/compare/4.1.2.1/S00483,S07326/synopsis"
         let $compare_path_parts := tokenize($url, "/")
         let $mcite := $compare_path_parts[last()-2]
         let $wits := tokenize($compare_path_parts[last()-1], ',')
         let $mode := $compare_path_parts[last()]
        (: dm:getMishnahTksJSON :)
    
   
      return dm:getMishnahTksJSON($mcite,'S00483,S07326')


    
