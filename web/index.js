var FingerprintJSFlutter=function(e){"use strict";var t=function(){return t=Object.assign||function(e){for(var t,r=1,n=arguments.length;r<n;r++)for(var R in t=arguments[r])Object.prototype.hasOwnProperty.call(t,R)&&(e[R]=t[R]);return e},t.apply(this,arguments)};"function"==typeof SuppressedError&&SuppressedError;var r={default:"endpoint"},n={default:"tlsEndpoint"},R="Client timeout",o="Network connection error",i="Network request aborted",E="Response cannot be parsed",a="Blocked by CSP",u="The endpoint parameter is not a valid URL";function _(e){for(var t="",r=0;r<e.length;++r)if(r>0){var n=e[r].toLowerCase();n!==e[r]?t+=" ".concat(n):t+=e[r]}else t+=e[r].toUpperCase();return t}var O=_("WrongRegion"),c=_("SubscriptionNotActive"),l=_("UnsupportedVersion"),s=_("InstallationMethodRestricted"),I=_("HostnameRestricted"),f=_("IntegrationFailed"),d=_("NetworkRestricted"),p=_("InvalidProxyIntegrationSecret"),N=_("InvalidProxyIntegrationHeaders"),T="API key required",v="API key not found",A="API key expired",h="Request cannot be parsed",S="Request failed",D="Request failed to process",P="Too many requests, rate limit exceeded",y="Not available for this origin",w="Not available with restricted header",m=T,L=v,g=A,C="Failed to load the JS script of the agent",U="9319";function b(e,t){var r,n,R,o,i,E=[],_=(r=function(e){var t=function(e,t,r){if(r||2===arguments.length)for(var n,R=0,o=t.length;R<o;R++)!n&&R in t||(n||(n=Array.prototype.slice.call(t,0,R)),n[R]=t[R]);return e.concat(n||Array.prototype.slice.call(t))}([],e,!0);return{current:function(){return t[0]},postpone:function(){var e=t.shift();void 0!==e&&t.push(e)},exclude:function(){t.shift()}}}(e),100,3e3,o=0,n=function(){return Math.random()*Math.min(3e3,100*Math.pow(2,o++))},R=new Set,[r.current(),function(e,t){var o,i=t instanceof Error?t.message:"";if(i===a||i===u)r.exclude(),o=0;else if(i===U)r.exclude();else if(i===C){var E=Date.now()-e.getTime()<50,_=r.current();_&&E&&!R.has(_)&&(R.add(_),o=0),r.postpone()}else r.postpone();var O=r.current();return void 0===O?void 0:[O,null!=o?o:e.getTime()+n()-Date.now()]}]),O=_[0],c=_[1];if(void 0===O)return Promise.reject(new TypeError("The list of script URL patterns is empty"));var l=function(e){var r=new Date,n=function(t){return E.push({url:e,startedAt:r,finishedAt:new Date,error:t})},R=t(e);return R.then((function(){return n()}),n),R.catch((function(e){if(null!=i||(i=e),E.length>=5)throw i;var t=c(r,e);if(!t)throw i;var n,R=t[0],o=t[1];return(n=o,new Promise((function(e){return setTimeout(e,n)}))).then((function(){return l(R)}))}))};return l(O).then((function(e){return[e,E]}))}var K="https://fpnpmcdn.net/v<version>/<apiKey>/loader_v<loaderVersion>.js",M=K;function F(e){var r;e.scriptUrlPattern;var n=e.token,R=e.apiKey,o=void 0===R?n:R,i=function(e,t){var r={};for(var n in e)Object.prototype.hasOwnProperty.call(e,n)&&t.indexOf(n)<0&&(r[n]=e[n]);if(null!=e&&"function"==typeof Object.getOwnPropertySymbols){var R=0;for(n=Object.getOwnPropertySymbols(e);R<n.length;R++)t.indexOf(n[R])<0&&Object.prototype.propertyIsEnumerable.call(e,n[R])&&(r[n[R]]=e[n[R]])}return r}(e,["scriptUrlPattern","token","apiKey"]),E=null!==(r=function(e,t){return function(e,t){return Object.prototype.hasOwnProperty.call(e,t)}(e,t)?e[t]:void 0}(e,"scriptUrlPattern"))&&void 0!==r?r:K,a=function(){var e=[],t=function(){e.push({time:new Date,state:document.visibilityState})},r=function(e,t,r,n){return e.addEventListener(t,r,n),function(){return e.removeEventListener(t,r,n)}}(document,"visibilitychange",t);return t(),[e,r]}(),u=a[0],_=a[1];return Promise.resolve().then((function(){if(!o||"string"!=typeof o)throw new Error(T);return b(function(e,t){return(Array.isArray(e)?e:[e]).map((function(e){return function(e,t){var r=encodeURIComponent;return e.replace(/<[^<>]+>/g,(function(e){return"<version>"===e?"3":"<apiKey>"===e?r(t):"<loaderVersion>"===e?r("3.11.8"):e}))}(String(e),t)}))}(E,o),V)})).catch((function(e){throw _(),function(e){return e instanceof Error&&e.message===U?new Error(C):e}(e)})).then((function(e){var r=e[0],n=e[1];return _(),r.load(t(t({},i),{ldi:{attempts:n,visibilityStates:u}}))}))}function V(e){return function(e,t,r,n){var R,o=document,i="securitypolicyviolation",E=function(t){var r=new URL(e,location.href),n=t.blockedURI;n!==r.href&&n!==r.protocol.slice(0,-1)&&n!==r.origin||(R=t,a())};o.addEventListener(i,E);var a=function(){return o.removeEventListener(i,E)};return null==n||n.then(a,a),Promise.resolve().then(t).then((function(e){return a(),e}),(function(e){return new Promise((function(e){var t=new MessageChannel;t.port1.onmessage=function(){return e()},t.port2.postMessage(null)})).then((function(){if(a(),R)return r(R);throw e}))}))}(e,(function(){return function(e){return new Promise((function(t,r){if(function(e){if(URL.prototype)try{return new URL(e,location.href),!1}catch(t){if(t instanceof Error&&"TypeError"===t.name)return!0;throw t}}(e))throw new Error(u);var n=document.createElement("script"),R=function(){var e;return null===(e=n.parentNode)||void 0===e?void 0:e.removeChild(n)},o=document.head||document.getElementsByTagName("head")[0];n.onload=function(){R(),t()},n.onerror=function(){R(),r(new Error(C))},n.async=!0,n.src=e,o.appendChild(n)}))}(e)}),(function(){throw new Error(a)})).then(B)}function B(){var e=window,t="__fpjs_p_l_b",r=e[t];if(function(e,t){var r,n=null===(r=Object.getOwnPropertyDescriptor)||void 0===r?void 0:r.call(Object,e,t);(null==n?void 0:n.configurable)?delete e[t]:n&&!n.writable||(e[t]=void 0)}(e,t),"function"!=typeof(null==r?void 0:r.load))throw new Error(U);return r}var G={load:F,defaultScriptUrlPattern:M,ERROR_SCRIPT_LOAD_FAIL:C,ERROR_API_KEY_EXPIRED:A,ERROR_API_KEY_INVALID:v,ERROR_API_KEY_MISSING:T,ERROR_BAD_REQUEST_FORMAT:h,ERROR_BAD_RESPONSE_FORMAT:E,ERROR_CLIENT_TIMEOUT:R,ERROR_CSP_BLOCK:a,ERROR_FORBIDDEN_ENDPOINT:I,ERROR_FORBIDDEN_HEADER:w,ERROR_FORBIDDEN_ORIGIN:y,ERROR_GENERAL_SERVER_FAILURE:S,ERROR_INSTALLATION_METHOD_RESTRICTED:s,ERROR_INTEGRATION_FAILURE:f,ERROR_INVALID_ENDPOINT:u,ERROR_INVALID_PROXY_INTEGRATION_HEADERS:N,ERROR_INVALID_PROXY_INTEGRATION_SECRET:p,ERROR_NETWORK_ABORT:i,ERROR_NETWORK_CONNECTION:o,ERROR_NETWORK_RESTRICTED:d,ERROR_RATE_LIMIT:P,ERROR_SERVER_TIMEOUT:D,ERROR_SUBSCRIPTION_NOT_ACTIVE:c,ERROR_TOKEN_EXPIRED:g,ERROR_TOKEN_INVALID:L,ERROR_TOKEN_MISSING:m,ERROR_UNSUPPORTED_VERSION:l,ERROR_WRONG_REGION:O,defaultEndpoint:r,defaultTlsEndpoint:n},j=Object.freeze({__proto__:null,ERROR_API_KEY_EXPIRED:A,ERROR_API_KEY_INVALID:v,ERROR_API_KEY_MISSING:T,ERROR_BAD_REQUEST_FORMAT:h,ERROR_BAD_RESPONSE_FORMAT:E,ERROR_CLIENT_TIMEOUT:R,ERROR_CSP_BLOCK:a,ERROR_FORBIDDEN_ENDPOINT:I,ERROR_FORBIDDEN_HEADER:w,ERROR_FORBIDDEN_ORIGIN:y,ERROR_GENERAL_SERVER_FAILURE:S,ERROR_INSTALLATION_METHOD_RESTRICTED:s,ERROR_INTEGRATION_FAILURE:f,ERROR_INVALID_ENDPOINT:u,ERROR_INVALID_PROXY_INTEGRATION_HEADERS:N,ERROR_INVALID_PROXY_INTEGRATION_SECRET:p,ERROR_NETWORK_ABORT:i,ERROR_NETWORK_CONNECTION:o,ERROR_NETWORK_RESTRICTED:d,ERROR_RATE_LIMIT:P,ERROR_SCRIPT_LOAD_FAIL:C,ERROR_SERVER_TIMEOUT:D,ERROR_SUBSCRIPTION_NOT_ACTIVE:c,ERROR_TOKEN_EXPIRED:g,ERROR_TOKEN_INVALID:L,ERROR_TOKEN_MISSING:m,ERROR_UNSUPPORTED_VERSION:l,ERROR_WRONG_REGION:O,default:G,defaultEndpoint:r,defaultScriptUrlPattern:M,defaultTlsEndpoint:n,load:F});return e.FingerprintJS=j,e}({});
