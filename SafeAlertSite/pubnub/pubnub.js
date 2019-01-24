var PubNub = require('pubnub')
exports.subscribe = function(uuid) {

  var pubnub = new PubNub({
    subscribeKey: "",
    publishKey: "",
    secretKey: "seeeeecretss",
    ssl:true,
  })
  pubnub.addListener({
    status: function(statusEvent) {
      if (statusEvent.category === "PNConnectedCategory") {
        console.log("connected")
      }
    },
    message: function(msg) {
      console.log(msg.message);

    },
    presence: function(presenceEvent) {
        // handle presence
    }
  })
  pubnub.subscribe({
    channels: [uuid]
  });
};
