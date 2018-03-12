import * as Backbone from 'backbone';
import Reading from './reading-model.js';

class Variant extends Backbone.Collection {
	constructor() {
		super();
		this.model = Reading;		
	}
}

export default Variant;