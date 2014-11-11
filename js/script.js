
(function(console){

console.save = function(data, filename){

    if(!data) {
        console.error('Console.save: No data')
        return;
    }

    if(!filename) filename = 'console.json'

    if(typeof data === "object"){
        data = JSON.stringify(data, undefined, 2)
    }

    var blob = new Blob([data], {type: 'text/json'}),
        e    = document.createEvent('MouseEvents'),
        a    = document.createElement('a')

    a.download = filename
    a.href = window.URL.createObjectURL(blob)
    a.dataset.downloadurl =  ['text/json', a.download, a.href].join(':')
    e.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
    a.dispatchEvent(e)
 }
})(console)


function scrollMap() {
  var scrollElId = '#scroll-map-capture';
  var wrapperElId = "#scroll-map-wrapper";
  var scrollEl;
  var windowH, windowW;
  var docH, docW;

  var allData = [];

  var lastScrollTop = 0;

  function s() {
    setupDimensions();
    // $(document).on('mousewheel DOMMouseScroll MozMousePixelScroll', onScroll);
    // setupDiv();
    // scrollEl.on('mousewheel', onScroll);

    // $(wrapperElId).on('mousewheel', fakeScroll);
    // $(scrollElId).forwardevents();
    
    // window.onscroll = onScroll;
    // $(document).on("mousewheel", onScroll);
    setupLog();
    document.addEventListener("wheel", onScroll, true);
  }

  setupDimensions = function() {
    console.log("setup");
    windowH = $(window).height();
    windowW = $(window).width();
    docH = $(document).height();
    docW = $(document).width();
    // scrollEl.css("pointer-events", "none");
  }

  saveData = function() {
    console.log('save');
    console.save(allData, "scroll_data.json");
  }

  setupLog = function(argument) {
    $('body').prepend('<div id="scroll-map-log"></div>');
    scrollEl = $('#scroll-map-log');
    scrollEl.css("position", "fixed");
    scrollEl.css("left", "0");
    scrollEl.css("top", "0");
    scrollEl.css("width", "60px");
    scrollEl.css("background-color", "grey");

    scrollEl.on("click", saveData);

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

  // fakeScroll = function(e) {
  //   console.log(e.isDefaultPrevented());
  // }

  onScroll = function(e) {
    var data = new Object();
    data.windowHeight = $(window).height();
    data.windowWidth = $(window).width();
    data.mouseX = e.clientX;
    data.mouseY = e.clientY;
    data.scrollTop = $(window).scrollTop();
    data.scrollDiff = (data.scrollTop - lastScrollTop);
    // hack to prevent infinity
    if(data.scrollDiff == 0) {
      data.scrollDiff = 1;
    }
    lastScrollTop = data.scrollTop;
    data.delta = e.wheelDeltaY;

    data.ratio = Math.round((data.delta) / (data.scrollDiff));

    data.time = Date.now();

    // console.log(e.clientY);
    scrollEl.html(data.ratio);

    allData.push(data);




    // var scrollTo= (e.wheelDelta*-1) + $(wrapperElId).scrollTop();
    // $(wrapperElId).scrollTop(scrollTo);
    // console.log(e);
    // var newEvent = $.extend($.Event(e.type), {
    // which: 1,
    // originalEvent: e.originalEvent,
    // clientX: e.clientX,
    // clientY: e.clientY,
    // pageX: e.pageX,
    // pageY: e.pageY,
    // screenX: e.screenX,
    // screenY: e.screenY,
    // wheelDelta: e.wheelDelta
    // });

    // e.preventDefault();
    // e.stopPropagation();
    // e.stopImmediatePropagation();
    // $(wrapperElId).trigger(newEvent);
  }

  return s;
}

$(document).ready(function() {

  $("#blank_square").on("mousewheel", function(e) {
    // console.log("box");
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
  });

  var s = scrollMap();
  s();

});




