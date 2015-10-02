package kolyunya.net.socket.message 
{
	
	import flash.utils.ByteArray;
	
	/**
	 * Message factory which is responsible for deserializing/serializing
	 * messages from/into raw byte arrays
	 * @author Kolyunya
	 */
	public interface IMessageFactory 
	{
		
		/**
		 * Parses raw data into a message object
		 * @param	data Raw data containing a serialized message
		 * @return	A message parsed from raw data
		 */
		function parse(data:ByteArray):Object;
		
		/**
		 * Serializes a message object into a byte array which can be sent over a socket
		 * @param	message	A message object to be serialized
		 * @return	A byte array representing a serialized message	
		 */
		function serialize(message:Object):ByteArray;
		
	}
	
}