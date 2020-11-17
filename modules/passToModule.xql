xquery version "3.1";

import module namespace config = "http://www.digitalmishnah.org/config" at "config.xqm";
import module namespace ws2j = "http://www.digitalmishnah.org/ws2j" at "w-sep-to-json-new.xqm";

declare namespace pt = "http://www.digitalmishnah.org/pt";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:method "json";:)
(:declare option output:media-type "application/json";:)
declare option output:method "text";
declare option output:media-type "text/javascript";

declare variable $mCite as xs:string :=  request:get-parameter('mcite', '3.1.14.4');
declare variable $wits as item()* := request:get-parameter('wits', 'all');
declare variable $algo as xs:string* := request:get-parameter('algo','nw');

ws2j:getTokenData($mCite,$wits,$algo)