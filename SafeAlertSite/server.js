const express = require('express');
const pug = require('pug');
var path = require('path')
var bodyParser = require('body-parser');
var PubNub = require('pubnub')
var pubTools = require('./pubnub/pubnub.js');
const app = express()
const port = 3000

app.set('view engine', 'pug')
//app.use(express.static(path.join(__dirname, '/public')));

app.use(express.static(path.join(__dirname, '/public')));
app.use(bodyParser.urlencoded({ extended: true }));

//######################################################
//PUBNUB STUFF





//######################################################
//DB STUFF
// //Set up default mongoose connection
// var mongoDB = 'mongodb://<dbuser>:<dbpassword>@ds034348.mlab.com:34348/pubnubplay'
// mongoose.connect(mongoDB)
// // Get Mongoose to use the global promise library
// mongoose.Promise = global.Promise;
// //Get the default connection
// var db = mongoose.connection;
// //Bind connection to error event (to get notification of connection errors)
// db.on('error', console.error.bind(console, 'MongoDB connection error:'));


//######################################################
//APP STUFF, VIEWS AND ALL

app.post('/publish_comment', function(req, res) {
  res.render('index',
  {

   })
  res.end('You sent the comment "' + req.body.comment + '".');
});

app.get('/',(req,res) =>{
  res.render('index',
  {
    lat: 37.33182,
    lon: -122.03118
   })
})
app.get('/user/:uuid',(req,res)=>{
  pubTools.subscribe(req.params.uuid)
  res.render('index',
  {
    lat: 37.33182,
    lon: -122.03118
  })
})

app.listen(port,()=>console.log('App listening on port' + port + '!'))
