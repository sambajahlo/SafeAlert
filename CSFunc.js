//The app uses channel send_text so make sure to set that as the channel name in your function
//Also set it as after fire or publish
//Make sure you replace the key and username below
// require console module for logging to console
const console = require('console');

const pubnub = require('pubnub');

// require xhr
const xhr = require('xhr');

const auth = require('codec/auth');

export default (request) => {

    //  api key
    const apiUsername = 'INSERT CLICKSEND USERNAME HERE';
    const apiKey = 'INSERT CLICKSEND API KEY HERE'

    // api endpoint
    const apiUrl = 'https://rest.clicksend.com/v3/sms/send';

    //building the message
    const message = "Claire wants you to know where she is, find her at ";
    const url = "https://safealert.herokuapp.com/uuid/" + request.message.uuid + "/lat/"+ request.message.lat + "/lon/" + request.message.lon;
    const channel = request.channels[0];

    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            Authorization: auth.basic(apiUsername, apiKey)
        },
        body: JSON.stringify({messages: [{
            source: "blocks",
            body: message + url,
            from: "SafeAlert",
            to: request.message.to
        }]})

    };


    // create a HTTP POST request to the ClickSend API
    return xhr.fetch(apiUrl, options).then((r) => {
        console.log(r);

        let testResponse = 0;
        if (r.status == 200) {
            testResponse = 1;
        }
        pubnub.publish({
            channel: responseChannel,
            message: testResponse
        });
        return request.ok()
    })
    .catch(e => {
        console.error(e);
        pubnub.publish({
            channel: responseChannel,
            message: 0
        });
        return request.ok();
    });
};
