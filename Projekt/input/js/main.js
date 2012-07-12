
  var rotator = {
    time      : [10000, 200, 100, 100],
    css_class : ['', 'frame-2', 'frame-3', 'frame-2']
  };


  function preload (file_name) {
    img = new Image ();
    img.src = file_name;
  }


  function animateLogo (frame) {
    $('h1').attr ('class', rotator.css_class [frame]);
    time = rotator.time [frame];
    frame++;
      if (frame >= rotator.time.length)
        frame = 0;
    setTimeout ("animateLogo(" + frame + ")", time);
  }


  function uniqueRandom (n, min, max) {
    result = Array ();

    for (i = 0; i < n; ++i) {
      do {
        r = min + Math.floor (Math.random () * (max - min + 1));
      } while ($.inArray (r, result) != -1);

      result.push (r);
    }

    return result;
  }


  function randomizeImage () {
    var ids = Array ("lt", "ct", "rt", "lb", "cb", "rb");

    if (!$("div#random").hasClass ("hovered")) {

      ind = uniqueRandom (6, 0, images.length - 1);

      for (i = 0; i < 6; ++i) {
        article = images [ind [i]];
        image = article.images [Math.floor (Math.random () * article.images.length)];
        $("a#" + ids [i]).attr ("href", article.title + ".html");
        $("a#" + ids [i] + " img").attr ("src", "thumbs/" + image);
      }
    }
    //setTimeout("randomizeImage()", 10000);
  }


  $(function () {
    setTimeout ("animateLogo(0)", 1000);

    $("div.illustrations img").each (function () {
      larger = this.src.replace("thumbs", "large-thumbs");
      $(this).after ("<img class='larger' src='" + larger + "' alt='Trochę większa ilustracja'/>");
    });

    $("div#menu").prepend ("<div id='random'><a id='lt'><img></a><a id='ct'><img></a><a id='rt'><img></a><a id='lb'><img></a><a id='cb'><img></a><a id='rb'><img></a></div>");

/*    $("div#menu").delegate ("div#random", "mouseover mouseleave", function (e){
      if (e.type == "mouseover")
        $(this).attr("class", "hovered");
      else
        $(this).attr("class", "");
    });
*/
    randomizeImage ();

    preload ("player/dewplayer-mini.swf");
    preload ("player/audio.mp3");

    $("h1").bind ("click", function (event) {
      $(this).append ('<object type="application/x-shockwave-flash" data="player/dewplayer-mini.swf" width="160" height="20" id="dewplayer" name="dewplayer"><param name="wmode" value="transparent"><param name="movie" value="player/dewplayer-mini.swf"><param name="flashvars" value="mp3=player/audio.mp3&amp;autostart=1&amp;volume=50"></object>');
    });
  });

