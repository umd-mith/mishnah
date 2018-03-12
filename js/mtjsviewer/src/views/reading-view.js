import $ from 'jquery';
import * as Backbone from 'backbone';

class ReadingView extends Backbone.View {
    initialize(options){
        this.source = options.source;
        this.$textEl = this.collection.where({"source":this.source})[0].get("elementRef");
        console.log(this.$textEl);
        // this.$textEl.click((e)=>{
        //     e.preventDefault(); 
        //     this.showInfo()
        // });
        // this.$textEl.hover((e)=>{e.preventDefault(); this.showInfo()});
    }

    showInfo() {
        // When rendering, only send to template variants that are OTHER than this.source.
        // Also set a flag that says whether other readings ( .get("agreeing") ) agree with this.source.
        
        $(".variant").removeClass('active');
        this.$textEl.addClass('active');

        // this.collection.each((rdg)=>{
        //     if (rdg.get("agreeing")){
        //         if (rdg.get("agreeing").indexOf(this.source) !== -1){
        //             rdg.set("agrees", true);
        //         }
        //         else rdg.set("agrees", false);
        //         // remove same source for the view
        //         let agreeing = rdg.get("agreeing");
        //         let i = agreeing.indexOf(rdg.get("source"))
        //         rdg.set("agreeing", agreeing.splice(i, 1));
        //     }
        // });

        // let readings = this.collection
        //  .chain()
        //     .filter((rdg) => {
        //         return rdg.get("source") !== this.source;
        //     })
        //     .invoke('toJSON')
        //     .value();

        // this.$el.html(reading_tpl(readings));
    }

    render(){
        if (this.$textEl){
            this.$textEl.addClass('variant');
        }
        // $(".variant").removeClass('active');
    }
}

export default ReadingView;