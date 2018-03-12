import * as Backbone from 'backbone';
import $ from 'jquery';
import TEIfiles from '../data/TEIfiles-coll';
import TEIfile from '../data/TEIfile-model';
import Collation from '../data/collation-model';
import TextView from './text-view';
import VariantsView from './variants-view'

class MTV extends Backbone.View {

  initialize(options){
    this.files = options.files;
    this.collation = options.collation;
    this.base = options.base;

    this.TEIfiles_coll = new TEIfiles([], this.files);    

    this.$el.append("<h2>Loading TEI files...</h2>");

    this.listenTo(this.TEIfiles_coll, 'sync', () => {  
      this.$el.append("<h2>Loading variants...</h2>");
      $.ajax( this.collation ).success( (data) => {
        this.TEIcollation = new Collation({"data":data, "TEIfiles": this.TEIfiles_coll});})
        .done(()=>{
          this.$el.append("Ready.");

          // All loaded, proceed here

          // $(this.el).empty();
          // $("#variant_info").empty();

          let model = null;
          if (!this.base) {
              model = this.TEIfiles_coll.first();
              
          } else {                
              model = this.TEIfiles_coll.where({"source":this.base})[0];
          }

          (new TextView({"model":model, "el": this.el})).render();

          (new VariantsView({"model":this.TEIcollation, "source":model, "el": this.el})).render();

        });
    }); 
  }

}

export default MTV;