package kolyunya.net.socket.message 
{
	
	import flash.utils.ByteArray;
	
	/**
	 * A simple message factory which treats messages as strings
	 * @author Kolyunya
	 */
	public class SimpleMessageFactory implements IMessageFactory 
	{
		
		/**
		 * @inheritDoc
		 */
		public function parse(data:ByteArray):Object 
		{
			var message:String = data.toString()
			return message;
		}
		
		/**
		 * @inheritDoc
		 */
		public function serialize(message:Object):ByteArray 
		{
			var string:String = new String(message);
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeUTFBytes(string);
			return byteArray;
		}
		
	}

}