/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Eddy Borja
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

// TODO: Use production openTok credentials
var opentok = require("cloud/opentok/opentok.js").createOpenTokSDK("45191152", "dab577a16fb5088001efc983e38795851dc16c66");

var Session = Parse.Object.extend("Session");

// TODO: Use production twilio credentials
var twilio = require('twilio')('AC5a7843b8b6fea6f713907d97ab89b161', '52d7fbb9bad38a39d55ca80e5404c25b')

var Stripe = require('stripe');
// TODO: Use production stripe credentials
Stripe.initialize('sk_live_Q00GHfCRD5ud04gpmUAbVAFd');


/**
* Start a transfer using Stripe to specified recipient
* Takes the credit amount and divides it by 20, or $5 for 100 credits. 
*
* @param {string} request.params.credits The amount of credits to be transferred
* @param {string} request.params.userObjectId The user's recipient account to send the money to
* @return {HTTPResponse} either returns an http error or the success dictionary sent by Stripe
*/
Parse.Cloud.define("startTransfer", function(request, response) {
  var userObjectId = request.params.userObjectId;
  var credits = request.params.credits;
  var StripeRecipient = Parse.Object.extend("StripeRecipient");
  var stripeRecipientQuery = new Parse.Query(StripeRecipient);

  stripeRecipientQuery.equalTo("user_id", userObjectId);
  stripeRecipientQuery.find({
    success: function(results) {
      if(results.length == 0) {
        
      } else if(results.length == 1) {
        var recipient = results[0];
        // handle returning customer adding a new card
        var recipientId = recipient.get("recipient_id");

        var params = [];
        params["amount"] = credits/20;
        params["currency"] = "USD";
        params["recipient"] = recipientId;

        Parse.Cloud.httpRequest({
          method: 'POST',
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer sk_test_ukk7e8B46I39nxoUd6XILpPZ' // TODO : Use production stripe credentials
           },
          url: 'https://api.stripe.com/v1/transfers',
          params: params,
          success: function(httpResponseInner) {
            console.log(httpResponseInner.text);
            response.success(httpResponseInner);
          },
          error: function(httpResponse) {
            console.error('Request failed with response code ' + httpResponse.status);
            response.error(httpResponse);
          }
        });
      }
    }, error: function(error) {
        reponse.error(error);          
    }
  });
});

/**
* Add a bank account to the user object
* Two main cases: (1) recipient doesn't exist (2) update existing recipient
*
* @param {string} request.params.userObjectId The user's recipient account to send the money to
* @return {HTTPResponse} either returns an http error or the success dictionary sent by Stripe
*/
Parse.Cloud.define("addPaymentSource", function(request, response) {
    console.log(request.params);
    var userObjectId = request.params.userObjectId;
    var StripeRecipient = Parse.Object.extend("StripeRecipient");
    var stripeRecipientQuery = new Parse.Query(StripeRecipient);

    stripeRecipientQuery.equalTo("userObj", userObjectId);
    stripeRecipientQuery.find({
      success: function(stripeRecipients) {
        if(stripeRecipients.length == 0) {
          // create a new 
          var recipientParams = [];
          recipientParams["name"] = Parse.User.current().get("first_name") + ' ' + Parse.User.current().get("last_name");
          recipientParams["type"] = "individual";
          recipientParams["email"] = Parse.User.current().get("email");
          recipientParams["bank_account"] = request.params.token;

          Parse.Cloud.httpRequest({
            method: 'POST',
            headers:{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer sk_test_ukk7e8B46I39nxoUd6XILpPZ'// TODO: Use production stripe credentials
             },
            url: 'https://api.stripe.com/v1/recipients',
            params: recipientParams,
            success: function(httpResponse) {
              var recipient = new StripeRecipient();
              recipient.set("user_id", Parse.User.current().id);
              console.log(httpResponse.data.id);
              recipient.set("recipient_id", httpResponse.data.id);
              recipient.save();
              response.success(httpResponse);
            }, error: function(httpError) {
              response.error(httpError);
            }
          });
        } else {
          // update bank token on existing recipient
          var recipientParams = [];

          var stripeRecipient = stripeRecipients[0];
          var recipientToken = stripeRecipient.get("recipientId");
          recipientParams["bank_account"] = request.params.token;
          Parse.Cloud.httpRequest({
            method: 'POST',
            headers:{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer sk_test_ukk7e8B46I39nxoUd6XILpPZ' // TODO : Use production stripe credentials
            },
            url: 'https://api.stripe.com/v1/recipients' + recipientToken,
            params: recipientParams,
            success: function(httpResponse) {
              stripeRecipient.set("tokenId", request.params.token);
              stripeRecipient.save();
              response.success(httpResponse);
            }, 
            error: function(httpError) {
              response.error(httpError);
            }  
          }); 
        }
      }, error: function(stripeRecipientError) {
        response.error(stripeRecipientError);
      }
    });
});


/**
* Send verification code to given phone number and store that code in the user object
* Randomly generates a 5 digit number and sets it to the current user, and then sends the text using twilio
*
* @param {string} request.params.phoneNumber The user's enterred phone number to be verified
* @return {HTTPResponse} either returns an error message or the word Success.
*/
Parse.Cloud.define("sendVerificationCode", function(request, response) {
    var verificationCode = Math.floor(Math.random()*999999);
    var user = Parse.User.current();
    user.set("phoneVerificationCode", verificationCode);
    user.save();
    // TODO: your twilio test number
    twilio.sendSms({
        From: "(855) 463-9362",
        To: request.params.phoneNumber,
        Body: "Your verification code is " + verificationCode + "."
    }, function(err, responseData) { 
        if (err) {
          response.error(err);
        } else { 
          response.success("Success");
        }
    });
});

/**
* Verify the given code with the user's phone number to make sure it's the right code
*
* @param {string} request.params.phoneVerificationCode The user's enterred verification code to be verified
* @return {HTTPResponse} either returns an error message or the word Success.
*/

Parse.Cloud.define("verifyPhoneNumber", function(request, response) {
    var user = Parse.User.current();
    var verificationCode = user.get("phoneVerificationCode");
    if (verificationCode == request.params.phoneVerificationCode) {
        user.set("phoneNumber", request.params.phoneNumber);
        user.save();
        response.success("Success");
    } else {
        response.error("Invalid verification code.");
    }
});

/**
*
* The rest of this code is created by Eddy Borja, using the OpenTok framework and cloud module to create his code. Check OpenTok and Parse documentation.
*/
// Use Parse.Cloud.define to define as many cloud functions as you want.
Parse.Cloud.define("joinSession", function(request, response) {
  var query = new Parse.Query(Session);
  var channel = request.params.channel_name;
  var facebookId = request.params.facebookId;
  
  if(!channel){
    return response.error("No channel name was received.");
  }  

  query.equalTo("channel_name", channel);

  query.first().then(function(object){
      if(!object){
        var session = new Session();
        session.set("channel_name", channel);
        session.set("facebookId", facebookId);
        session.save().then(function(object){
          return response.success(object);
        }, function(error){
          return response.error("Couldn't create and save new session: " + error.description);
        });
      } else {
        return response.success(object);
      }
  }, function(error){
      return response.error("Couldn't search for session: " + error.description);
  });

});

// Start Session will create a session and return the Session Object. 
Parse.Cloud.define("startSession", function(request, response) {

  var facebookId = request.params.facebookId;
  var hostName = request.params.hostName;
  var title = request.params.chatTitle;
  var description = request.params.chatDescription;
  
  if(!facebookId){
    return response.error("The host's facebookID wasn't specified with the 'facebookId' key");  
  }

  if(!hostName){
    return response.error("The host's first name was not specified with the 'hostName' key.");
  }

  if(!title){
    return response.error("The session title was not specified with the 'chatTitle' key.");
  }

  if(!description){
    return response.error("The session's description was not specified with the 'chatDescription' key.");
  }

  var session = new Session();

  session.set("facebookId", facebookId);
  session.set("hostName", hostName);
  session.set("chatTitle", title);
  session.set("chatDescription", description);

  session.save().then(function(object){
    return response.success(object);
  }, function(error){
    return response.error("Couldn't create and save new session: " + error.description);
  });

});


// For example:
Parse.Cloud.beforeSave("Session", function (request, response) {
  //get the session object being saved
  var session = request.object;

  if (!session.get("facebookId")) {
    response.error("Sessions must have a facebookId");
    return;
  } else {
    var query = new Parse.Query(Session);
    query.equalTo("facebookId", session.get("facebookId"));
    query.first().then(function(object) {
        if (object) {
          object.destroy();
        } 
      }, function(error){
        response.error("Could not validate uniqueness for Session: " + error.description);
        return;
      });
  }

  //Check if the session object has already gotten a sessionID form opentok
  if (session.get("sessionID")) {
    response.success();
    return;
  }

  //Create a session if one doesn't exist
  opentok.createSession(function (err, sessionId){

  if (err){
    response.error("Could not create session for " + sessionId);
    return;
  }


  session.set("sessionID", sessionId);

  //Generate Publisher token
  var publisherToken = opentok.generateToken(sessionId, {"role" : opentok.ROLE.PUBLISHER});
  if (publisherToken){
  } else {
    response.error("could not create publisher token for session " + session.id);
    return;
  }

  //Generate Subscriber Token
  var subscriberToken = opentok.generateToken(sessionId, {"role" : opentok.ROLE.SUBSCRIBER });
  if (subscriberToken){
  } else {
    response.error("Could not create subscriber token for " + session.id);
    return;
  }

  session.set("publisherToken", publisherToken);
  session.set("subscriberToken", subscriberToken);
  response.success();
  });
});

Parse.Cloud.define("getActiveSessionsToken", function (request, response){

  //Retrieve sessions object for token
  var sessionId = request.params.session;
  if (!sessionId) {
    response.error("You must provide a session object id");
  }
 
  var sessionQuery = new Parse.Query("Session");

  sessionQuery.get(sessionId, {

  success: function (session)
  {
    var role = roleForUser(session, request.user);
    var token = opentok.generateToken(session.get("sessionID"), {"role" : role});
    if (token){
      response.success(token);
    } else {
      response.error("Could not generate token for session " + sessionId + " for role: " + role);
    }
  },

  error: function (session, error)
  {
    response.error("cannot find a session with id: " + sessionId + ", error: " + error.description);
  }
  });

});


var roleForUser = function (session, user){
  if (session.get("callerID").id === user.id){
    return opentok.ROLE.PUBLISHER;
  } else {
    return opentok.ROLE.SUBSCRIBER;
  }
};
