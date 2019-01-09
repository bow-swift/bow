// Navbar

$(window).on("load", function () {
    $(window).scroll(function () {
        if ($("#navigation").offset().top > 0) {
            $("#navigation").addClass("navigation-scroll");
        } else {
            $("#navigation").removeClass("navigation-scroll");
        }
    });

    // Function to load GitHub stats, which expects a DOM element with 'stars' as id
    (function loadGitHubStats() {
        var gitHubAPI = "https://api.github.com/repos/bow-swift/bow?callback=?";
        $.getJSON(gitHubAPI).done(function(data) {
            $('#stars').text(data.data.stargazers_count);
        });
    })();
});
