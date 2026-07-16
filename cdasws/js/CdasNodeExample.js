/*
 * NOSA HEADER START
 *
 * The contents of this file are subject to the terms of the NASA Open
 * Source Agreement (NOSA), Version 1.3 only (the "Agreement").  You may
 * not use this file except in compliance with the Agreement.
 *
 * You can obtain a copy of the agreement at
 *   docs/NASA_Open_Source_Agreement_1.3.txt
 * or
 *   https://cdaweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
 *
 * See the Agreement for the specific language governing permissions
 * and limitations under the Agreement.
 *
 * When distributing Covered Code, include this NOSA HEADER in each
 * file and include the Agreement file at
 * docs/NASA_Open_Source_Agreement_1.3.txt.  If applicable, add the
 * following below this NOSA HEADER, with the fields enclosed by
 * brackets "[]" replaced with your own identifying information:
 * Portions Copyright [yyyy] [name of copyright owner]
 *
 * NOSA HEADER END
 *
 * Copyright (c) 2017-2023 United States Government as represented by
 * the National Aeronautics and Space Administration. No copyright is
 * claimed in the United States under Title 17, U.S.Code. All Other
 * Rights Reserved.
 *
 */

var http = require('https');
const os = require('os');
var path = require('path');
const util = require('util');

var userAgent = path.basename(__filename) + ' (node.js ' +
    process.version + '; ' + os.platform() + '; ' + 
        os.arch() + ')';

var cdfRequest = {
    CdfRequest: {
        TimeInterval: [
            {
                Start: new Date("2014-01-01T00:00:00Z"),
                End: new Date ("2014-01-01T00:10:00Z")
            }
        ],
        DatasetRequest: {
            DatasetId: "AC_H0_MFI",
            VariableName: [
                "Magnitude"
            ]
        },
        CdfFormat: "ICDFML"
    }
};

var data = JSON.stringify(cdfRequest);

var options = {
    host : 'cdaweb.gsfc.nasa.gov',
//    host : 'cdaweb-dev.sci.gsfc.nasa.gov',
    port : 443,
    path : '/WS/cdasr/1/dataviews/sp_phys/datasets/',
    method : 'POST',
    headers : {
      'User-Agent': userAgent,
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'Content-Length': data.length
    },
//    rejectUnauthorized: false
};

function printHeaders(headers, title) {

    console.log(title + " Headers:");
    for (var hdr in headers) {
        console.log("  " + hdr + " = " + headers[hdr]);
    }   
}

var responses = 0;


function handleResponse (res) {
    var msg = '';

    res.setEncoding('utf8');

    res.on('data', (chunk) => {msg += chunk});

    res.on('end', () => {

        if (msg.length > 0) {
            console.log(util.inspect(JSON.parse(msg), 
                                     {depth: null, colors: true} ))
        }

        console.log("statusCode = " + res.statusCode);
        responses++;
        console.log("responses = " + responses);
        var lastModified = res.headers['last-modified'];
        console.log("Last-Modified = " + lastModified);
        options.headers['If-Modified-Since'] = lastModified;
        console.log("msg.length = " + msg.length);
        console.log();
        if (lastModified !== undefined &&
            lastModified.length > 0 &&
            res.statusCode === 200 &&
            responses < 2) {

            printHeaders(options.headers, "Request " + responses);
            var req = http.request(options, handleResponse);
            req.write(data);
            req.end();
        }
    });
    res.on('error', (e) => {
        console.log("Error: " + e.message);
    });
}

printHeaders(options.headers, "Request " + responses);

var req = http.request(options, handleResponse);
req.write(data);
req.end();

