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
