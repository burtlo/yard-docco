function createAnnotatedSourceLinks() {
    $('.method_details_list .annotated_source_code').
        before("<span class='showSource'>[<a href='#' class='annotatedToggleSource'>View annotated source</a>]</span>");
    $('.annotatedToggleSource').toggle(function() {
       $(this).parent().next().slideDown(100);
       $(this).text("Hide annotated source");
    },
    function() {
        $(this).parent().next().slideUp(100);
        $(this).text("View annotated source");
    });
}

$(createAnnotatedSourceLinks);