package kolyunya.net.socket.splitter
{
	
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import kolyunya.net.socket.splitter.ISplitter;
	
	/**
	 * An abstract implementation of base splitter.
	 * @author Kolyunya
	 */
	public class AbstractSplitter implements ISplitter
	{
		
		/**
		 * A reference to the stream the splitter is currently managing
		 */
		protected var stream:ByteArray;
		
		/**
		 * @inheritDoc
		 */
		public function getStream():ByteArray
		{
			return this.stream;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setStream(stream:ByteArray):void
		{
			this.stream = stream;
		}
		
		/**
		 * @inheritDoc
		 */
		public function fetchMessage():ByteArray
		{
			var envelope:ByteArray = this.fetchEnvelope();
			if (envelope == null)
			{
				return null;
			}
			var message:ByteArray = this.unwrapMessage(envelope);
			return message;
		}
		
		/**
		 * @inheritDoc
		 */
		public function fetchEnvelope():ByteArray
		{
			// This method must be implemented in concrete splitters
			throw new IllegalOperationError("This method can not be called on an abstract splitter");
		}
		
		/**
		 * @inheritDoc
		 */
		public function wrapMessage(message:ByteArray):ByteArray
		{
			// This method must be implemented in concrete splitters
			throw new IllegalOperationError("This method can not be called on an abstract splitter");
		}
		
		/**
		 * @inheritDoc
		 */
		public function unwrapMessage(envelope:ByteArray):ByteArray
		{
			// This method must be implemented in concrete splitters
			throw new IllegalOperationError("This method can not be called on an abstract splitter");
		}
		
	}

}