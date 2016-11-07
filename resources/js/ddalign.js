// Assumes that the mtjsviewer is loaded and MTV is available globally.
// Requires jQuery

var loadChapter = function (chap) {

    // Open menu at right place
    var esc_chap = "ch_" + chap.replace(/\./g, "_");    
    var cur_chap_nav = $("#"+esc_chap);
    
    // Highlight current
    $('.nav-link-item').removeClass("active");
    cur_chap_nav.addClass("active");
    
    cur_chap_nav
      .closest('.collapse').collapse()
      .parent()
        .closest('.collapse').collapse();

    // Clear out any alignment data, instructions, and spinner
    $("#instructions").remove();
    $("#MTV").off();
    $("#MTV-align").off().empty();
    $("#MTV-base").off().empty();
    
    $("#MTV-spinner").show();
    
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
    
    // open menu at right place
//    cur_chap_nav.closest(".collapse").collapse("show");
    
    // Determine prev
    var prev_chap = cur_chap_nav.prev('.nav-link-item');
    if (prev_chap.length > 0) { 
        $("#dm-align-nav a:first-child").show().attr("href", prev_chap.find("a").attr("href"));        
    }
    else $("#dm-align-nav a:first-child").hide();
    
    // Determined next
    var next_chap = cur_chap_nav.next('.nav-link-item');
    if (next_chap.length > 0) { 
        $("#dm-align-nav a:last-child").show().attr("href", next_chap.find("a").attr("href"));        
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
   