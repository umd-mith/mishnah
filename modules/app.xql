xquery version "3.0";

module namespace app="http://www.digitalmishnah.org/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.digitalmishnah.org/config" at "config.xqm";

(:import module namespace console="http://exist-db.org/xquery/console";:)

declare namespace my="local-functions.uri";
declare namespace tei="http://www.tei-c.org/ns/1.0"; 

(:~
 : This function returns an XML document with grouped list of witnesses.
 : This is not a templating function.
 :)
declare function app:index-compos($unit as xs:string, $mcite as xs:string) {
    let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
    (: let $step1 := transform:transform($input, doc("//exist/apps/digitalmishnah/xsl/index-wit-compos.xsl"), 
                    <parameters>
                       <param name="tei-loc" value="{$config:data-root}/mishnah/"/>
                    </parameters>)
    return transform:transform($step1, doc("//exist/apps/digitalmishnah//xsl/groupFromIndex.xsl"), 
            <parameters>
               <param name="unit" value="{$unit}"/>
               <param name="mcite" value="{$mcite}"/>
            </parameters>):)
    let $out := transform:transform($input, doc("//exist/apps/digitalmishnah/xsl/index-wit-compos.xsl"), 
                    <parameters>
                       <param name="tei-loc" value="{$config:data-root}/mishnah/"/>
                    </parameters>)        
    return $out
};

(:~
 : This templating function generates assets specific to a given page
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 declare function app:page_assets($node as node(), $model as map(*)){
    if ($model("resource") = "align") then
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="$app-root/resources/css/mtjsviewer.css"/>
    else if ($model("resource") = "edit") then
        (<link xmlns="http://www.w3.org/1999/xhtml" href="$app-root/resources/editapp/ngDialog.css" rel="Stylesheet" type="text/css"/>,
		<link xmlns="http://www.w3.org/1999/xhtml" href="$app-root/resources/editapp/ngDialog-theme-default.css" rel="Stylesheet" type="text/css"/>,
		<link xmlns="http://www.w3.org/1999/xhtml" href="$app-root/resources/editapp/angMishnah.css" rel="Stylesheet" type="text/css" />)  
    else if ($model("resource") = "read") then
        (<link xmlns="http://www.w3.org/1999/xhtml" href="$app-root/resources/css/FormattingforHTML.css" rel="Stylesheet" type="text/css"/>,
		<link xmlns="http://www.w3.org/1999/xhtml" href="$app-root/resources/css/demo-styles.css" rel="Stylesheet" type="text/css"/>)
    else if ($model("resource") = "compare") then
        (<link xmlns="http://www.w3.org/1999/xhtml" href="$app-root/resources/css/compare-home.css" rel="Stylesheet" type="text/css"/>,
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/Sortable/1.4.2/Sortable.min.js"></script>)
    else ()
 };
  
(:~
 : This templating function generates a title from a unit number (mcite)
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 declare function app:expand-mcite($mcite as xs:string){
    let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
    let $el := $input//*[@xml:id=concat('ref.', $mcite)]
    let $mcite_parts := tokenize($mcite, '\.')
    let $num := if (count($mcite_parts) = 4) 
                then (concat($mcite_parts[last()-1],'.',$mcite_parts[last()])) 
                else $mcite_parts[last()]
    return concat(
        translate($el/ancestor::tei:div1/data(@n), "_", " "),
        " - ",
        translate($el/ancestor::tei:div2/data(@n), "_", " "),
        " ",
        $num
    )
 };
 
(:~
 : This templating function generates a table of witnesses
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:list_wits($node as node(), $model as map(*)){
    let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
    return
    element table {
    ($node/@*[not(starts-with(name(), 'data-'))],
    for $lw in $input//tei:listWit[tei:witness]
    return (       
        <tr><th colspan="2">{if ($lw/@n) then data($lw/@n) else data($lw/@xml:id)}</th></tr>,
            
        for $w in $lw/tei:witness[@corresp]
        let $source := doc(concat($config:data-root, "/mishnah/", $w/@corresp))
        return
            <tr>
               <td aling="left" valign="middle" style="font-weight:bold; padding-right:5;">
                   <a href="browse/{data($w/@xml:id)}/page/{
                     substring-after(($source//tei:body//tei:pb)[1]/@xml:id,concat($w/@xml:id,'.'))}">{data($w/@xml:id)}</a></td>
               <td>{
                 $w/text()
               }
               (<span style="font-size:75%;">
                   <a href="{concat($config:http-data-root, "/mishnah/", substring-before($w/@corresp, '.xml'))}.xml">TEI/XML</a>
               </span>)
               </td>
           </tr>
        )
    )}
 };

 (:~
 : This templating function generates a reading view for part of a witness
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:read($node as node(), $model as map(*)){
    element div {
        $node/@*[not(starts-with(name(), 'data-'))],
        let $reading_path_parts := tokenize($model("path"), "/")
        let $witness := $reading_path_parts[last() -2]
        let $mode := $reading_path_parts[last() -1]
        let $num := $reading_path_parts[last()]
        let $input := doc(concat($config:data-root, "/mishnah/", $witness, ".xml"))
        let $step1 := transform:transform($input, doc("//exist/apps/digitalmishnah/xsl/extractFromSource.xsl"),
                        <parameters>
                           <param name="mode" value="{$mode}"/>
                           <param name="num" value="{$num}"/>
                        </parameters>)
        let $step2 :=
          if ($mode = 'chapter')
          then transform:transform($step1, doc("//exist/apps/digitalmishnah/xsl/flat-to-pages.xsl"),())
          else $step1
        let $step3 := transform:transform($step2, doc("//exist/apps/digitalmishnah/xsl/pages-to-html.xsl"),
                        <parameters>
                           <param name="mode" value="{$mode}"/>
                           <param name="num" value="{$num}"/>
                           <param name="tei-loc" value="{$config:http-data-root}/mishnah/"/>
                        </parameters>)
        return
            $step3
    }
};

 (:~
 : This templating function generates a reading view for part of a witness
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:read-title($node as node(), $model as map(*)){
    let $witness := tokenize($model("path"), "/")[last() -2]
    let $input := doc(concat($config:data-root, "/mishnah/", $witness, ".xml"))
    return
        <h1>{$input//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()}</h1>
};

(:~
 : This templating function generates a list of witnesses that can be sorted by the user
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
 (: TODO MERGE WITH app:list_wits :)
declare function app:drag_list_wits($node as node(), $model as map(*)) {
    let $input := doc(concat($config:data-root, "/mishnah/ref.xml"))
    return
    element ul {
    ($node/@*[not(starts-with(name(), 'data-'))],
    for $lw in $input//tei:listWit[tei:witness]
    return (
        for $w in $lw/tei:witness[@corresp]
        let $source := doc(concat($config:data-root, "/mishnah/", $w/@corresp))
        return
            <li class="list-group-item wit-item" id="wit-item-{data($w/@xml:id)}" draggable="false">
               <input type="checkbox" class="wit-remove"/>&#160;<strong>{data($w/@xml:id)}</strong>
               <!--<span>&#160;{$w/text()}</span>               
               <span class="wit-info">&#160;({if ($lw/@n) then data($lw/@n) else data($lw/@xml:id)})</span>-->
           </li>
        )
    )}
};

(:~
 : This templating function generates a TOC panel
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:toc($node as node(), $model as map(*), $level as xs:string, $wholechap as xs:boolean) {
    let $tract-compos := app:index-compos("all", "")
    let $index := doc(concat($config:data-root, "/mishnah/index.xml"))
    return
      <div class="panel-group" role="tablist">
       <div class="panel">{
        for $order in $index//my:order
        return (
          <div class="panel-heading" role="tab">
            <div class="panel-title">
              <a href="#{$order/@n}" class="collapsed" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="{string($order/@n)}">{string($order/@n)}  <span class="caret"></span></a>
            </div>
          </div>,
          <div class="panel-collapse collapse" role="tabpanel" id="{$order/@n}" aria-labelledby="{$order/@n}_Heading" aria-expanded="false" style="height: 0px;">
            <ul class="list-group">{
              for $tract in $order/my:tract
              return
                  if (substring-after($tract/@xml:id,'ref.') = $tract-compos//my:tract-compos/@n)
                  then (
                      (: This tractate has chapter children :)
                      <li class="list-group-item">
                        <div class="panel-heading" role="tab">
                          <div class="panel-title">
                            <a href="#{$tract/@n}" class="collapsed" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="{$tract/@n}">{replace($tract/@n,'_',' ')} <span class="caret"></span></a>
                          </div>
                        </div>
                        <div class="panel-collapse collapse" role="tabpanel" id="{$tract/@n}" aria-labelledby="{$tract/@n}_Heading" aria-expanded="false" style="height: 0px;">
                          <ul class="list-group">{
                           for $chap in $tract/my:chapter
                           return
                             if ($level = "mishnah" and substring-after($chap/@xml:id,'ref.') = $tract-compos//my:ch-compos/@n)
                             then 
                                 (: This chapter has mishnah children :)
                                 let $htmlid := replace(substring-after($chap/@xml:id,'ref.'), "\.", "_")
                                 return (
                                 <li class="list-group-item">
                                    <div class="panel-heading" role="tab" >
                                       <div class="panel-title">
                                         <a id="ch_{$htmlid}" href="#{$htmlid}" class="collapsed mishnah_chap" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="{$htmlid}">
                                            Chapter {substring-after($chap/@xml:id, concat($chap/parent::my:tract/@xml:id, '.'))} <span class="caret"></span>
                                          </a>
                                       </div>
                                     </div>    
                                     <div class="panel-collapse collapse" role="tabpanel" id="{$htmlid}" aria-labelledby="{$htmlid}_Heading" aria-expanded="false" style="height: 0px;">
                                        <ul class="list-group">{
                                        if ($wholechap)
                                         then 
                                           <a class="list-group-item nav-link-item mishnah_link mishnah_chap" href="#{substring-after($chap/@xml:id,'ref.')}">Whole Chapter</a>
                                         else (),
                                         for $mish in $chap/my:mishnah
                                         return
                                             if (substring-after($mish/@xml:id,'ref.') = $tract-compos//my:m-compos/@n)
                                             then
                                                 (: This Mishnah has text :)
                                                 <a class="list-group-item nav-link-item mishnah_link" href="#{substring-after($mish/@xml:id,'ref.')}">
                                                     {concat('Mishnah ',substring-after($mish/@xml:id, concat($mish/ancestor::my:tract/@xml:id, '.')))}
                                                 </a>
                                             else
                                              <a class="list-group-item nav-link-item mishnah_link">{concat('Mishnah ',substring-after($mish/@xml:id, concat($mish/ancestor::my:tract/@xml:id, '.')))}</a>
                                        }</ul>
                                     </div>
                                 </li>
                                )
                             else
                                <li class="list-group-item nav-link-item" id="ch_{replace(substring-after($chap/@xml:id,'ref.'), "\.", "_")}">
                                  <a class="mishnah_link mishnah_chap" href="#{substring-after($chap/@xml:id,'ref.')}">
                                     Chapter {substring-after($chap/@xml:id, concat($chap/parent::my:tract/@xml:id, '.'))}
                                  </a>
                                </li>
                      }</ul>
                     </div>
                    </li>)                      
                   else 
                      <a class="list-group-item">{replace($tract/@n,'_',' ')}</a>
          }</ul>
         </div>)
       }</div>
      </div>
};