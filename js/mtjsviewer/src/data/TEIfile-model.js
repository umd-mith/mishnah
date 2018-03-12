import * as Backbone from 'backbone';
import CETEI from 'CETEIcean';

class TEIfile extends Backbone.Model {

    initialize() {
        // Register TEI elements as HTML5 when possible.
        let CETEIcean = new CETEI();
        CETEIcean.makeHTML5(this.get("data"), (data) => {
            this.set("html5", data);
        });
    }
}

export default TEIfile;