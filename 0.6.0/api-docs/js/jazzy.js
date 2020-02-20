window.jazzy = { docset: false };
if (typeof window.dash != "undefined") {
  document.documentElement.className += " dash";
  window.jazzy.docset = true;
}
if (navigator.userAgent.match(/xcode/i)) {
  document.documentElement.className += " xcode";
  window.jazzy.docset = true;
}

// On token click, toggle its discussion and animate token.marginLeft
$(".token").click(function(event) {
  if (window.jazzy.docset) {
    return;
  }
  // Keeps the document from jumping to the hash.
  event.preventDefault();
  var link = $(this);
  var linkIcon = link.find(".token-icon");
  var animationDuration = 200;
  linkIcon.toggleClass("token-icon-plus");
  $content = link
    .parent()
    .parent()
    .next();
  $content.slideToggle(animationDuration);

  // Avoid polluting the history with hash navigation
  var href = $(this).attr("href");
  history.replaceState(undefined, undefined, href);
});
