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
 * Copyright (c) 2017 United States Government as represented by
 * the National Aeronautics and Space Administration. No copyright is
 * claimed in the United States under Title 17, U.S.Code. All Other
 * Rights Reserved.
 *
 */
"use strict";

var cdasUrl = "/WS/cdasr/1/dataviews/sp_phys";


function ajaxFail (jqxhr, textStatus, errorThrown) {

    $('body').css('cursor', 'default');
    alert ('Failed to get ' + jqxhr.responseURL + ' : status = ' +
           textStatus + ', error = ' + errorThrown);
}

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

function Example1() {

    $('#requestButton').on('click', null, makeRequest);

    $('#request').val(JSON.stringify(cdfRequest, null, 2));

    $.get("Example1.js", function(response) {
        $('#code').val(response).scrollTop(500);
    });
}


function makeRequest() {

    $('body').css('cursor', 'wait');

    var jqxhr = $.ajax({
            type: 'POST',
            url: cdasUrl + '/datasets/',
            data: JSON.stringify(cdfRequest),
            dataType: 'json',
            contentType: 'application/json',
            processData: false,
        });

    jqxhr.done(displayResponse);

    jqxhr.fail(ajaxFail);
}


function displayResponse(response) {

    $('body').css('cursor', 'default');

    $('#response').val(JSON.stringify(response, null, 2));
}

