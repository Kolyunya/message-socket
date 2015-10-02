package kolyunya.net.socket
{
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import kolyunya.net.socket.message.IMessageFactory;
	import kolyunya.net.socket.message.SimpleMessageFactory;
	import kolyunya.net.socket.stream.IStreamSplitter;
	import kolyunya.net.socket.stream.NullStreamSplitter;
	
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
		 * Default reconnect timeout is 10 seconds
		 */
		private static const DEFAULT_RECONNECT_TIMEOUT:uint = 10 * 1000;
		
		/**
		 * A host adders to which the last connection was attempted to be made
		 */
		private var host:String;
		
		/**
		 * A port number to which the last connection was attempted to be made
		 */
		private var port:uint;
		
		/**
		 * Current stream splitter used by the socket
		 */
		private var streamSplitter:IStreamSplitter;
		
		/**
		 * Current message factory used by the socket
		 */
		private var messageFactory:IMessageFactory;
		
		/**
		 * Reconnect timer
		 */
		private var reconnectTimer:Timer;
		
		/**
		 * Receieved data buffer
		 */
		private var receivedData:ByteArray;
		
		/**
		 * Received messages buffer. Used as a FIFO queue.
		 */
		private var receivedMessages:Array;
		
		/**
		 * Constructs a new message socket
		 * @param	host Peer host address
		 * @param	port Peer port
		 */
		public function MessageSocket(host:String = null, port:int = 0)
		{
			this.initializeDataBuffer();
			this.initializedMessageBuffer();
			this.initializeEventListeners();
			this.initializeStreamSplitter();
			this.initializeMessageFactory();
			this.initializeReconnectTimer();
			this.setPeerAddress(host, port);
			super(host, port);
		}
		
		/**
		 * Attempts to connect to the specified host and port
		 * @param	host	A host to connect to
		 * @param	port	A port to connect to
		 */
		public function connectTo(host:String, port:uint):void
		{
			this.setPeerAddress(host, port);
			this.connect(host, port);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getSplitter():IStreamSplitter
		{
			return this.streamSplitter;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setSplitter(splitter:IStreamSplitter):void
		{
			this.streamSplitter = splitter;
			this.streamSplitter.setStream(this.receivedData);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getMessageFactory():IMessageFactory
		{
			return this.messageFactory;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setMessageFactory(messageFactory:IMessageFactory):void
		{
			this.messageFactory = messageFactory;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getReconnectTimeout():uint
		{
			return this.reconnectTimer.delay;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setReconnectTimeout(reconnectTimeout:uint):void
		{
			this.reconnectTimer.reset();
			this.reconnectTimer.delay = reconnectTimeout;
			if (this.connected == false)
			{
				this.reconnectTimer.start();
			}
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
		public function hasInputMessages():Boolean
		{
			var inputMessagesCount:uint = this.getMessagesCount();
			var hasInputMessages:Boolean = inputMessagesCount > 0;
			return hasInputMessages;
		}
		
		/**
		 * @inheritDoc
		 */
		public function readMessage():Object
		{
			// Retrieve the first element of the FIFO queue
			var messageData:ByteArray = this.receivedMessages.pop();
			var message:Object = this.messageFactory.parse(messageData);
			return message;
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeMessage(messageData:Object):void
		{
			var message:ByteArray = this.messageFactory.serialize(messageData);
			var envelope:ByteArray = this.streamSplitter.wrapMessage(message);
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
		private function initializeDataBuffer():void
		{
			this.receivedData = new ByteArray();
		}
		
		/**
		 * Initializes the received messages buffer
		 */
		private function initializedMessageBuffer():void
		{
			this.receivedMessages = new Array();
		}
		
		/**
		 * Subscibes the message socket to the TCP socket data event
		 */
		private function initializeEventListeners():void
		{
			this.addEventListener(ProgressEvent.SOCKET_DATA, this.processInputData);
			this.addEventListener(Event.CLOSE, this.startReconnectTimer);
			this.addEventListener(IOErrorEvent.IO_ERROR, this.startReconnectTimer);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.startReconnectTimer);
		}
		
		/**
		 * Initializes the reconnect timer with the default timeout
		 */
		private function initializeReconnectTimer():void
		{
			this.reconnectTimer = new Timer(MessageSocket.DEFAULT_RECONNECT_TIMEOUT, 1);
			this.reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.reconnect);
		}
		
		/**
		 * Initializes the default stream splitter
		 */
		public function initializeStreamSplitter():void
		{
			this.streamSplitter = new NullStreamSplitter();
		}
		
		/**
		 * Initializes the default message factory
		 */
		public function initializeMessageFactory():void
		{
			this.messageFactory = new SimpleMessageFactory();
		}
		
		/**
		 * Saves peer's host and port
		 * @param	host	Peer's host
		 * @param	port	Peer's port
		 */
		private function setPeerAddress(host:String, port:uint):void
		{
			this.host = host;
			this.port = port;
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
			var message:ByteArray = this.streamSplitter.fetchMessage();
			if (message != null)
			{
				// Save the message as the last element of the message buffer
				this.receivedMessages.push(message);
				
				// Dispatch a corresponding event if a message was received
				var messageEvent:Event = new Event(MessageSocket.MESSAGE_RECEIVED);
				this.dispatchEvent(messageEvent);
				
				// Check if there are any other messages available.
				// The "fetchMessage" fetches only first message while
				// there can be more than one available already.
				this.processInputData(null);
			}
		}
		
		/**
		 * Starts the reconnect timer
		 * @param	event Disconnect or error event emitted by the TCP socket
		 */
		private function startReconnectTimer(event:*):void
		{
			this.reconnectTimer.start();
		}
		
		/**
		 * Attempts to reconnect to the peer
		 * @param	event Timer event emitted by the reconnect timer
		 */
		private function reconnect(event:TimerEvent):void
		{
			this.connectTo(this.host, this.port);
		}
	
	}

}