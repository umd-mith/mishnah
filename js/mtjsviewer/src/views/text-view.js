import $ from 'jquery';
import * as Backbone from 'backbone';

class TextView extends Backbone.View {

    render() {
        this.$el.html(this.model.get("html5"));
    }

}

export default TextView;