
xquery version "3.1";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace util = "http://exist-db.org/xquery/util";

let $in := parse-json(util:binary-to-string(request:get-data()))

return
   <TEI
      xmlns="http://www.tei-c.org/ns/1.0">
      <teiHeader>
         <fileDesc>
            <titleStmt>
               <title>Edited Collation of Mishnah {replace(map:keys($in?table(1)), '.1$', '')}</title>
            </titleStmt>
            <publicationStmt>
               <p>Publication Information</p>
            </publicationStmt>
            <sourceDesc>
               <p>Information about the source</p>
            </sourceDesc>
         </fileDesc>
      </teiHeader>
      <text>
         <body>
            <ab
               xml:id="app.{replace(map:keys($in?table(1)), '.1$', '')}">{
                  for $data in $in("table")
                  return
                     for $table in $data
                     return
                        for $cols in $table
                        (: $cols an array of col  :)
                        return
                           for $col in $cols?*
                           (: $col is a map with the id as key :)
                           return
                              let $i := map:keys($col)
                              return
                                 <app
                                    xml:id="app.{map:keys($col)}">{
                                       for $cells in $col?*
                                       (: $cells is an array of maps and/or of an array of maps    :)
                                       return
                                          let $gNo := distinct-values(for $i in $cells?*
                                          return
                                             if (exists($i?*)) then
                                                $i(1)("group")
                                             else
                                                ())
                                          return
                                             (for $n in $gNo
                                             return
                                             (:do we have to do this twice?:)
                                                <rdgGrp
                                                   n="{$n}">
                                                   {
                                                      for $rdgs in $cells?*
                                                         where (exists($rdgs?*) and $rdgs(1)("group") = $n)
                                                      return
                                                         <rdg
                                                            wit="{substring-before($rdgs(1)("id"), '.')}">{
                                                               for $tkn in $rdgs?*
                                                               return
                                                                  <ptr
                                                                     target="#{$tkn("id")}"></ptr>
                                                            }</rdg>
                                                   }
                                                </rdgGrp>,
                                             (:now deal with empties:)
                                             let $wits := for $i in $in("witnesses")?*
                                             return
                                                substring-after($i, '-')
                                             let $ids := for $rdgs in $cells?*
                                                where (exists($rdgs?*))
                                             return
                                                substring-before($rdgs(1)("id"), '.')
                                             return
                                                if (count($wits) != count($ids)) then
                                                   <rdgGrp
                                                      n="empty">{
                                                         for $wit in $wits
                                                         return
                                                            if ($wit = $ids) then
                                                               ()
                                                            else
                                                               <rdg
                                                                  wit="{$wit}"/>
                                                      }</rdgGrp>
                                                else
                                                   ()
                                             )
                                    }</app>
               
               }</ab>
         </body>
      </text>
   </TEI>
