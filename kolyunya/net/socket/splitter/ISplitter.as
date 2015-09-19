package kolyunya.net.socket.splitter
{
	
	import flash.utils.ByteArray;
	
	/**
	 * An object which is responsible for (un)wrapping messages and
	 * retrieving envelopes from the stream
	 * @author Kolyunya
	 */
	public interface ISplitter
	{
		
		/**
		 * Returns a stream the splitter is currently managing
		 * @return A stream the splitter is currently managing
		 */
		function getStream():ByteArray;
		
		/**
		 * Setts a stream which the splitter should manage
		 * @param	stream A stream which the splitter should manage
		 */
		function setStream(stream:ByteArray):void
		
		/**
		 * Fetches an envelope from the currently managed stream and unwraps it
		 * @return	A message from the envelope fetched from the currently managed strem
		 */
		function fetchMessage():ByteArray;
		
		/**
		 * Fetches an envelope from the curently managed stream
		 * @return	A message contained in the envelope fetched from the stream
		 */
		function fetchEnvelope():ByteArray;
		
		/**
		 * Wraps a message into the envelope
		 * @param	message A message to be wrapped in the envelope
		 * @return 	An envelope containing the specified message
		 */
		function wrapMessage(message:ByteArray):ByteArray;
		
		/**
		 * Unwraps the envelope and retrieves the message it contains
		 * @param	envelope An envelope containing the message to be retrieved
		 * @return	A message retrieved from the envelope
		 */
		function unwrapMessage(envelope:ByteArray):ByteArray;
	
	}

}