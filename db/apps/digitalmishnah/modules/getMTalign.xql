xquery version "3.1";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace dm = "org.digitalmishnah";
declare namespace tei="http://www.tei-c.org/ns/1.0"; 

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

declare function dm:getMTalign($chapter as xs:string) {
    let $align := doc(concat($config:data-root, "/standoff/mtalignment/mtalignment-", $chapter, ".xml"))
    return array {
        for $link in $align//tei:link
        return
            map:merge(
                for $t in tokenize($link/@target)
                return
                    for $ptr in $align//tei:ptr/id(substring-after($t, '#'))
                    group by $isT := contains($ptr/@target, 'ref-t')   
                    return
                        if ($isT) 
                        then map {'t' : tokenize(replace($ptr/@target/data(), '#', ''))}
                        else map {'m' : tokenize(replace($ptr/@target/data(), '#', ''))}
            )
    }
};

dm:getMTalign(request:get-parameter("chapter", ''))