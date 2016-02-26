javascirpt(function ($) {
    $.fn.extend({
        aiiUpload: function (obj) {
            if (typeof obj != "object") {
                alert('参数错误');
                return;
            }
            var imageWidth, imageHeight;
            var base64;
            var file_num = 0;
            var fileInput = $(this);
            var fileInputId = fileInput.attr('id');
            createDoc('#' + fileInputId, obj.method, obj.action);
            $('#aii_file').change(function () {
                if (test(this.value) == false) {
                    alert('格式错误');
                    return;
                }
                var objUrl = getObjectURL(this.files[0]);
                if (objUrl) {
                    imgBefore(objUrl, file_num);
                    render(objUrl, obj.max_h, obj.max_w, file_num);
                    file_num++;
                }
            });
        }
    });
    function createDoc(objID, form_method, form_action) {
        var element = $(objID);
        element.append('
            < ul
    class
        = "viewList" > < / ul > ').append('
            < div
    class
        = "fileBox" > < input
        type = "file"
        id = "aii_file" / >

            < div
    class
        = "file_bg" > < / div >
            < / div > ').append('
            < form
        id = "aii_upload_form"
        method = "'+form_method+'"
        action = "'+form_action+'" > < / form > ').append('
            < canvas
        id = "canvas" > < / canvas > ');
    }

    function test(value) {
        var regexp = new RegExp("(.JPEG|.jpeg|.JPG|.jpg|.GIF|.gif|.BMP|.bmp|.PNG|.png)$", 'g');
        return regexp.test(value);
    }

    function render(src, MaximgW, MaximgH, idnum) {
        var image = new Image();
        image.onload = function () {
            var canvas = document.getElementById('canvas');
            if (image.width > image.height) {
                imageWidth = MaximgW;
                imageHeight = MaximgH * (image.height / image.width);
            }
            else if (image.width
                < image.height) {
                imageHeight = MaximgH;
                imageWidth = MaximgW * (image.width / image.height);
            }
            else {
                imageWidth = MaximgW;
                imageHeight = MaximgH;
            }
            canvas.width = imageWidth;
            canvas.height = imageHeight;
            var con = canvas.getContext('2d');
            con.clearRect(0, 0, canvas.width, canvas.height);
            con.drawImage(image, 0, 0, imageWidth, imageHeight);
            base64 = canvas.toDataURL('image/jpeg', 0.5).substr(22);
            add_doc(base64, idnum);
        }
        image.src = src;
    };
//建立一個可存取到該file的url
    function getObjectURL(file) {
        var url = null;
        if (window.createObjectURL != undefined) { // basic
            url = window.createObjectURL(file);
        } else if (window.URL != undefined) { // mozilla(firefox)
            url = window.URL.createObjectURL(file);
        } else if (window.webkitURL != undefined) { // webkit or chrome
            url = window.webkitURL.createObjectURL(file);
        }
        return url;
    }

//预览
    function imgBefore(objUrl, idnum) {
        var li = '
            < li
    class
        = "view" > < img
        src = "'+objUrl+'"
        id = "aiiImg_'+idnum+'"
        idnum = "'+idnum+'" / >

            < div
    class
        = "close"
        onclick = "img_remove(this);" > < / div >
            < / li > '
        $('.viewList').append(li);
        var img = $('#aiiImg_' + idnum);
//预览图片居中 填满 代码
        console.log('asdfasdfasdf');

        img.load(function () {
            var imgw = img.width(),
                imgh = img.height();
            console.log(imgw);
            console.log(imgh);
            if (imgw > imgh) {
                img.css('height', '100%');
                img.css('width', 'auto');
                img.css('marginLeft', -(img.width() - img.height()) / 2 + 'px');
            }
            else if (imgw
                < imgh) {
                img.css('width', '100%');
                img.css('height', 'auto');
                img.css('marginTop', -(img.height() - img.width()) / 2 + 'px');
            }
        });
    }

    function add_doc(base, idnum) {
        $('#aii_upload_form').append('<input type="hidden" name="img[]" id="f_' + idnum + '" value="' + base + '"/>');
    }
})(jQuery);
function img_remove(element) {
    var num = $(element).prev().attr('idnum');
    $(element).parent().remove();
    $('#f_' + num).remove();
    console.log('asdf');
}