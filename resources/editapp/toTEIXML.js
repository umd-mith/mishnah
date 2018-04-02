function toTEIXML(json_data){
    var TEI_head = '<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>\n'
        +'<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>\n'
        +'<TEI xmlns="http://www.tei-c.org/ns/1.0">\n'
        +'  <teiHeader>\n'
        +'    <fileDesc>\n'
        +'        <titleStmt>\n'
        +'            <title>Title</title>\n'
        +'        </titleStmt>\n'
        +'        <publicationStmt>\n'
        +'            <p>Publication Information</p>\n'
        +'        </publicationStmt>\n'
        +'        <sourceDesc>\n'
        +'            <p>Information about the source</p>\n'
        +'        </sourceDesc>\n'
        +'    </fileDesc>\n'
        +'  </teiHeader>\n'
        +'  <text>\n'
        +'    <body>\n'
        +'        <ab>\n';
    var TEI_foot = '        </ab>\n'
        +'    </body>\n'
        +'  </text>\n'
        +'</TEI>';
    var TEI = TEI_head;
    json_data.table.forEach(function(w){
        TEI += "          <app ";
        var groups = {}
        // w always has only one key
        var word_id = Object.keys(w)[0];
        TEI += 'xml:id="app.'+word_id+'">\n';
        var rdgs = w[word_id];
        rdgs.forEach(function(rdg, i){
            if (rdg.length > 0){
                var grp = rdg[0].group
                var cnt = {ptr: [], wit:json_data.witnesses[i] };
                rdg.forEach(function(token){
                  cnt.ptr.push(token.id)  
                })
                if (groups.hasOwnProperty(grp)) {groups[grp].push(cnt)}
                else groups[grp] = [cnt]
            }
            else {
                var cnt = {wit: json_data.witnesses[i]};
                if (Object.hasOwnProperty("empty")) {groups["empty"].push(cnt)}
                else groups["empty"] = [cnt]
            }
        })
        Object.keys(groups).forEach(function(n){
            TEI += '            <rdgGrp n="'+n+'">\n';
            groups[n].forEach(function(rdg){
                TEI += '               <rdg wit="#'+rdg.wit+'">\n';
                if (rdg.hasOwnProperty("ptr")) {
                    rdg.ptr.forEach(function(p){
                        TEI += '                  <ptr target="#'+p+'"/>\n'    
                    })                                        
                }
                TEI += '               </rdg>\n';
            });
             TEI += '            </rdgGrp>\n';
        });
        TEI += "          </app>\n";
    })
    TEI += TEI_foot;
    return TEI;
}