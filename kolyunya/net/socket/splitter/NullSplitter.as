package kolyunya.net.socket.splitter
{
	
	import flash.utils.ByteArray;
	
	/**
	 * A stream splitter which splits the stream by the null byte
	 * @author Kolyunya
	 */
	public class NullSplitter extends AbstractSplitter implements ISplitter
	{
		
		/**
		 * @inheritDoc
		 */
		override public function fetchEnvelope():ByteArray
		{
			var position:int = this.stream.position;
			while (position < this.stream.length)
			{
				var byte:int = this.stream[position];
				if (byte == 0)
				{
					var envelope:ByteArray = new ByteArray();
					var envelopeLength:int = position - this.stream.position + 1;
					this.stream.readBytes(envelope, 0, envelopeLength);
					if (position + 1 == this.stream.length)
					{
						this.stream.clear();
					}
					return envelope;
				}
				position++;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function wrapMessage(message:ByteArray):ByteArray
		{
			// Construct an empty envelope
			var envelope:ByteArray = new ByteArray();
			
			// Put the message to the envelope
			envelope.writeBytes(message);
			
			// Put the delimiter to the envelope
			envelope.writeByte(0);
			
			return envelope;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function unwrapMessage(envelope:ByteArray):ByteArray
		{
			// Construct an empty message
			var message:ByteArray = new ByteArray();
			
			// Calculate the message length
			var envelopeLength:uint = envelope.length;
			var messageLength:uint = envelopeLength - 1;
			
			// Copy message from envelope to message
			message.writeBytes(envelope, 0, messageLength);
			
			return message;
		}
	
	}

}