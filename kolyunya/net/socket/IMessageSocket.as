package kolyunya.net.socket 
{
	
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import kolyunya.net.socket.message.IMessageFactory;
	import kolyunya.net.socket.stream.IStreamSplitter;
	
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
		 * Returns current socket stream splitter
		 * @return Current socket stream splitter
		 */
		function getSplitter():IStreamSplitter;
		
		/**
		 * Specifies socket stream splitter
		 * @param	ISplitter New stream splitter
		 */
		function setSplitter(splitter:IStreamSplitter):void;
		
		/**
		 * Returns current message factory used by socket
		 * @return Current message factory used by socket
		 */
		function getMessageFactory():IMessageFactory;
		
		/**
		 * Sets a message factory the socket should use
		 * @param	factory A message factory the socket should use
		 */
		function setMessageFactory(messageFactory:IMessageFactory):void;
		
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
		 * Returns a number of messages available for read
		 * @return A number of messages available for read
		 */
		function getMessagesCount():uint;
		
		/**
		 * Tells if the socket has input messages available
		 * @return A boolean indicating if the socket has input messages available
		 */
		function hasInputMessages():Boolean;
		
		/**
		 * Reads a message from the socket
		 * @return	A message read from the socket
		 */
		function readMessage():Object;
		
		/**
		 * Writes the message to the socket
		 * @param	messageData A message to be written to the socket
		 */
		function writeMessage(messageData:Object):void;
		
		/**
		 * Flushes all accumulated messages in the socket's output buffer
		 */
		function flushMessages():void;
		
	}
	
}