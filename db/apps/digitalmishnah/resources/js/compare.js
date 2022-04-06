// JS for compare page


// Make list sortable
var list = document.getElementById("select-wits");
var sortable = Sortable.create(list, {
   animation: 150
}); 

// Filter list based on selection
var updateList = function (unit, sources) {
    $('#wits-loading').show();
    $("#select-wits li").hide();
    $.get("$app-root/modules/filterWitsJSON.xql?mcite="+unit, function(wits){        
        $("#select-wits li").each(function(i, el){
            console.log((unit, sources));
            var $el = $(el);
            if ($.inArray($el.attr("id").split("-").pop(), wits) == -1) {
                $el.hide();
            }
            else {
                $el.css('display', "block");
            }
        });
        $('#wits-loading').hide();
        
        // If sources are indicated, re-oreder and check them.
        if (sources) {
            sources.forEach(function(s, i){
                var $item = $("#wit-item-" + s);
                $item.find("input").prop('checked', true);
                if (i-1 == -1) {
                    $item.parent().prepend($item)
                }
                else {
                 $item.insertAfter($item.siblings(':eq('+(i-1)+')'));   
                }                
            })
            if (sources.length > 1) {
                $("#compareBtn").removeClass("disabled");    
            }
        }        
        
    }, "json");
}

// Update sidebar
var updateSideBar = function (unit, sources) {
    var unit_nav = $(".nav-link-item[href='#"+unit+"']")
    unit_nav.addClass("active")
    unit_nav.closest('.collapse').collapse()
    .parent().closest('.collapse').collapse()
    .parent().closest('.collapse').collapse();
}

var resetAll = function() {
    $(".mishnah_link").removeClass("active");
    $("#compareView").empty();
    $(".wit-remove").prop('checked', false);
}

$(window).on('load',function(){ 
    // check for info from url structure
    var parts = location.pathname.split("/");
    if (parts[parts.length -4] == "compare") {
        var unit = parts[parts.length -3]
        var sources = parts[parts.length -2].split(",")
        var mode = parts[parts.length -1]
        // Update mode
        $("#opt_"+mode).click()
        // Updated other components
        updateNav(unit);
        updateList(unit, sources);
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
    $("#cmpLoading").show()
    var mcite = $(".nav-link-item.active").attr("href").split("#")[1];
    var sources = [];
    $(".wit-remove:checked").each(function(i, w){
       sources.push($(w).parent().attr("id").split("-").pop()); 
    });
    var mode = $("#options input:checked").val()
    var base_url = location.href.substr(0, location.href.indexOf('compare/')); 
    location.href= base_url + "compare/" + mcite + "/" + sources.join(",") + "/" + mode;
});

$("#toggle_boxes").click(function(){   
    if ($(".wit-item input:checked").length > 0) {
        $(".wit-item input").prop("checked", false)
        $("#compareBtn").addClass("disabled");
    }
    else {
        $(".wit-item input").filter(":visible").prop("checked", true)
        $("#compareBtn").removeClass("disabled");
    }
})

var updateNav = function (unit) {
    // Show next/prev navigation
    $("#dm-compare-nav").show();
    
    var next_unit, prev_unit;
    if (unit.split(".").length == 4) {
        // This is a mishnah
        var cur_unit_nav = $(".mishnah_link[href='#"+unit+"']")
        prev_unit = cur_unit_nav.prev('.nav-link-item:not(.mishnah_chap)');
        next_unit = cur_unit_nav.next('.nav-link-item:not(.mishnah_chap)');
    }
    else {
        // This is a chapter 
        var cur_unit_nav = $("#ch_"+unit.replace(/\./g,"_")).closest(".list-group-item")
        prev_unit = cur_unit_nav.prev('.list-group-item').find("a:first");
        next_unit = cur_unit_nav.next('.list-group-item').find("a:first");
    }
    
    var parts = location.pathname.split("/");
    
    // Determine prev
    if (prev_unit.length > 0) { 
        var prev_url = parts.slice(0, 5);    
        prev_url.push(prev_unit.attr("href").slice(1).replace(/_/g, "."))
        prev_url = prev_url.concat(parts.slice(-2));
        prev_url = prev_url.join("/"); 
        $("#dm-compare-nav a:last-child").show().attr("href", prev_url);        
    }
    else $("#dm-compare-nav a:last-child").hide();
    
    // Determine next
    if (next_unit.length > 0) { 
        var next_url = parts.slice(0, 5);
        next_url.push(next_unit.attr("href").slice(1).replace(/_/g, "."))
        next_url = next_url.concat(parts.slice(-2));
        next_url = next_url.join("/");
        $("#dm-compare-nav a:first-child").show().attr("href", next_url);        
    }
    else $("#dm-compare-nav a:first-child").hide();
}

$(".mishnah_link").click(function(e){
    e.preventDefault();
    resetAll()
    var unit = $(e.target).attr("href").slice(1)
    updateList(unit);
    updateSideBar(unit);
});
