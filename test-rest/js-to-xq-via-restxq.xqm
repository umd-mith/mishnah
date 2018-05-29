xquery version "3.1";
module namespace rst='http://rest-to-xq.org';
import module namespace console="http://exist-db.org/xquery/console";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:method "xml";:)
(:declare option output:media-type "application/xml";:)

declare
  %rest:path("/js-to-xq-via-restxq")
  %rest:consumes("application/xml")
  %rest:POST("{$data}")
  %output:method("html") 
function rst:echo($data) {
   let $input := string($data/test)
   let $response := <span>{string($data/test)}</span>
   return (
   console:log ($input), 
   $response)};


