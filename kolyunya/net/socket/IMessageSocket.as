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
		 * Attempts to connect to the specified host and port
		 * This method should be used instead on "connect" in order
		 * the reconnect to work properly
		 * @param	host	A host to connect to
		 * @param	port	A port to connect to
		 */
		function connectTo(host:String, port:uint):void;
		
		/**
		 * Returns a reconnect timeout in milliseconds
		 * @return A reconnect timeout in milliseconds
		 */
		function getReconnectTimeout():uint;
		
		/**
		 * Sets a reconnect timeout
		 * @param	timeout	A reconnect timeout in milliseconds
		 */
		function setReconnectTimeout(reconnectTimeout:uint):void;
		
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