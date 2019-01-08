// Navbar

$(window).on("load", function () {
    $(window).scroll(function () {
        if ($("#navigation").offset().top > 0) {
            $("#navigation").addClass("navigation-scroll");
        } else {
            $("#navigation").removeClass("navigation-scroll");
        }
    });
});


function myFunction() {
  var x = document.getElementById("myTopnav");
  if (x.className === "navigation-menu") {
    x.className += "responsive";
  } else {
    x.className = "navigation-menu";
  }
}