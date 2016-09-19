// Set clicked item as active

$("#passages .nav-link-item").click(function(e){
    activate($(e.target));
});

var activate = function($el) {
    $("#passages .nav-link-item").removeClass("active");
    $el.addClass("active");
}

// Show and activate right place in navigation on hash change
var updateNav = function(unit) {
    console.log('h');
    var item = $("*[href='#"+unit+"']");
    activate(item);
    item.parents('div.list-group').collapse('show');
    item.parent().prev('a').collapse('show');    
}

$(window).on('hashchange',function(){
    var unit = location.hash.slice(1);
    if (unit) {    
        updateNav(unit);
    }
});

$(window).on('load',function(){ 
    var unit = location.hash.slice(1)
    if (unit) {
        updateNav(unit);
    }
});