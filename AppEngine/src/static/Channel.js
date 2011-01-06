/**
 * 
 */

function {
	// Channel to actionscript object
	// Javascript in JSON Notation
	CTA = {
			// Open a channel to the google appengine. The connection
			// is setup in this function.
			openChannel : function(token){
				var channel = new goog.appengine.Channel(token);
				var handler = {
					'onopen' : CTA.onOpen,				/* Called when the channel is opened */
					'onmessage': CTA.onMessage,			/* Called when a message is received */
					'onerror' : CTA.onError,			/* Called upon any error */
					'onclose' : CTA.onClose,			/* Called when the channel is closed */
				};
				var socket = channel.open(handler);
				
				// Setup the socket level handlers
				socket.onopen = CTA.onOpen;
				socket.onmessage = CTA.onMessage;
				socket.onerror =  CTA.onError;
				socket.onclose = CTA.onClose;
			}
	
			getSWF : function() {
				return document.getElementById("flashContent");
			}
			
			// Call of the relevant functions in actionsricpt associated with the 
			// channel data
			onOpen : function() {
				swf = CTA.getSWF();
				swf.onChannelOpen();
			}
			onMessage : function(message) {
				swf = CTA.getSWF();
				swf.onChannelMessage(message);
			}
			onError : function(error) {
				swf = CTA.getSWF();
				swf.onChannelError(error);
			}
			onClose : function() {
				swf = CTA.getSWF();
				swf.onChannelClose();
			}
	};
}