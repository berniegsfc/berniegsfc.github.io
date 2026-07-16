;
; NOSA HEADER START
;
; The contents of this file are subject to the terms of the NASA Open 
; Source Agreement (NOSA), Version 1.3 only (the "Agreement").  You may 
; not use this file except in compliance with the Agreement.
;
; You can obtain a copy of the agreement at
;   docs/NASA_Open_Source_Agreement_1.3.txt
; or 
;   https://cdaweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
;
; See the Agreement for the specific language governing permissions
; and limitations under the Agreement.
;
; When distributing Covered Code, include this NOSA HEADER in each
; file and include the Agreement file at 
; docs/NASA_Open_Source_Agreement_1.3.txt.  If applicable, add the 
; following below this NOSA HEADER, with the fields enclosed by 
; brackets "[]" replaced with your own identifying information: 
; Portions Copyright [yyyy] [name of copyright owner]
;
; NOSA HEADER END
;
; Copyright (c) 2018 United States Government as represented by the 
; National Aeronautics and Space Administration. No copyright is claimed 
; in the United States under Title 17, U.S.Code. All Other Rights Reserved.
;
;


;+
; Gets the HTTP proxy values for the IDLnetURL PROXY_* properties.
; If access to the Internet is through an HTTP proxy, the caller 
; should ensure that the HTTP_PROXY environment is correctly set  
; before this procedure is called.  The HTTP_PROXY value should be of 
; the form http://username:password@hostname:port/.  If the HTTP_PROXY
; environment is not set, the values returned will indicate to
; IDLnetURL not to use a proxy.  See IDLnetURL documentation for more
; details about the values.
;
; @param proxy_authentication {out} {type=int}
;     Type of authentication used when connecting to a proxy server.
; @param proxy_hostname {out} {type=string}
;     The proxy server name.
; @param proxy_port {out} {type=string}
;     The proxy's TCP/IP port.
; @param proxy_username {out} {type=string}
;     Username for authenticating with the proxy server.
; @param proxy_password {out} {type=string}
;     Password for authenticating with the proxy server.
;-
pro SpdfGetHttpProxyValues, $
    proxy_authentication, $
    proxy_hostname, $
    proxy_port, $
    proxy_username, $
    proxy_password
    compile_opt idl2

    proxy_authentication = 0
    proxy_hostname = ''
    proxy_password = ''
    proxy_port = ''
    proxy_username = ''

    http_proxy = getenv('HTTP_PROXY')

    if strlen(http_proxy) gt 0 then begin

        proxyComponents = parse_url(http_proxy)

        proxy_hostname = proxyComponents.hostname
        proxy_password = proxyComponents.password
        proxy_port = proxyComponents.port
        proxy_username = proxyComponents.username

        if strlen(proxy_username) gt 0 then begin

            proxy_authentication = 3
        endif
    endif

end
