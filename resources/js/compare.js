// JS for compare page


// Make list sortable
var list = document.getElementById("select-wits");
Sortable.create(list, {
   animation: 150
}); 

// Filter list based on selection
var updateList = function (unit) {
    $.get("$app-root/modules/filterWitsJSON.xql?mcite="+unit, function(wits){
        $("#select-wits li").each(function(i, el){
            var $el = $(el);
            if ($.inArray($el.attr("id").split("-").pop(), wits) == -1) {
                $el.remove();
            }
        });
    }, "json");
}

// Hash events
$(window).on('hashchange',function(){
    var unit = location.hash.slice(1);
    if (unit) {    
        updateList(unit);
    }
});

$(window).on('load',function(){ 
    var unit = location.hash.slice(1)
    if (unit) {
        updateList(unit);
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
    location.href= "compare/" + mcite + "/" + sources.join(",") + "/" + mode;
});
