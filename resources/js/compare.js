// JS for compare page


// Make list sortable
var list = document.getElementById("select-wits");
Sortable.create(list, {
   animation: 150
}); 

// Filter list based on selection
var updateList = function (unit) {
    $('#wits-loading').show();
    $("#select-wits li").hide();
    $.get("$app-root/modules/filterWitsJSON.xql?mcite="+unit, function(wits){        
        $("#select-wits li").each(function(i, el){
            var $el = $(el);
            if ($.inArray($el.attr("id").split("-").pop(), wits) == -1) {
                $el.hide();
            }
            else {
                $el.css('display', "block");
            }
        });
        $('#wits-loading').hide();
    }, "json");
}

// Update sidebar
var updateSideBar = function (unit) {
    var unit_nav = $(".nav-link-item[href='#"+unit+"']")
    unit_nav.addClass("active")
    unit_nav.closest('.collapse').collapse()
    .parent().closest('.collapse').collapse()
    .parent().closest('.collapse').collapse();
}

// Hash events
$(window).on('hashchange',function(){
    var unit = location.hash.slice(1);
    if (unit) {    
        updateList(unit);
        updateSideBar(unit);
    }
});

$(window).on('load',function(){ 
    var unit = location.hash.slice(1)
    if (unit) {
        updateList(unit);
        updateSideBar(unit);
    }
});

$(".wit-remove").click(function(){
    // If at least two witnesses are selected, enable the compare button, 
    // otherwise disable it.
    if ($(".wit-remove:checked").length >= 2) {
        $("#compareBtn").removeClass("disabled");
    }
    else $("#compareBtn").addClass("disabled");
})

$("#compareBtn").click(function(){
    var mcite = $(".nav-link-item.active").attr("href").split("#")[1];
    var sources = [];
    $(".wit-remove:checked").each(function(i, w){
       sources.push($(w).parent().attr("id").split("-").pop()); 
    });
    var mode = $("#options input:checked").val()
    var base_url = location.href.substr(0, location.href.indexOf('compare/')); 
    location.href= base_url + "compare/" + mcite + "/" + sources.join(",") + "/" + mode + "#" + mcite;
});
