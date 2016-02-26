function DownLoadUrl(c_id, plat_form) {
    this.c_id = c_id;
    this.default_url = "default url";
    this.plat_form = plat_form;
    this.iphone_url = "iphone download url";
    this.ipad_url = "ipad download url";
    this.android_url = function () {
        switch (c_id) {
            case 'baidu_c_id':
                return '你的APP：baidu定制版';
            case 'google_c_id':
                return '你的APP：google定制版';
            case 'c_id':
                return '你的APP：google定制版';
            default:
                return default_url
        }
    }
    this.download_url = function () {
        if (plat_from.android)
            android_url;
        else if (plat_form.iphone)
            iphone_url;
        else if (plat_form.ipad)
            ipad_url;
        else
            default_url;
    }
}

function download_state(c_id, mobile_type) {
    $.ajax({
        type: "POST",
        url: "http://101.200.162.121:8080/add_promotion_log",
        data: {c_id: c_id, mobile_type: mobile_type},
        dataType: 'json'
    });
}

function get_request() {
    var url = location.search; //获取url中"?"符后的字串
    var theRequest = new Object();
    if (url.indexOf("?") != -1) {
        var str = url.substr(1);
        strs = str.split("&");
        for (var i = 0; i < strs.length; i++) {
            theRequest[strs[i].split("=")[0]] = (strs[i].split("=")[1]);
        }
    }
    return theRequest;
}