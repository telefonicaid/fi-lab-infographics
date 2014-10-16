function createDiv() {
    var e = document.getElementsByTagName("body")[0],
        t = document.createElement("div");
    t.setAttribute("id", "cookie-law"), t.innerHTML = '<p>We use first and third-party\'s cookies to improve your experience and our services,identifying your Internet browsing preferences on our website. If you keep browsing, you accept its use. You can get more information on our <a href="http://forge.fi-ware.org/plugins/mediawiki/wiki/fiware/index.php/Cookies_Policy_FIWARE_Lab" target="_blank">Cookie Policy. </p><a id="close-cookie-banner" href="javascript:void(0);" onclick="removeMe();"><span>X</span></a>', e.insertBefore(t, e.firstChild), document.getElementsByTagName("body")[0].className += " cookiebanner", createCookie(window.cookieName, window.cookieValue, window.cookieDuration)
}

function createCookie(e, t, n) {
    if (n) {
        var i = new Date;
        i.setTime(i.getTime() + 1e3 * 60 * 60 * 24 * n);
        var o = "; expires=" + i.toGMTString()
    } else var o = "";
    window.dropCookie && (document.cookie = e + "=" + t + o + "; path=/")
}

function checkCookie(e) {
    for (var t = e + "=", n = document.cookie.split(";"), i = 0; i < n.length; i++) {
        for (var o = n[i];
            " " == o.charAt(0);) o = o.substring(1, o.length);
        if (0 == o.indexOf(t)) return o.substring(t.length, o.length)
    }
    return null
}

function eraseCookie(e) {
    createCookie(e, "", -1)
}

function removeMe() {
        var e = document.getElementById("cookie-law");
        e.parentNode.removeChild(e)
}

var dropCookie = !0,
    cookieDuration = 10,
    cookieName = "policy_info_cookie",
    cookieValue = "on";

window.onload = function() {
    checkCookie(window.cookieName) != window.cookieValue && createDiv()
};

