import $ from 'jquery';
import * as Backbone from 'backbone';
import ReadingView from './reading-view.js';

class VariantsView extends Backbone.View {
    initialize(options){
    	this.source = options.source;
    	this.variants = this.model.get("variants");
    }
    render(){
    	let sourceid = this.source.get("source");
    	// Start by highlighting affected ids
    	for (let variant of this.variants){
    		(new ReadingView({"collection":variant, "source": sourceid})).render();

    	}
    }
}

export default VariantsView;