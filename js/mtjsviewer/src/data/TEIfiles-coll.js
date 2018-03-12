import $ from 'jquery';
import * as Backbone from 'backbone';
import TEIfile from './TEIfile-model.js';

class TEIfiles extends Backbone.Collection {

    initialize(models, files) {

        this.model = TEIfile;

        // Store all ajax calls in array
        let deferreds = [];

        for (let file of files) {
            let source = /[\/]([^\/]+)\.xml/.exec(file)[1];

            deferreds.push(
                $.ajax( {
                  url: file,
                  type: "GET",
                  async: true,
                  dataType: 'text'
                } )
                .success( (data) => {
                    this.add({"source" : source, "data": data});
                    // TODO I'm cheating here; handle with Events
                    $("#TEI").append("<h3>Loaded "+ source+ "</h3>");
                })
            );
        }

        // All done
        $.when.apply(null, deferreds).done(() => {
            this.trigger('sync');
        });
    }
}

export default TEIfiles;