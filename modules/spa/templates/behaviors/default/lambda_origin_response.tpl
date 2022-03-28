'use strict';

${securityHeaders} 

exports.handler = async (event, context, callback) => {
  const response = securityHeaders(event);
  callback(null, response);
}