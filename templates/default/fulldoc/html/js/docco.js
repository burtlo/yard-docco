function createAnnotatedSourceLinks() {
    $('.method_details_list .annotated_source_code').each(function(index,element) {

      var spanToggleAnnotatedSource = "<span class='showSource'>[<a href='#' class='annotatedToggleSource'>View Annotated source</a>]</span>";

      $(element).before(spanToggleAnnotatedSource);
    });

    $('.annotatedToggleSource').toggle(function() {
       $(this).parent().next().slideDown(100);
       $(this).text("Hide Annotated source");
    },
    function() {
        $(this).parent().next().slideUp(100);
        $(this).text("View Annotated source");
    });
}

$(createAnnotatedSourceLinks);