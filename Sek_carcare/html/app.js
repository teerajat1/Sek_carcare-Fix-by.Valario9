window.addEventListener('message', function (event) {
    var item = event.data;
    if (item.clear == true) {
        $(".items").empty();
    }
    if (item.display == true) {
        $(".container").show();
        var sound = new Audio('open.mp3');
        sound.volume = 0.3;
        sound.play();
    }
    if (item.display == false) {
        $(".container").fadeOut(100);
    }
});

document.addEventListener('DOMContentLoaded', function () {
    $(".container").hide();
});

window.addEventListener('message', function (event) {
    var data = event.data;
    if (data.clear !== undefined) {
       $(".shop").html();
    }
});

function yes(item, zone) {
    $.post('http://Sek_carcare/Yes', JSON.stringify({ item: item, zone: zone}));
    $.post('http://Sek_carcare/focusOff');
    var sound = new Audio('click.mp3');
    sound.volume = 0.7;
    sound.play();
    $(".container").fadeOut(100);
}

window.addEventListener('message', function (event) {
    var data = event.data;

    if (data.price !== undefined) {
    $(".items").append(`
        <div class="item" onclick="yes('`+data.itemLabel+`', '`+data.zone+`')">
            <div class="item22">`+data.itemLabel+`</div>
        </div>
    `);
    }
});
