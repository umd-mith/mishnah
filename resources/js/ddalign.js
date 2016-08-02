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

$(window).on('hashchange',function(){ 
    if (location.hash.slice(1)) {
        loadChapter(location.hash.slice(1));    
    }
});

$(window).on('load',function(){ 
    if (location.hash.slice(1)) {
        loadChapter(location.hash.slice(1));    
    }
});
   