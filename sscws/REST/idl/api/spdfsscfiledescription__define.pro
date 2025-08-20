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
;   https://sscweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
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
; Copyright (c) 2014-2024 United States Government as represented by the 
; National Aeronautics and Space Administration. No copyright is claimed 
; in the United States under Title 17, U.S.Code. All Other Rights Reserved.
;
;



;+
; This class is an IDL representation of the FileDescription
; element from the
; <a href="https://sscweb.gsfc.nasa.gov/">File Situation Center</a>
; (SSC) XML schema.
;
; @copyright Copyright (c) 2014-2024 United States Government as 
;     represented by the National Aeronautics and Space Administration.
;     No copyright is claimed in the United States under Title 17,
;     U.S.Code. All Other Rights Reserved.
;
; @author B. Harris
;-


;+
; Creates an SpdfSscFileDescription object.
;
; If access to the Internet is through an HTTP proxy, the caller
; should ensure that the HTTP_PROXY environment is correctly set
; before this method is called.  The HTTP_PROXY value should be of
; the form
; http://username:password@hostname:port/.
;
; @param name {in} {type=string}
;            file name.
; @param mimeType {in} {type=string}
;            file's MIME type.
; @param length {in} {type=int}
;            file's size in bytes.
; @param lastModified {in} {type=julday}
;            time of last modification to file.
; @returns reference to an SpdfSscFileDescription object.
;-
function SpdfSscFileDescription::init, $
    name, mimeType, length, lastModified
    compile_opt idl2

    self.name = name
    self.mimeType = mimeType
    self.length = length
    self.lastModified = lastModified

    http_proxy = getenv('HTTP_PROXY')

    if strlen(http_proxy) gt 0 then begin

        proxyComponents = parse_url(http_proxy)

        self.proxy_hostname = proxyComponents.host
        self.proxy_password = proxyComponents.password
        self.proxy_port = proxyComponents.port
        self.proxy_username = proxyComponents.username

        if strlen(self.proxy_username) gt 0 then begin

            self.proxy_authentication = 3
        endif
    endif

    return, self
end


;+
; Performs cleanup operations when this object is destroyed.
;-
pro SpdfSscFileDescription::cleanup
    compile_opt idl2

end


;+
; Gets the name of the file.
;
; @returns name of the file.
;-
function SpdfSscFileDescription::getName
    compile_opt idl2

    return, self.name
end


;+
; Gets the MIME type of the file.
;
; @returns MIME type of the file.
;-
function SpdfSscFileDescription::getMimeType
    compile_opt idl2

    return, self.mimeType
end


;+
; Gets the length of the file.
;
; @returns length of the file.
;-
function SpdfSscFileDescription::getLength
    compile_opt idl2

    return, self.length
end


;+
; Gets the last modified time.
;
; @returns last modified time.
;-
function SpdfSscFileDescription::getLastModified
    compile_opt idl2

    return, self.lastModified
end


;+
; Prints a textual representation of this object.
;-
pro SpdfSscFileDescription::print
    compile_opt idl2

    print, '  ', self.name, ': ', self.mimeType
end


;+
; Retrieves this file from a remote HTTP or FTP server and writes
; it to disk, a memory buffer, or an array of strings. The returned
; data is written to disk in the location specified by the FILENAME
; keyword. If the filename is not specified, the local name will be
; the same as this file's name in the current working directory.
;
; @keyword buffer {in} {optional} {type=boolean} {default=false}
;            if this keyword is set, the return value is a buffer
;            and the FILENAME keyword is ignored.
; @keyword filename {in} {optional} {type=string}
;            set this keyword equal to a string that holds the file
;            name and path where the retrieved file is locally stored.
;            If FILENAME specifies a full path, the file is stored in
;            the specified path.  If FILENAME specifies a relative
;            path, the path is relative to IDL's current working
;            directory.  If FILENAME is not present the file is
;            stored in the current working directory under the name
;            the basename of filename.  If FILENAME is the same
;            between calls, the last file received is overwritten.
; @keyword string_array {in} {optional} {type=boolean} {default=false}
;            set this keyword to treat the return value as an array
;            of strings. If this keyword is set, the FILENAME and
;            BUFFER keywords are ignored.
; @keyword callback_function {in} {optional} {type=string}
;            this keyword value is the name of the IDL function that
;            is to be called during this retrieval operation.  The
;            callbacks provide feedback to the user about the ongoing
;            operation, as well as provide a method to cancel an
;            ongoing operation. If this keyword is not set, no
;            callback to the caller is made.  For information on
;            creating a callback function, see "Using Callbacks with
;            the IDLnetURL Object" in the IDL documentation.
; @keyword callback_data {in} {optional} {type=reference}
;            this keyword value contains data that is passed to the
;            caller when a callback is made. The data contained in
;            this variable is defined and set by the caller. The
;            variable is passed, unmodified, directly to the caller
;            as a parameter in the callback function. If this keyword
;            is not set, the corresponding callback parameter's value
;            is undefined.
; @keyword sslVerifyPeer {in} {optional} {type=int} {default=1}
;            Specifies whether the authenticity of the peer's SSL
;            certificate should be verified.  When 0, the connection
;            succeeds regardless of what the peer SSL certificate
;            contains.
; @returns one of the following: A string containing the full path
;            of the file retrieved from the remote HTTP or FTP server,
;            A byte vector, if the BUFFER keyword is set, An array of
;            strings, if the STRING_ARRAY keyword is set, A null
;            string, if no data were returned by the method.
;-
function SpdfSscFileDescription::getFile, $
    buffer = buffer, filename = filename, $
    string_array = string_array, $
    callback_function = callback_function, $
    callback_data = callback_data, $
    sslVerifyPeer = sslVerifyPeer
    compile_opt idl2

    if n_elements(filename) eq 0 then begin

        urlComponents = parse_url(self.name)
        filename = file_basename(urlComponents.path)
    endif

    if n_elements(sslVerifyPeer) eq 0 then begin

        sslVerifyPeer = 1
    endif

    fileUrl = $
        obj_new('IDLnetUrl', $
                proxy_authentication = self.proxy_authentication, $
                proxy_hostname = self.proxy_hostname, $
                proxy_port = self.proxy_port, $
                proxy_username = self.proxy_username, $
                proxy_password = self.proxy_password, $
                ssl_verify_peer = sslVerifyPeer)

    if keyword_set(callback_function) then begin

        fileUrl -> setProperty, callback_function = callback_function
    endif

    if keyword_set(callback_data) then begin

        fileUrl -> setProperty, callback_data = callback_data
    endif

    result = fileUrl->get(buffer = buffer, filename = filename, $
                 string_array = string_array, url = self.name)

    obj_destroy, fileUrl

    return, result
end


;+
; Defines the SpdfSscFileDescription class.
;
; @field name file name.
; @field mimeType file's MIME type.
; @field length file size in bytes.
; @field lastModified julday of the last time the file was modified.
; @field proxy_authentication IDLnetURL PROXY_AUTHENTICATION property
;            value.
; @field proxy_hostname IDLnetURL PROXY_HOSTNAME property value.
; @field proxy_password IDLnetURL PROXY_PASSWORD property value.
; @field proxy_port IDLnetURL PROXY_PORT property value.
; @field proxy_username IDLnetURL PROXY_USERNAME property value.
;-
pro SpdfSscFileDescription__define
    compile_opt idl2
    struct = { SpdfSscFileDescription, $
        name:'', $
        mimetype:'', $
        length:0LL, $
        lastModified:0D, $
        proxy_authentication:0, $
        proxy_hostname:'', $
        proxy_password:'', $
        proxy_port:'', $
        proxy_username:'' $
    }
end
