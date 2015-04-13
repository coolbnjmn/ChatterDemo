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

var opentok = require("cloud/opentok/opentok.js").createOpenTokSDK("45198012", "4f7be1cc176b0f6a151aa33c329b1a8bdf96acbc");

var Session = Parse.Object.extend("Session");

var twilio = require('twilio')('ACcc39af43df9296cbcfb3826b99274678', '205db33bd7f9f9405d91f919d7e35a95')

var Stripe = require('stripe');
Stripe.initialize('sk_test_ukk7e8B46I39nxoUd6XILpPZ');


Parse.Cloud.define("saveCardInformation", function(request, response) {

    Stripe.Customers.create({
      source: request.params.cardToken,
    },{
      success: function(httpResponse) {
        response.success("Customer created!");
        console.log(httpResponse);
      },
      error: function(httpResponse) {
        response.error(httpResponse.message);
      }
    });

});

var createStripeCustomer = function(request, response) {
  var StripeCustomer = Parse.Object.extend("StripeCustomer");

}

Parse.Cloud.define("addPaymentSource", function(request, response) {
    console.log(request.params);
    var userObjectId = request.params.userObjectId;
    var StripeCustomer = Parse.Object.extend("StripeCustomer");
    var stripeCustomerQuery = new Parse.Query(StripeCustomer);

    stripeCustomerQuery.equalTo("userObj", userObjectId);
    stripeCustomerQuery.find({
      success: function(results) {
        if(results.length == 0) {
          var stripeCustomer = new StripeCustomer();
          stripeCustomer.set("tokenId", request.params.token);
          stripeCustomer.set("userObj",request.params.userObjectId);

          var newStripeCustomer = {};
          newStripeCustomer.source = request.params.token;
          newStripeCustomer.email = Parse.User.current().get("email");
          newStripeCustomer.description = request.params.userObjectId;
          console.log(newStripeCustomer);
          Stripe.Customers.create(newStripeCustomer, {
                success: function(httpResponse) {
                  console.log(httpResponse);
                  stripeCustomer.set("stripeCustomerId", httpResponse.id);
                  stripeCustomer.save(null,{
                    success: function(customer) {
                      console.log(customer.id)
                      response.success("created new customer");
                    }, error : function(customer, error) {
                      console.log(error);
                      response.error(error);
                    } 
                  });
                },
                error: function(httpResponse) {
                  console.log("error");
                  response.error(httpResponse.message);
                } 
            }
          );        
        } else if(results.length == 1) {
          // handle returning customer adding a new card
          var stripeCustomerFromQuery = results[0];
          var customerId = stripeCustomerFromQuery.get("stripeCustomerId");
          Stripe.Customers.retrieve(
            customerId, {
              success: function(customer) {
                // add the card to this customer
                Stripe.Customers.update(
                  customerId, 
                  {source:request.params.token}, {
                    success: function(card) {
                      console.log(card);
                      response.success("Added card to existing Customer");
                    }, error: function(card, error) {
                      response.error(error);
                    }
                  }
                );
              }, error: function(customer, error) {
                console.log(error);
                response.error(error);
              }
            
          });
        } else {
          response.error("Had too many customer IDs");
        }
      }, error: function(error) {
          reponse.error(error);          
      }
    });

   

});

Parse.Cloud.define("sendVerificationCode", function(request, response) {
    var verificationCode = Math.floor(Math.random()*999999);
    var user = Parse.User.current();
    user.set("phoneVerificationCode", verificationCode);
    user.save();
    
    twilio.sendSms({
        From: "(650) 666-0785",
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
