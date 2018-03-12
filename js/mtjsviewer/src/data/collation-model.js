import * as Backbone from 'backbone';
import $ from 'jquery';
import Variant from './variant-coll.js';

class Collation extends Backbone.Model {
	initialize() {
		let variants = [];
		let data = this.get("data");
        let TEIfiles = this.get("TEIfiles");

        let createReadingData = function(rdg){
            let $rdg = $(rdg);
            let source = $rdg.attr('wit').slice(1);
            let $ptr = $rdg.find("ptr");
            if ($ptr.length == 0){
                return {
                    "source" : source,
                    "idref" : "",
                    "elementRef" : "",
                    "text" : ""
                }
            }
            let idref = $rdg.find("ptr").attr("target").split("#")[1];
            if ($(TEIfiles.where({source: source})).length == 0) {
                return {
                    "source" : source,
                    "idref" : "",
                    "elementRef" : "",
                    "text" : ""
                }
            }
            let elementRef = $(TEIfiles.where({source: source})[0].get("html5")).find('*').filter(function(){
                return $(this).attr("xml:id") == idref;
            });
            let text = elementRef.text();

            return {
                "source" : source,
                "idref" : idref,
                "elementRef" : elementRef,
                "text" : text
            };
            
        }

		$(data).find("app").each(function(i_a, app){

            // Create new variant collection
            let variant = new Variant();

            $(app).children().each(function(i_rg, reading){
                if (reading.tagName == "rdg") {
                    variant.add(createReadingData(reading))
                } 
                else {
                    let grouped = [];
                    let toCreate = [];

                    $(reading).children().each(function(i_r, rdg){
                        toCreate.push(createReadingData(rdg));
                        grouped.push($(rdg).find("ptr").attr("target").split(".xml")[0]);                        
                    });
                    
                    for (let r of toCreate) {
                        r["agreeing"] = grouped;
                        variant.add(r);
                    }
                }
            });

            variants.push(variant);

        });

        this.set("variants", variants);
	}
}

export default Collation;