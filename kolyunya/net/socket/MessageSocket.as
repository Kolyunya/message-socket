package kolyunya.net.socket 
{
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import kolyunya.net.socket.splitter.ISplitter;
	
	/**
	 * ...
	 * @author Kolyunya
	 */
	public class MessageSocket extends flash.net.Socket
	{
		
		/**
		 * Dispatched when a complete message was received by the message socket
		 * @eventType	kolyunya.net.message.Socket.MESSAGE_RECEIVED
		 */
		[Event(name = "messageReceived", type = "flash.events.Event")]
		
		/**
		 * A type of the event which is dispatched when a complete message is received
		 */ 
		public static const MESSAGE_RECEIVED:String = "MESSAGE_RECEIVED";
		
		/**
		 * Current socket stream splitter
		 */
		private var splitter:ISplitter;
		
		/**
		 * Receieved data buffer
		 */
		private var receivedData:ByteArray;
		
		/**
		 * Received messages buffer
		 */
		private var receivedMessages:Array;
		
		/**
		 * Constructs a new message socket
		 * @param	host Peer host address
		 * @param	port Peer port
		 */
		public function MessageSocket(host:String=null, port:int=0) 
		{
			this.initializeReceivedData();
			this.initializedReceivedMessages();
			this.initializeEventListener();
			super(host, port);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getSplitter():ISplitter
		{
			return this.splitter;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setSplitter(splitter:ISplitter):void
		{
			this.splitter = splitter;
			this.splitter.setStream(this.receivedData);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getMessagesCount():uint
		{
			return this.receivedMessages.length;
		}
		
		/**
		 * @inheritDoc
		 */
		public function readMessage():ByteArray
		{
			return this.receivedMessages.pop();
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeMessage(message:ByteArray):void
		{
			var envelope:ByteArray = this.splitter.wrapMessage(message);
			this.writeBytes(envelope);
		}
		
		/**
		 * @inheritDoc
		 */
		public function flushMessages():void
		{
			this.flush();
		}
		
		/**
		 * Initializes the received data buffer
		 */
		private function initializeReceivedData():void
		{
			this.receivedData = new ByteArray();
		}
		
		/**
		 * Initializes the received messages buffer
		 */
		private function initializedReceivedMessages():void
		{
			this.receivedMessages = new Array();
		}
		
		/**
		 * Subscibes the message socket to the TCP socket data event
		 */
		private function initializeEventListener():void
		{
			this.addEventListener(ProgressEvent.SOCKET_DATA, this.processInputData);
		}
		
		/**
		 * Process received input data
		 * @param	event Progress event emitted by the TCP socket
		 */
		private function processInputData(event:ProgressEvent):void
		{
			// Fetch all awailable data to the buffer
			this.readBytes(this.receivedData);
			
			// Chek if there are any complete messages in the buffer yet
			var message:ByteArray = this.splitter.fetchMessage();
			if (message != null)
			{
				// Dispatch a corresponding event if a message was received
				var messageEvent:Event = new Event(kolyunya.net.message.Socket.MESSAGE_RECEIVED);
				this.dispatchEvent(messageEvent);
			}
		}
		
	}

}