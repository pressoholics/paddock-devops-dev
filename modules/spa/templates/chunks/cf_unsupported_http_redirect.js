function unsupportedRedirect(event) {
  var assetPaths = ["_next", "favicons", "assets", "robots.txt", "sitemap.xml"];
  // Get request and request headers
  var request = event.request;
  var userAgent = request.headers["user-agent"].value;
  // Define unsupported conditions
  var isIE =
    userAgent.indexOf("MSIE") >= 0 || userAgent.indexOf("Trident/") >= 0;
  var isUnsupportedUrl = request.uri.startsWith("/unsupported");
  var isUnsupportedBrowser = isIE; // extend this condition if needed
  var isAsset = assetPaths.find((path) => request.uri.startsWith(`/${path}`));
  var response = {
    statusCode: 302,
    statusDescription: "Found",
    headers: {
      location: { value: "" },
    },
  };

  if (!isAsset) {
    if (isUnsupportedBrowser && !isUnsupportedUrl) {
      // Redirect unsupported browsers to `unsupported` page once
      response.headers.location.value = "/unsupported";
      // Return modified response
      return { response };
    } else if (!isUnsupportedBrowser && isUnsupportedUrl) {
      // Redirect a supported browser to `landing` page if it hits `unsupported` page
      response.headers.location.value = "/";
      // Return modified response
      return { response };
    }
  }

  // Continue request processing for the normal flow
  return event;
}
