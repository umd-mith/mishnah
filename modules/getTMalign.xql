xquery version "3.1";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace dm = "org.digitalmishnah";
declare namespace tei="http://www.tei-c.org/ns/1.0"; 

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

(: this function looks for alignments to a given Tosefta chapter and returns the mapped IDS in a json array
 : The input data in /standoff/mtalignment is structured by Mishnah chapter, so the function first obtains
 : the pointers to the requested Tosefta chapter across the files and then locates the alignment link elements.
:)
declare function dm:getTMalign($chapter as xs:string) {
    let $align := collection(concat($config:data-root, "/standoff/mtalignment"))
    return array {
    for $ptr in $align//tei:ptr[contains(@target, concat('ref-t.', $chapter))   ]
        for $link in $ptr/parent::*/tei:link[contains(@target, $ptr/@xml:id)]
        return
            map:merge(
                for $t in tokenize($link/@target)
                return
                    for $aptr in $align//tei:ptr/id(substring-after($t, '#'))
                    group by $isT := contains($aptr/@target, 'ref-t')   
                    return
                        if ($isT) 
                        then map {'t' : tokenize(replace($aptr/@target/data(), '#', ''))}
                        else map {'m' : tokenize(replace($aptr/@target/data(), '#', ''))}
            )
    }
};

dm:getTMalign(request:get-parameter("chapter", ''))