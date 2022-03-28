${basicAuth}
${unsupported} 

function handler(event) {
  event = basicAuth(event);
  if (event.response) {
    return event.response;
  }

  event = unsupportedRedirect(event);
  if (event.response) {
    return event.response;
  }

  return event.request;
}