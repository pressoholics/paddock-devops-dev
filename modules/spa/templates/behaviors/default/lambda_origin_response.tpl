'use strict';

${securityHeaders} 

exports.handler = async (event) => {
  const response = securityHeaders(event);
  return response;
}