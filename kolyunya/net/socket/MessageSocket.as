package kolyunya.net.socket
{
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
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
		 * Reconnect timer
		 */
		private var reconnectTimer:Timer;
		
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
		public function MessageSocket(host:String = null, port:int = 0)
		{
			this.initializeReconnectTimer();
			this.initializeReceivedData();
			this.initializedReceivedMessages();
			this.initializeEventListener();
			this.setPeerAddress(host, port);
			super(host, port);
		}
		
		/**
		 * Attempts to connect to the specified host and port
		 * @param	host	A host to connect to
		 * @param	port	A port to connect to
		 */
		function connectTo(host:String, port:uint):void
		{
			this.setPeerAddress(host, port);
			this.connect(host, port);
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
			if (this.connected == false )
			{
				this.reconnectTimer.start();
			}
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
		 * Initializes the reconnect timer with the default timeout
		 */
		private function initializeReconnectTimer():void
		{
			this.reconnectTimer = new Timer(MessageSocket.DEFAULT_RECONNECT_TIMEOUT, 1);
			this.reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.reconnect);
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
			this.addEventListener(Event.CLOSE, this.startReconnectTimer);
			this.socket.addEventListener(IOErrorEvent.IO_ERROR, this.startReconnectTimer);
			this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.startReconnectTimer);
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
			var message:ByteArray = this.splitter.fetchMessage();
			if (message != null)
			{
				// Dispatch a corresponding event if a message was received
				var messageEvent:Event = new Event(MessageSocket.MESSAGE_RECEIVED);
				this.dispatchEvent(messageEvent);
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