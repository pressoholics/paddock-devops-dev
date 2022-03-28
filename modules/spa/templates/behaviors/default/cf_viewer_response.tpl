${securityHeaders} 

function handler(event) {
  event = securityHeaders(event);
  return event.response;
}
