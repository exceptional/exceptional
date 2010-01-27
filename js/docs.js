$(document).ready( function() {
  
  // Highlight correct TOC line
  var toc_url = location.href.replace(/^http\:\/\/[^\/]+\//, '');
  $("div#TableOfContents a[href='/" + toc_url + "']").addClass('selected');
  
});