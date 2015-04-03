var opentok = require('cloud/opentok/opentok.js').createOpenTokSDK('45135932', '09184b366376c3d70f1d2ebfd84f384ec292f020');

// Example function that creates a session
Parse.Cloud.define("opentokNewSession", function(request, response) {
  // The first parameter is an optional set of properties,
  // similar to http://www.tokbox.com/opentok/api/tools/documentation/api/server_side_libraries.html#create_session
  opentok.createSession(request.params, function(err, sessionId) {
    if (err) return response.error(err.message);
    response.success(sessionId);
    return;
  });
});

// Example function that generates a token
Parse.Cloud.define("opentokGenerateToken", function(request, response) {
  // The second parameter is an optional set of properties
  // similar to http://www.tokbox.com/opentok/api/tools/documentation/api/server_side_libraries.html#generate_token
  var token = opentok.generateToken(request.params.sessionId || '', request.params.options);
  if (token) return response.success(token);
  return response.error("You must specify a sessionId to generate a token");
});
