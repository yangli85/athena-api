//encoding:utf - 8
window.onload = function(){
    if (window == window.top && window.location.pathname.indexOf("welcome.html") < 0) {
        window.location.href = "./welcome.html"
    }
}
login_info = JSON.parse(localStorage.getItem("login_info"));

