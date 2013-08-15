/**
 *	This is a resource loader 
 *	the idea is that all the tracking is global so this thing can be loaded at will and it wont mess with pre exisiting loads etc
 */

function include(scripts, callback) {
	
	// Vars
	// ------------------------------------------
	
	var revision = '0.2.0';
	var i, ii, e, script, proceed;
	var namespace = 'set-'+Math.round(Math.random()*100000000);	
	
	// Make sure the environment is sane
	// ------------------------------------------

	// init the global tracking object
	if (typeof window.includa == 'undefined') {
		window.includa = {
			loaded	: {},
			loading	: {},
			elems	: {}
		};
	}

	// init the loading tracking object for this script set
	if (typeof window.includa[namespace] == 'undefined') {
		window.includa[namespace] = {
			loaded	: 0,
			total	: 0
		};
	}
	
	// Static Helper Methods
	// ------------------------------------------

	/**
	 *	Adds a script to the document and the loading register
	 *	
	 *	@param	e		obj			a DOM object representing the script element
	 *	@param	script	obj/string	a string containing the path to the script or and object with key and val indexes i.e. {key : 'the-key-for-the-script', val : 'the/path/to/the/script'}
	 *	@return			obj			the include object for chaining
	 */
	include.addScript = function(e, script) {
		var key = typeof script == 'object' ? script.key : script;
		var val = typeof script == 'object' ? script.val : script;		
		e.type = "text/javascript";
		e.src = val;
		document.getElementsByTagName("head")[0].appendChild(e);
		window.includa.elems[key] = e;
	};
	
	/**
	 *	Gets a cached script element from the element cache
	 *	
	 *	@param	key		string/int	the index of element
	 *	@return			obj			a DOM object representing the script element or 
	 *					false		if the element doesn't exist in the register
	 */
	include.getElem = function(key) {
		if (typeof window.includa.elems[key] !== 'undefined') return window.includa.elems[key];
		return false;
	};
	
	/**
	 *	Adds a script to the loading register
	 *	
	 *	@param	script	obj/string	a string containing the path to the script or and object with key and val indexes i.e. {key : 'the-key-for-the-script', val : 'the/path/to/the/script'}
	 *	@return			obj			the include object for chaining
	 */
	include.addToLoading = function(script) {
		var key = typeof script == 'object' ? script.key : script;
		var val = typeof script == 'object' ? script.val : script;
		window.includa.loading[key] = (val);
		return include;
	};
	
	/**
	 *	Adds a script to the document and the loaded register
	 *	
	 *	@param	script	obj/string	a string containing the path to the script or and object with key and val indexes i.e. {key : 'the-key-for-the-script', val : 'the/path/to/the/script'}
	 *	@return			obj			the include object for chaining
	 */
	include.addToLoaded = function(script) {
		var key = typeof script == 'object' ? script.key : script;
		var val = typeof script == 'object' ? script.val : script;		
		window.includa.loaded[key] = val;
		return include;
	};

	/**
	 *	Removes a script from the loading register
	 *	
	 *	@param	key		string/int	the index of the script in the register
	 *	@return			obj			the include object for chaining
	 */
	include.removeFromLoading = function(key) {
		var ii;
		for (ii in window.includa.loading) {
			if (ii == key) delete(window.includa.loading[ii]);
		}			
		return include;	
	};
	
	/**
	 *	Removes a script from the loaded register
	 *	
	 *	@param	key		string/int	the index of the script in the register
	 *	@return			obj			the include object for chaining
	 */
	include.removeFromLoaded = function(key) {
		var ii;
		for (ii in window.includa.loaded) {
			if (ii == key) delete(window.includa.loaded[ii]);
		}			
		return include;			
	};

	/**
	 *	Identifies if a script is in the loading register
	 *	
	 *	@param	key		string/int	the index of the script in the register
	 *	@return			bool	
	 */
	include.isLoading = function(key) {
		var ii;
		for (ii in window.includa.loading) {
			if (ii == key) return true;
		}
		return false;
	};
	
	/**
	 *	Identifies if a script is in the loaded register
	 *	
	 *	@param	key		string/int	the index of the script in the register
	 *	@return			bool	
	 */
	include.isLoaded = function(key) {
		var ii;
		for (ii in window.includa.loaded) {
			if (ii == key) return true;
		}
		return false;			
	};

	/**
	 *	gets all the keys defined on an object
	 *	
	 *	@param	obj		obj		the object to get the keys from
	 *	@return			array
	 */
	include.objKeys = function(obj) {
		var keys = [],
			k;
		for (k in obj) {
			if (Object.prototype.hasOwnProperty.call(obj, k)) {
				keys.push(k);
			}
		}
		return keys;
	};
	
	/**
	 *	adds an event handler to a DOM element
	 *	
	 *	@param	obj		obj			The DOM element to attach the event handler to
	 *	@param	e		string		The event to attach the callback to minus any on prefix i.e. an onload event would use the string 'load'
	 *	@param	func	function	The callback function
	 *	@return			void
	 */	
	include.add_e_handler = function(obj, e, func) {
		//test if func exists - prevents problems in IE
		if(typeof func != "undefined" && typeof obj != "undefined" && obj){		
			if(obj.attachEvent){
				obj.attachEvent('on' + e, func);
			}else if(obj.addEventListener){
				obj.addEventListener(e, func, false);
			}else{
				obj['on' + e] = func;
			}
		}
	}

	/**
	 *	removes an event handler from a DOM element
	 *	
	 *	@param	obj		obj			The DOM element to remove the event handler from
	 *	@param	e		string		The event the callback was attached to minus any on prefix i.e. an onload event would use the string 'load'
	 *	@param	func	function	The handle to the callback function
	 *	@return			void
	 */
	include.remove_e_handler = function(obj, e, func) {
		//test if func exists - prevents problems in IE		
		if(typeof func != "undefined" && typeof obj != "undefined" && obj){
			if (obj.detachEvent){
				obj.detachEvent('on' + e, func);
			}else if(obj.removeEventListener){
				obj.removeEventListener(e, func, false);
			}else{
				obj['on' + e] = null;
			}
		}
	}	
	
	// The Actual Bidniz
	// ---------------------------------------------

	if (typeof scripts == 'object' && Array.isArray(scripts)) {

		// save the length of the script list
		window.includa[namespace].total = scripts.length;

		// load each script
		for (i=0; i < scripts.length; i++) {

			// get the current script
			script = scripts[i];

			// do we need to load this script?
			proceed = true;

			// dont proceed if its already loaded
			if (include.isLoaded(script)) proceed = false;		

			// do we need to actually load it or just check if the callback needs to be called
			if (proceed) {

				// create the script element
				e = include.isLoading(script) ? include.getElem(script) : document.createElement('script');

				// define the onload behaviour
				include.add_e_handler(e, 'load', function() {

					// increment the loaded thingy what's it
					window.includa[namespace].loaded++;

					// add the script to the loaded tracker
					include.addToLoaded(script);

					// remove the script from the loading tracker
					include.removeFromLoading(script);

					// call the complete callback if we are finished loading
					if (typeof callback == 'function' && window.includa[namespace].loaded == window.includa[namespace].total) callback();
					
				});
				
				// init load if its not already loading
				if (!include.isLoading(script)) {
					
					// handle the script element
					include.addScript(e, script);

					// add the script to the loading tracker
					include.addToLoading(script);
				
				}

			} else {

				// increment the loaded thingy what's it
				window.includa[namespace].loaded++;

				// if its time to call the callback then lets go
				if (typeof callback == 'function' && window.includa[namespace].loaded == window.includa[namespace].total) callback();

			}

		}
		
	} else if (typeof scripts == 'object') {

		// save the length of the script list
		window.includa[namespace].total = include.objKeys(scripts).length;

		// load each script
		for (i in scripts) {

			// get the current script
			script = scripts[i];

			// do we need to load this script?
			proceed = true;

			// dont proceed if its already loaded
			if (include.isLoaded(i)) proceed = false;		

			// do we need to actually load it or just check if the callback needs to be called
			if (proceed) {

				// create the script element
				e = include.isLoading(i) ? include.getElem(i) : document.createElement('script');

				// define the onload behaviour
				include.add_e_handler(e, 'load', function() {

					// increment the loaded thingy what's it
					window.includa[namespace].loaded++;

					// add the script to the loaded tracker
					include.addToLoaded({key : i, val : script});

					// remove the script from the loading tracker
					include.removeFromLoading(i);

					// call the complete callback if we are finished loading
					if (typeof callback == 'function' && window.includa[namespace].loaded == window.includa[namespace].total) callback();
					
				});
				
				// init load if its not already loading
				if (!include.isLoading(i)) {
					
					// handle the script element
					include.addScript(e, {key : i, val : script});

					// add the script to the loading tracker
					include.addToLoading({key : i, val : script});
					
				}

			} else {

				// increment the loaded thingy what's it
				window.includa[namespace].loaded++;

				// if its time to call the callback then lets go		
				if (typeof callback == 'function' && window.includa[namespace].loaded == window.includa[namespace].total) callback();

			}

		}

	} else if (typeof scripts == 'string') {

		// get the current script
		script = scripts;

		// do we need to load this script?
		proceed = true;

		// dont proceed if its already loaded
		if (include.isLoaded(script)) proceed = false;	

		// do we need to actually load it or just check if the callback needs to be called
		if (proceed) {			

			// create the script element
			e = include.isLoading(script) ? include.getElem(script) : document.createElement('script');

			// define the onload behaviour
			include.add_e_handler(e, 'load', function() {

				// add the script to the loaded tracker
				include.addToLoaded(script);

				// remove the script from the loading tracker
				include.removeFromLoading(script);

				// call the callback
				if (typeof callback == 'function') callback();
				
			});
			
			// init load if its not already loading
			if (!include.isLoading(script)) {
				
				// handle the script element
				include.addScript(e, script);

				// add the script to the loading tracker
				include.addToLoading(script);
				
			}

		} else {

			// call the call back
			if (typeof callback == 'function') callback();

		}			

	}

}