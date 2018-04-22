

xquery version "3.1";
import module namespace console="http://exist-db.org/xquery/console";

let $in:=json-doc('file:/C:/Users/hlapin/Documents/mishnah/data/xslExternal/4.2.5.1.json')
    return 
        <out>{for $data in $in("table") 
        return 
            for $table in $data 
            return for $cols in $table 
                (: $cols an array of col  :)
                return 
                for $col in $cols?*
(:                $col is a map with the id as key :)
                    return
                    (let $i := map:keys($col) return console:log($i),    
                    <app xml:id="app-{map:keys($col)}">{    
                    for $cells in $col?*
(:                    $cells is an array of maps and/or of an array of maps    :)
                        return 
                        let $gNo := distinct-values(for $i in $cells?* return 
                            if (exists($i?*)) then $i(1)("group") else ())
                            return 
                            for $n in $gNo return 
                                <rdgGrp n="{$n}">
                                    {for $rdgs in $cells?* 
                                        where (exists($rdgs?*) and $rdgs(1)("group") = $n)
                                        return
                                        <rdg wit="{substring-before($rdgs(1)("id"),'.')}" >{
                                            for $tkn in $rdgs?* return
                                            <ptr target="{$tkn("id")}"></ptr>   
                                        }</rdg>    
                                    }
                                </rdgGrp>
                    }</app> 
                    )
        }</out>            
