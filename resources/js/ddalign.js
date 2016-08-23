// Assumes that the mtjsviewer is loaded and MTV is available globally.
// Requires jQuery

var loadChapter = function (chap) {

    // Open menu at right place
//    console.log($("#ch_"+chap.replace(/\./g,"_")))
//    $("#ch_"+chap.replace(/\./g,"_")).parent().show();

    // Clear out any alignment data and instructions
    $("#instructions").remove();
    $("#MTV").off();
    $("#MTV-align").off().empty();
    $("#MTV-base").off().empty();
    
    new MTV(
        {
        "base" : 'modules/getMishnah.xql?ch='+chap,
        "base_id" : 'ref.xml',
        "align" : 'modules/getTosefta.xql?ch='+chap,
        "alignment" : 'modules/getAlignPart.xql?ch='+chap,
        "el": "#MTV"
        }
    );    
    
}

var updateNav = function (chap) {
    // Show next/prev navigation
    $("#dm-align-nav").show();
    
    var esc_chap = "ch_" + chap.replace(/\./g, "_");
    
    var cur_chap_nav = $("#"+esc_chap);    
    
    // Determine prev
    var prev_chap = cur_chap_nav.prev('a.list-group-item');
    if (prev_chap.length > 0) { 
        $("#dm-align-nav a:first-child").show().attr("href", prev_chap.attr("href"));        
    }
    else $("#dm-align-nav a:first-child").hide();
    
    // Determined next
    var next_chap = cur_chap_nav.next('a.list-group-item');
    if (next_chap.length > 0) { 
        $("#dm-align-nav a:last-child").show().attr("href", next_chap.attr("href"));        
    }
    else $("#dm-align-nav a:last-child").hide();
}


$(window).on('hashchange',function(){
    var chap = location.hash.slice(1);
    if (chap) {    
        loadChapter(chap);   
        updateNav(chap);
    }
});

$(window).on('load',function(){ 
    var chap = location.hash.slice(1)
    if (chap) {
        loadChapter(chap);
        updateNav(chap);
    }
});
   