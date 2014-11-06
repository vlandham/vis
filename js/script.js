
function scrollMap() {
  var scrollElId = '#scroll-map-capture';
  var scrollEl;
  var windowH, windowW;
  var docH, docW;

  var lastScrollTop = 0;

  function e() {
    setupCapture();
    scrollEl.on('mousewheel DOMMouseScroll MozMousePixelScroll', onScroll);
  }

  setupCapture = function() {
    console.log("setup");
    windowH = $(window).height();
    windowW = $(window).width();
    docH = $(document).height();
    docW = $(document).width();
    $('body').prepend('<div id="scroll-map-capture"></div>');
    scrollEl = $(scrollElId);
    scrollEl.css("height", docH + "px");
    scrollEl.css("width", docW + "px");
    scrollEl.css("position", "absolute");
    scrollEl.css("z-index", "1000000");
    // scrollEl.css("pointer-events", "none");
  }

  onScroll = function(e) {
    var st = $(window).scrollTop();
    var scrollDiff = (st - lastScrollTop);
    console.log(scrollDiff);
    lastScrollTop = st;
  }

  return e;
}

$(document).ready(function() {
  var s = scrollMap();
  s();

});




