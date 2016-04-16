//= require websocket_rails/main

// Connect to websocket
var dispatcher = new WebSocketRails('localhost:5000');

dispatcher.on_open = function(data) {  
  console.log('Connection has been established: ', data);
  dispatcher.trigger('listen', 'Hello, there!');
}

var channel = dispatcher.subscribe('updates');  
channel.bind('update', function(response) {  
  console.log(response);
});