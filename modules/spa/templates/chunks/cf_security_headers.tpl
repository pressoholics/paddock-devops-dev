function securityHeaders(event) {
  if (${securityHeadersEnabled}) {
    var response = event.response;
    var headers = response.headers;

    var CSPRules = {
      defaultSrc: ${defaultSrc},
      imgSrc: ${imgSrc},
      styleSrc: ${styleSrc},
      fontSrc: ${fontSrc},
      mediaSrc: ${mediaSrc},
      connectSrc: ${connectSrc},
      scriptSrc: ${scriptSrc}
    };

    var allowXFrame = ${allowXFrame};
    var isReportOnly = ${cspReportOnly}

    //Set new headers
    headers['strict-transport-security'] = {
      value: 'max-age=63072000; includeSubdomains; preload'
    }

    headers['x-content-type-options'] = {
      value: 'nosniff'
    }

    headers['x-frame-options'] = {
      value: allowXFrame ? 'SAMEORIGIN' : 'DENY'
    };

    headers['x-xss-protection'] = {
      value: '1; mode=block'
    };

    headers['referrer-policy'] = {
      value: 'same-origin'
    };

    headers[isReportOnly ? 'content-security-policy-report-only' : 'content-security-policy'] = {
      value: `
        default-src
            'self'
            $${CSPRules.defaultSrc.join(' ')};
        manifest-src
            'self'; 
        base-uri
            'self'; 
        form-action
            'self'; 
        font-src
            'self'
            data:
            'unsafe-inline'
            $${CSPRules.fontSrc.join(' ')}; 
        frame-ancestors
            'self'; 
        object-src
            'none';
        media-src
            'self'
            $${CSPRules.mediaSrc.join(' ')};
        img-src
            'self'
            blob:
            data:
            $${CSPRules.imgSrc.join(' ')};
        connect-src
            'self'
            $${CSPRules.connectSrc.join(' ')};
        prefetch-src
            'self';
        script-src
            'self'
            'unsafe-eval'
            'unsafe-inline'
            $${CSPRules.scriptSrc.join(' ')};
        style-src-elem
            'self'
            blob:
            data:
            'unsafe-inline'
            $${CSPRules.styleSrc.join(' ')};
        style-src
            'self'
            blob:
            data:
            'unsafe-inline'
            $${CSPRules.styleSrc.join(' ')};`
        .replace(/\n\s*|\n/gm, ' ')
        .trim()
    };

    headers['feature-policy'] = {
      value: `
        sync-xhr
            'none';
        geolocation
            'none';
        midi
            'none';
        payment
            'none';
        camera
            'none';
        usb
            'none';
        fullscreen
            'none';
        magnetometer
            'none';
        picture-in-picture
            'none';
        accelerometer
            'none';
        autoplay
            'none';
        document-domain
            'none';
        encrypted-media
            'none';
        gyroscope
            'none';
        xr-spatial-tracking
            'none';
        microphone
            'none';`
        .replace(/\n\s*|\n/gm, ' ')
        .trim()
    };
    event.response = response;

    //Return modified response
    return event;
  }
}


