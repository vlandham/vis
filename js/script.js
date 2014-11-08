
function scrollMap() {
  var scrollElId = '#scroll-map-capture';
  var wrapperElId = "#scroll-map-wrapper";
  var scrollEl;
  var windowH, windowW;
  var docH, docW;

  var lastScrollTop = 0;

  function e() {
    setupDimensions();
    // $(document).on('mousewheel DOMMouseScroll MozMousePixelScroll', onScroll);
    setupDiv();
    scrollEl.on('mousewheel', onScroll);

    $(wrapperElId).on('mousewheel', fakeScroll);
    // $(scrollElId).forwardevents();
  }

  setupDimensions = function() {
    console.log("setup");
    windowH = $(window).height();
    windowW = $(window).width();
    docH = $(document).height();
    docW = $(document).width();
    // scrollEl.css("pointer-events", "none");
  }

  setupDiv = function() {
    $('body').children().wrapAll("<div id='scroll-map-wrapper' />");
    // $(wrapperElId).css("position", "absolute");

    $('body').prepend('<div id="scroll-map-capture"></div>');
    scrollEl = $(scrollElId);
    scrollEl.css("height", docH + "px");
    scrollEl.css("width", docW + "px");
    // scrollEl.css("position", "absolute");
    scrollEl.css("position", "fixed");
    scrollEl.css("z-index", "1000000");
  }

  fakeScroll = function(e) {
    console.log(e.isDefaultPrevented());
  }

  onScroll = function(e) {
    var st = $(window).scrollTop();
    var scrollDiff = (st - lastScrollTop);
    console.log(scrollDiff);
    lastScrollTop = st;

    // var scrollTo= (e.wheelDelta*-1) + $(wrapperElId).scrollTop();
    // $(wrapperElId).scrollTop(scrollTo);
    // console.log(e);
    var newEvent = $.extend($.Event(e.type), {
    which: 1,
    originalEvent: e.originalEvent,
    clientX: e.clientX,
    clientY: e.clientY,
    pageX: e.pageX,
    pageY: e.pageY,
    screenX: e.screenX,
    screenY: e.screenY,
    wheelDelta: e.wheelDelta
    });

    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
    $(wrapperElId).trigger(newEvent);
  }

  return e;
}

$(document).ready(function() {
  var s = scrollMap();
  s();

  $("#blank_square").on("mousewheel", function(e) {
    console.log("box");
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
  });

});




