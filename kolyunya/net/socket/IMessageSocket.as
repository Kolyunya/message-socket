package kolyunya.net.socket 
{
	
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import kolyunya.net.socket.splitter.ISplitter;
	
	/**
	 * A socket which abstracts away from raw data streams
	 * and operates with separated data messages
	 * @author Kolyunya
	 */
	public interface IMessageSocket extends IEventDispatcher
	{
		
		/**
		 * Returns current socket stream splitter
		 * @return Current socket stream splitter
		 */
		function getSplitter():ISplitter;
		
		/**
		 * Specifies socket stream splitter
		 * @param	ISplitter New stream splitter
		 */
		function setSplitter(splitter:ISplitter):void;
		
		/**
		 * Returns a number of messages available for read
		 * @return A number of messages available for read
		 */
		function getMessagesCount():uint;
		
		/**
		 * Reads a message from the socket
		 * @return	A message read from the socket
		 */
		function readMessage():ByteArray;
		
		/**
		 * Writes the message to the socket
		 * @param	message A message to be written to the socket
		 */
		function writeMessage(message:ByteArray):void;
		
		/**
		 * Flushes all accumulated messages in the socket's output buffer
		 */
		function flushMessages():void;
		
	}
	
}