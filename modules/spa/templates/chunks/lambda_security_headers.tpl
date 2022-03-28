const securityHeaders = (event) => {
  const response = event.Records[0].cf.response;
  const request = event.Records[0].cf.request;
  const headers = response.headers;
  const CSPRules = {
    defaultSrc: ${defaultSrc},
    imgSrc: ${imgSrc},
    styleSrc: ${styleSrc},
    fontSrc: ${fontSrc},
    mediaSrc: ${mediaSrc},
    connectSrc: ${connectSrc},
    scriptSrc: ${scriptSrc}
  };

  const allowXFrame = ${allowXFrame};
  const isReportOnly = ${cspReportOnly}

  //Set new headers
  headers['strict-transport-security'] = [
    {
      key: 'Strict-Transport-Security',
      value: 'max-age=63072000; includeSubdomains; preload'
    }
  ];

  headers['x-content-type-options'] = [
    {
      key: 'X-Content-Type-Options',
      value: 'nosniff'
    }
  ];

  headers['x-frame-options'] = [
    {
      key: 'X-Frame-Options',
      value: allowXFrame ? 'SAMEORIGIN' : 'DENY'
    }
  ];

  headers['x-xss-protection'] = [
    {
      key: 'X-XSS-Protection',
      value: '1; mode=block'
    }
  ];

  headers['referrer-policy'] = [
    {
      key: 'Referrer-Policy',
      value: 'same-origin'
    }
  ];

  headers[isReportOnly ? 'content-security-policy-report-only' : 'content-security-policy'] = [
    {
      key: isReportOnly ? 'Content-Security-Policy-Report-Only' : 'Content-Security-Policy',
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
            www.google-analytics.com
            $${CSPRules.connectSrc.join(' ')};
        prefetch-src
            'self';
        script-src
            'self'
            'unsafe-eval'
            'unsafe-inline'
            www.googletagmanager.com
            www.google-analytics.com
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
    }
  ];

  headers['feature-policy'] = [
    {
      key: 'Feature-Policy',
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
    }
  ];

  //Return modified response
  return response;
};