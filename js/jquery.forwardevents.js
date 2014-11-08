(function ($) {

	function triggerEvent($elem, eventType, event, relatedTarget)
	{
		var originalType = event.type,
		originalEvent = event.originalEvent,
		originalTarget = event.target,
		originalRelatedTarget = event.relatedTarget;

		event.target = $elem[0];
		event.type = eventType;
		event.originalEvent = null;

		if (relatedTarget) { event.relatedTarget = relatedTarget }

		$elem.trigger(event);

		event.type = originalType;
		event.originalEvent = originalEvent;
		event.target = originalTarget;
		event.relatedTarget = originalRelatedTarget;
	};

    $.fn.forwardevents = function(settings)
	{

		var options = $.extend( {
				enableMousemove: false,
				dblClickThreshold: 500,
				directEventsTo: null
			}, settings);

		var instance = this;
			
        return this.each(function () {
            
            var $this = $(this),
                xy, lastT,
				clickX, clickY,
                clicks = 0,
                lastClick = 0;

            $this.bind('mouseout', function (e) {
                if (lastT) {
	                triggerEvent(lastT, 'mouseout', e, $this[0]);
                    //lastT = null;
                }
            }).bind('mousemove mousedown mouseup mousewheel', function (e) {

                if ($this.is(':visible'))
                {

                    var be = e.originalEvent,
                        et = be.type,
                        mx = be.clientX,
                        my = be.clientY,
                        t;

                    e.stopPropagation();

	                if (options.directEventsTo != null)
	                {
		                t = options.directEventsTo;
	                }
	                else
	                {
	                    $this.hide();
	                    t = $(document.elementFromPoint(mx, my));
	                    $this.show();
	                }

					//console.log(lastT);
					
                    if (!t) {
                        triggerEvent(lastT, 'mouseout', e);
                        lastT = t;						
                        return;
                    }

                    if (options.enableMousemove || et !== 'mousemove') {
                        triggerEvent(t, et, e);
                    }
					
                    if (lastT && (t[0] === lastT[0])) 
                    {	
			if (et == 'mouseup') {

                            // using document.elementFromPoint in mouseup doesn't trigger dblclick event on the overlay
                            // hence we have to manually check for dblclick
                            if (clickX != mx || clickY != my || (e.timeStamp - lastClick) > options.dblClickThreshold) {
                                clicks = 0;
                            }

                            clickX = mx;
                            clickY = my;
                            lastClick = e.timeStamp;
                            triggerEvent(t, 'click', e);

                            if (++clicks == 2) {
                                triggerEvent(t, 'dblclick', e);
                                clicks = 0;
                            }
                        }
                    } else {
						
			clicks = 0;
                        if (lastT) {	
				triggerEvent(lastT, 'mouseout', e, t[0]);
                        }
			triggerEvent(t, 'mouseover', e, lastT ? lastT[0] : $this[0]);
                    }
		    lastT = t;
                    //instance._suspended = false;
                }
            });
        });
    }

})(jQuery);
