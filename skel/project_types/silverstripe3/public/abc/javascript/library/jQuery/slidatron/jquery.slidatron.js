/*
 *  Project:
 *  Description:
 *  Author:
 *  License:
 */

// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ($, window, document, undefined) {

    // undefined is used here as the undefined global variable in ECMAScript 3 is
    // mutable (ie. it can be changed by someone else). undefined isn't really being
    // passed in so we can ensure the value of it is truly undefined. In ES5, undefined
    // can no longer be modified.

    // window and document are passed through as local variable rather than global
    // as this (slightly) quickens the resolution process and can be more efficiently
    // minified (especially when both are regularly referenced in your plugin).

    // Create the defaults once
    var pluginVersion = "0.1.1";
    var pluginName = "slidatron";
    var defaults = {
        slideSelector   : null,
        classNameSpace  : "slidatron",
		holdTime		: 9000,
		transitionTime	: 1500,
		onAfterInit		: null,
		onAfterMove		: null		
    };

    // The actual plugin constructor
    function Plugin(element, options) {

        this.element = element;

        // jQuery has an extend method which merges the contents of two or
        // more objects, storing the result in the first object. The first object
        // is generally empty as we don't want to alter the default options for
        // future instances of the plugin
        this.options = $.extend({}, defaults, options);
        this._defaults = defaults;
        this._name = pluginName;
        this.init();
    }

    Plugin.prototype = {
        slides: [],
		mapping: {},
		curIndex: 0,
		position: 0,
		slideWrapper: null,
		container: null,
		timeoutHandle: null,
        init: function () {

            // Place initialization logic here
            // You already have access to the DOM element and
            // the options via the instance, e.g. this.element
            // and this.options
            // you can add more functions like the one below and
            // call them like so: this.yourOtherFunction(this.element, this.options).
			
			// set the scope of some vars
			var options			= this.options;
			var _this			= this;
			
            // handle existing html nodes
			var $container		= $(this.element).addClass(options.classNameSpace+'-container');
            var $slides			= options.slideSelector ? $container.find(options.slideSelector) : $container.children() ;
			
			// grab the dims of the container
			var containerW		= $container.width();
			var containerH		= $container.height();
			
			// new html nodes
            var $slideWrapper	=	$('<div class="'+options.classNameSpace+'-slide-wrapper"></div>').css({
										position	: 'absolute',
										top			: 0,
										left		: 0,
										width		: $slides.length * containerW
									});
            var $ctrlWrapper	=	$('<div class="'+options.classNameSpace+'-ctrl-wrapper"></div>');
			var $next			=	$('<a class="'+options.classNameSpace+'-next">&gt;</a>').on('click',function(e) {
										e.preventDefault();
										var next = (_this.curIndex + 1) > (_this.slides.length - 1) ? 0 : _this.curIndex + 1 ;
										_this.stopShow();
										_this.move(next);
										_this.startShow();
									});
			var $prev			=	$('<a class="'+options.classNameSpace+'-prev">&lt;</a>').on('click',function(e) {
										e.preventDefault();
										var prev = (_this.curIndex - 1) < 0 ? (_this.slides.length - 1) : _this.curIndex - 1 ;
										_this.stopShow();
										_this.move(prev);
										_this.startShow();
									});

			
			// process slides
			var i = 0;
			$slides.each(function() {
				
				// get some vars
				var $this		= $(this);
				
				// this is in here 3 times
				var ids			= _this.generateIndentifiers(i);
				var className	= ids.className;
				var id			= ids.id;
				var ctrlId		= ids.ctrlId;
				
				// append the class to the elem
				$this.addClass(className+' '+id);
				
				// add the slide into the slide container
				$slideWrapper.append($this);
				
				// add a control elem for this slide
				var $ctrlElem = $('<a href="#'+id+'" id="'+ctrlId+'"></a>');
				$ctrlElem.on('click', function (e) {
					e.preventDefault();
					var index = parseInt($(this).attr('id').split('-')[3]);
					_this.stopShow();
					_this.move(index);
					_this.startShow();
				});
				$ctrlWrapper.append($ctrlElem);
				
				// cache the elems
				_this.mapping.id = {
					ctrl	: $ctrlElem,
					slide	: $this
				};
				
				// manipulate the styles
				$this.css({
					position	: 'absolute',
					top			: 0,
					left		: i * containerW,
					width		: containerW
				});			
				
				// increment counter
				i++;
				
			});
			
			// save these for later
			this.slides = $slides;
			
			// update the container styles
			$container.css({
				width		: containerW,
				height		: containerH,
				position	: 'relative',
				overflow	: 'hidden'
			});			
			
			// build the dom structure
			$container	.append($slideWrapper)
						.parent()
							.append($prev)
							.append($next)
							.append($ctrlWrapper);
						
			// initialise the position
			this.position = $slideWrapper.position().left;
			this.slideWrapper = $slideWrapper;
			this.container = $container;
						
			// attach the drag event
			$slideWrapper.drag(function( ev, dd ){

				// init vars
				var xBlown	= false; 
				var yBlown	= false;
				var c		= { x1 : -($slideWrapper.width() - containerW) , x2 : 0 };
				var n		= parseFloat(_this.position) + parseFloat(dd.deltaX);
				
				//console.log(c);
				//console.log(n);

				// block if we we've blown the containment field
				if (n < c.x1 || n > c.x2)	xBlown = true;

				// apply the css
				if (!xBlown) $slideWrapper.stop().css({left : n});
				
				// stop the slideshow while draggin
				_this.stopShow();

			}).drag("end",function( ev, dd ){

				// save the position
				_this.position = $slideWrapper.position().left;
				
				// what are we closest to?
				var cur = $slideWrapper.position().left;
				var mod = Math.abs(cur % containerW);
				var mid = Math.abs(containerW / 2);
				
				// calc some references
				var goNext = mod > mid ? true : false ;
				var index = Math.abs(goNext ? Math.floor(cur/containerW) : Math.ceil(cur/containerW));
				
				// animate to location
				_this.move(index);
				
				// start show now that we have finished
				_this.startShow();

			}).css({ 'cursor' : 'move' }); // set the cursor to the "move" one
			
			// start show now that we have  setting up
			_this.startShow();
			
			// run the post
			if (typeof options.onAfterInit == 'function') options.onAfterInit();
			
        },
		
		generateIndentifiers: function(index) {
			// this is in here 3 times
			var className	= this.options.classNameSpace+'-slide';
			var id			= className+'-'+index;
			var ctrlId		= 'ctrl-'+id;
			return {
				'className'	: className,
				'id'		: id,
				'ctrlId'	: ctrlId
			};
		},
		
		startShow: function() {
			
			// init the slideshow
			var _this = this;
			this.timeoutHandle = setInterval(function() {
				_this.timeoutCallback();
			}, this.options.holdTime);
			
			// add current to the first index
			if (!$('.slidatron-ctrl-wrapper a.current').length) {
				var ids = this.generateIndentifiers(0);
				$('.slidatron-ctrl-wrapper a').removeClass('current');
				$('#'+ids.ctrlId).addClass('current');
			}
		},
		
		stopShow: function() {
			// stop slideshow
			clearTimeout(this.timeoutHandle);			
		},		
		
		timeoutCallback: function() {
			var next = (this.curIndex + 1) > (this.slides.length - 1) ? 0 : this.curIndex + 1 ;
			this.move(next);
		},
		
		move: function(index, time) {
					
			var _this			= this;
			var $slideWrapper	= this.slideWrapper;
			var $container		= this.container;
			var target			= -(index * $container.width());			
			var next			= (target) > (this.slides.length - 1) ? 0 : target ;		
			
			if (typeof time == 'undefined') time = _this.options.transitionTime;			
			
			// do the animation
			$slideWrapper.stop().animate({
				left : next
			},time,function(){
				
				_this.position	= $slideWrapper.position().left;
				_this.curIndex	= index;
				
				// this is in here 3 times
				var ids = _this.generateIndentifiers(index);
				$('.slidatron-ctrl-wrapper a').removeClass('current');
				$('#'+ids.ctrlId).addClass('current');

				// add the curret class to the current slide
				$('.slidatron-slide').removeClass('current');
				$('.slidatron-slide-'+index).addClass('current');

				// run the post
				if (typeof _this.options.onAfterMove == 'function') _this.options.onAfterMove();				
				
			});			
			
		}
    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName, new Plugin(this, options));
            }
        });
    };

})(jQuery, window, document);
