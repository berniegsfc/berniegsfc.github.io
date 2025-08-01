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
 *   https://sscweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
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
 * Copyright (c) 2018-2025 United States Government as represented by
 * the National Aeronautics and Space Administration. No copyright is
 * claimed in the United States under Title 17, U.S.Code. All Other
 * Rights Reserved.
 *
 */

/**
 * JavaScript example use of 
 * {@link https://sscweb.gsfc.nasa.gov/WebServices/|SSC web services}.
 *
 * @author B. Harris
 * @copyright 2025 United States Government as represented by
 * the National Aeronautics and Space Administration. No copyright is
 * claimed in the United States under Title 17, U.S.Code. All Other
 * Rights Reserved.
 */

/**
 * Note: The code below uses jquery to interact with  the HTML DOM but 
 *     jquery is not required to call the ssc web services (or to
 *     interact with the DOM).
 */

/**
 * Beginning part of URL for the SSC web services.
 */
const sscUrl = window.location.protocol + '//' +
    window.location.hostname + '/WS/sscr/2';
// const sscUrl='https://sscweb.gsfc.nasa.gov/WS/sscr/2';

/**
 * SSC web services XML namespace.
 */
const sscwsNs = "http://sscweb.gsfc.nasa.gov/schema";

/**
 * Regular expression pattern for an ISO 8601 time value.
 */
const timePattern = '(\\d{4})-(\\d{2})-(\\d{2})([T\\s](\\d{2}))?(:(\\d{2}))?(:(\\d{2}))?(\\.(\\d{3}))?Z?';

/**
 * Regular expression for an ISO 8601 time value.
 */
const iso8601RegExp = new RegExp(timePattern);


/**
 * Satellite descriptions sorted by Name, indexed by Id, and with 
 * duplicates (except for different spase resource ids) removed.
 */
let sats = [];

/**
 * Displays the names of the given observatories for the user to select.
 *
 * @param {Object} observatories - SSC observatory descriptions JSON 
 *     object.
 */
function displayObservatories(observatories) {

    // sort in ascending name order
    observatories[1].Observatory[1][1].sort(function(a, b) {
        if (a.Name < b.Name) {
            return -1;
        } else if (a.Name > b.Name) {
            return 1;
        }
        return 0;
    });
    // eliminate duplicates, save resulting descriptions in sats, and
    // append an <option> element to <select> element
    let lastName; // value of last name encountered
    for (let i = 0; i < observatories[1].Observatory[1].length; i++) {

        let observ = observatories[1].Observatory[1][i][1];
        if (lastName != observ.Name) {

            sats[observ.Id] = observ;
            // Remove fractional seconds and timezone from times in
            // title.
            if (observ.Id === 'cluster1' || observ.Id === 'cluster2') {

                $("#satSel").append('<option value="' + observ.Id + 
                    '" title="' + observ.StartTime[1].split('.')[0] + 
                    ' to ' + observ.EndTime[1].split('.')[0] + 
                    '" selected="selected">' + observ.Name + '</option>');
            } else {

                $("#satSel").append('<option value="' + observ.Id + 
                    '" title="' + observ.StartTime[1].split('.')[0] + 
                    ' to ' + observ.EndTime[1].split('.')[0] + '">' + 
                    observ.Name + '</option>');
            }
        }
        lastName = observ.Name;
    }
    document.body.style.cursor = 'default';
}


/**
 * Adds the given data to the dataTable.
 *
 * @param {Object} data - observatory trajectory information.
 */
function addToTable(data) {

    for (let i = 0; i < data.length; i++) {

        for (let j = 0; j < data[i].time.length; j++) {

            if (j == 0) {

                $('#dataTable > tbody').append(
                    '<tr><td colspan="1" rowspan="' + data[i].time.length +
                    '" style="vertical-align: top;">' + data[i].satName +
                    '</td><td>' + data[i].time[j] + '</td><td>' + 
                    data[i].x[j] + '</td><td>' + data[i].y[j] + 
                    '</td><td>' + data[i].z[j] + '</td></td');
            } else {

                $('#dataTable > tbody').append(
                    '<tr><td>' + data[i].time[j] + '</td><td>' + 
                    data[i].x[j] + '</td><td>' + data[i].y[j] + 
                    '</td><td>' + data[i].z[j] + '</td></td');
            }
        }
    }
}


/**
 * Gets an <OutputOptions> xml element.
 *
 */
function getOutputOptions() {

    const outputOptions = 
        document.createElementNS(sscwsNs, "OutputOptions");

    const allLocationFilters = 
        document.createElementNS(sscwsNs, "AllLocationFilters");
    allLocationFilters.textContent = 'true';
    outputOptions.appendChild(allLocationFilters);

    const coordinateOptions1 = 
        document.createElementNS(sscwsNs, "CoordinateOptions");
      const coordinateSystem1 = 
          document.createElementNS(sscwsNs, "CoordinateSystem");
      coordinateSystem1.textContent = 'Gse';
      coordinateOptions1.appendChild(coordinateSystem1);
      const component1 = document.createElementNS(sscwsNs, "Component");
      component1.textContent = 'X';
      coordinateOptions1.appendChild(component1);
    outputOptions.appendChild(coordinateOptions1);
    const coordinateOptions2 = 
        document.createElementNS(sscwsNs, "CoordinateOptions");
      const coordinateSystem2 = 
          document.createElementNS(sscwsNs, "CoordinateSystem");
      coordinateSystem2.textContent = 'Gse';
      coordinateOptions2.appendChild(coordinateSystem2);
      const component2 = document.createElementNS(sscwsNs, "Component");
      component2.textContent = 'Y';
      coordinateOptions2.appendChild(component2);
    outputOptions.appendChild(coordinateOptions2);
    const coordinateOptions3 = 
        document.createElementNS(sscwsNs, "CoordinateOptions");
      const coordinateSystem3 = 
          document.createElementNS(sscwsNs, "CoordinateSystem");
      coordinateSystem3.textContent = 'Gse';
      coordinateOptions3.appendChild(coordinateSystem3);
      const component3 = document.createElementNS(sscwsNs, "Component");
      component3.textContent = 'Z';
      coordinateOptions3.appendChild(component3);
    outputOptions.appendChild(coordinateOptions3);

    const minMaxPoints = document.createElementNS(sscwsNs, "MinMaxPoints");
    minMaxPoints.textContent = '2';
    outputOptions.appendChild(minMaxPoints);

    return outputOptions;
}


/**
 * Earth's radius in km.
 */
const earthRadiusKm = 6378;

/**
 * Displays the trajectory data returned by the web services.
 *
 * @param {Object} result - observatory trajectory information returned
 *     by the web services (XML root element).
 * @see {@link requestData} for request that initiated result.
 */
function displayData(result) {

    $("#requestButton").prop("disabled", false);

    let statusCode = $(result).find('StatusCode').text();

    if (statusCode != 'Success') {

        alert('Request for information from SSC failed.');
        return;
    }

    $('#dataTable > tbody').empty();
    Plotly.purge('plot');

    let data = [];
    $('Data', result).each(function() {

        let satId = $(this).find('Id').text();
        let satName = sats[satId].Name;

        let coordSystem = $(this).find('CoordinateSystem').text();

        let time = $(this).find('Time').map(function() {
            return $(this).text();
        }).get();
        let x = $(this).find('X').map(function() {
            return $(this).text() / earthRadiusKm;
        }).get();
        let y = $(this).find('Y').map(function() {
            return $(this).text() / earthRadiusKm;
        }).get();
        let z = $(this).find('Z').map(function() {
            return $(this).text() / earthRadiusKm;
        }).get();

        data.push({
            satId: satId,
            satName: satName,
            coordSystem: coordSystem,
            time: time,
            x: x,
            y: y,
            z: z
        });
    });

    addToTable(data);

    plot(data);

    document.body.style.cursor = 'default';
}


/**
 * Plots the satellite's trajectory.
 *
 * @param {Object} data - observatory trajectory information.
 */
function plot(data) {

    const colors = d3.scaleOrdinal(d3.schemeCategory10); // default colors

    let trace = [];

    for (let i = 0; i < data.length; i++) {

        let color = colors(i);

        // line trace of trajectory
        trace.push({
            name: data[i].satName,
            x: data[i].x,
            y: data[i].y,
            z: data[i].z,
            text: data[i].time,
            type: 'scatter3d',
            mode: 'lines',
            opacity: 1,
            line: {
                color: color,
                width: 3
            },
            showlegend: true,
        });

        // marker trace for animation (with single first marker)
        trace.push({
            //          name: data[i].satId,
            name: data[i].satName,
            x: [data[i].x[0]],
            y: [data[i].y[0]],
            z: [data[i].z[0]],
            text: data[i].time[0],
            type: 'scatter3d',
            mode: 'markers',
            marker: {
                color: color,
            },
            showlegend: false,
            opacity: 1,
        });
    }

    /*
      trace.push({
          name: 'earth',
          z: ???,
          type: 'surface',
      });
    */

    let frames = [];
    for (let t = 0; t < data[0].time.length; t++) {
        let frameData = [];
        for (let i = 0; i < data.length; i++) {
            frameData.push({}); // no change for line trace
            frameData.push({
                name: data[i].satId,
                id: data[i].time[t],
                text: data[i].time[t],
                x: [data[i].x[t]],
                y: [data[i].y[t]],
                z: [data[i].z[t]],
            });
        }
        frames.push({
            name: data[0].time[t],
            data: frameData,
            type: 'scatter3d',
            mode: 'markers'
        })
    }

    let sliderSteps = [];
    for (let i = 0; i < data[0].time.length; i++) {
        let shortTime = (data[0].time[i].split('T')[1]).split('.')[0];
        // time without date, fractional seconds, and TZ
        sliderSteps.push({
            method: 'animate',
            label: shortTime,
            args: [
                [data[0].time[i]], {
                    mode: 'immediate',
                    transition: {
                        duration: 300
                    },
                    frame: {
                        duration: 300,
                        redraw: false
                    },
                }
            ]
        });
    }

    let layout = {
        title: data[0].coordSystem.toUpperCase() + ' Orbit Plot',
        autosize: false,
        width: 1000,
        height: 700,
        margin: {
            l: 10,
            r: 10,
            t: 50,
            b: 10,
        },
        scene: {
            xaxis: {
                title: 'X (Re)',
                //        autorange: false,
                //        range: [minX, maxX],
            },
            yaxis: {
                title: 'Y (Re)',
                //        autorange: false,
                //        range: [minY, maxY],
            },
            zaxis: {
                title: 'Z (Re)',
                //        autorange: false,
                //        range: [minZ, maxZ],
            },
        },
        /*
            shapes: [
                {
                    type: 'sphere',
                    xref: 'x',
                    yref: 'y',
                    zref: 'z',
                    x: [0,1],
                    y: [0,1],
                    z: [0,1],
                    line: {
                        color: 'rgb(55, 128, 191)',
                        width: 3,
                    },
                },
            ],
        */
        showlegend: true,
        legend: {
            x: 0.8,
            y: 1,
            orientation: 'v',
            bgcolor: '#E2E2E2',
        },
        updatemenus: [{
            x: 0,
            y: 0,
            yanchor: 'top',
            xanchor: 'left',
            showactive: false,
            direction: 'left',
            type: 'buttons',
            pad: {
                t: 87,
                r: 10
            },
            buttons: [{
                method: 'animate',
                args: [null, {
                    mode: 'immediate',
                    fromcurrent: true,
                    transition: {
                        duration: 300
                    },
                    frame: {
                        duration: 500,
                        redraw: true
                    }
                }],
                label: 'Play'
            }, {
                method: 'animate',
                args: [
                    [null], {
                        mode: 'immediate',
                        transition: {
                            duration: 0
                        },
                        frame: {
                            duration: 0,
                            redraw: false
                        }
                    }
                ],
                label: 'Pause'
            }]
        }],
        sliders: [{
            pad: {
                l: 130,
                t: 55
            },
            currentvalue: {
                visible: true,
                prefix: 'Time:',
                xanchor: 'right',
                font: {
                    size: 20,
                    color: '#666'
                }
            },
            steps: sliderSteps
        }]
    }

    Plotly.newPlot('plot', {
        data: trace,
        layout: layout,
        frames: frames
    });

    for (let i = 0; i < time.length; i++) {

        if (i == 0) {

            $('#dataTable > tbody').append(
                '<tr><td colspan="1" rowspan="' + time.length +
                '" style="vertical-align: top;">' + satName + '</td><td>' +
                time[i] + '</td><td>' + x[i] + '</td><td>' +
                y[i] + '</td><td>' + z[i] + '</td></td');
        } else {

            $('#dataTable > tbody').append(
                '<tr><td>' + time[i] + '</td><td>' + x[i] + '</td><td>' +
                y[i] + '</td><td>' + z[i] + '</td></td');
        }
    }

}

/**
 * Gets an ISO 8601 date/time value from the input date/time value.
 *
 * @param {String} value data/time input value.
 * @return {String} ISO 8601 date/time corresponding to given value.
 */
function getIso8601FromInput(value) {

    let components = iso8601RegExp.exec(value);

    for (let i = 0; i < components.length; i++) {

        if (components[i] === undefined) {

            components[i] = '00';
        }
    }

    return components[1] + '-' + components[2] + '-' + components[3] + 'T' +
        components[5] + ':' + components[7] + ':' + components[9] + '.000Z';
}

/**
 * Gets the corresponding JS Date object for the given ISO 8601 date value.
 *
 * @param {String} ISO 8601 date/time value.
 * @return {Date} Date object corresponding to given value.
 */
function getDateFromIso8601(iso8601Date) {
    // Date.parse() does not handle ISO 8601 dates until ECMAScript 5

    let components = iso8601RegExp.exec(iso8601Date);

    for (let i = 0; i < components.length; i++) {

        if (components[i] === undefined) {

            components[i] = 0;
        }
    }

    return new Date(Date.UTC(components[1], components[2] - 1,
        components[3], components[5],
        components[7], components[9],
        components[11]));
}

/**
 * Validates that the given start and end dates are within the range of
 * valid dates for the given satellite.
 *
 * @param {Object} sat - satellite description used to validate the
 *     startDate and endDate.
 * @param {String} startDate - start date to validate.
 * @param {String} endDate - end date to validate.
 * @return {String} an empty string if given dates are within the valid
 *     dates for the satellite.  Otherwise, and error message.
 */
function validTimeRange(sat, startDate, endDate) {

    let satStartDate = getDateFromIso8601(sat.StartTime);
    let satEndDate = getDateFromIso8601(sat.EndTime);

    if (startDate >= satStartDate && endDate <= satEndDate) {

        return '';
    } else {

        return 'Time range outside of data for ' + sat.Name +
            '.\n\nIt must be within ' + sat.StartTime + '\nto ' +
            sat.EndTime + '.';
    }
}

/**
 * Performs final validation and constructs an XML DataRequest from the 
 * user's input.  The XML request is used to make a web service request 
 * to SSC to request the data.  The {@link displayData} function is 
 * registered to handle the results.
 */
async function requestData() {

    // disable rapid, repeated requests
    $("#requestButton").prop("disabled", true);

    let selectedSats = $('#satSel option:selected').map(
        function() {
            return this.value
        }).get();

    if (selectedSats.length == 0) {

        alert('You must select at least one satellite');
        $("#requestButton").prop("disabled", false);
        return;
    }

    // FF 15 is allowing invalid times to get here so we must re-validate 
    let iso8601Start = $('#startTime').val();

    if (!iso8601RegExp.test(iso8601Start)) {

        alert('Invalid Start Time');
        $("#requestButton").prop("disabled", false);
        return;
    }
    // make certain that it is a "full" iso 8601 time value
    iso8601Start = getIso8601FromInput(iso8601Start);

    let iso8601End = $('#stopTime').val();

    if (!iso8601RegExp.test(iso8601End)) {

        alert('Invalid Stop Time');
        $("#requestButton").prop("disabled", false);
        return;
    }
    iso8601End = getIso8601FromInput(iso8601End);

    let startDate = getDateFromIso8601(iso8601Start);
    let endDate = getDateFromIso8601(iso8601End);

    if (startDate >= endDate) {

        alert('Start Time must be less than Stop Time');
        $("#requestButton").prop("disabled", false);
        return;
    }

    const req = 
        document.implementation.createDocument(sscwsNs, "DataRequest");
 
    const timeInterval = document.createElementNS(sscwsNs, "TimeInterval");
    const start = document.createElementNS(sscwsNs, "Start");
    start.textContent = iso8601Start;
    const end = document.createElementNS(sscwsNs, "End");
    end.textContent = iso8601End;
    timeInterval.appendChild(start);
    timeInterval.appendChild(end);
    req.documentElement.appendChild(timeInterval);

    const bFieldModel = document.createElementNS(sscwsNs, "BFieldModel");
    const internalBFieldModel = 
        document.createElementNS(sscwsNs, "InternalBFieldModel");
    internalBFieldModel.textContent = 'IGRF';
    bFieldModel.appendChild(internalBFieldModel);
    const externalBFieldModel = 
        document.createElementNS(sscwsNs, "ExternalBFieldModel");
    externalBFieldModel.setAttribute('xmlns:xsi', 
                            'http://www.w3.org/2001/XMLSchema-instance');
    externalBFieldModel.setAttribute('xsi:type', 
                            'Tsyganenko89cBFieldModel');
    const keyParameterValues = 
        document.createElementNS(sscwsNs, "KeyParameterValues");
    keyParameterValues.textContent = 'KP3_3_3';
    externalBFieldModel.appendChild(keyParameterValues);
    bFieldModel.appendChild(externalBFieldModel);
    const traceStopAltitude = 
        document.createElementNS(sscwsNs, "TraceStopAltitude");
    traceStopAltitude.textContent = '100';
    bFieldModel.appendChild(traceStopAltitude);
    req.documentElement.appendChild(bFieldModel);

    let satReqXml = '';
    for (let i = 0; i < selectedSats.length; i++) {

        let satId = selectedSats[i];
        let sat = sats[satId];

        let invalid = validTimeRange(sat, startDate, endDate);

        if (invalid.length > 0) {

            alert(invalid);
            $("#requestButton").prop("disabled", false);
            return;
        }

        const satellites = document.createElementNS(sscwsNs, "Satellites");
        const id = document.createElementNS(sscwsNs, "Id");
        id.textContent = satId;
        const resolutionFactor = 
            document.createElementNS(sscwsNs, "ResolutionFactor");
        resolutionFactor.textContent = '2';
        satellites.appendChild(id);
        satellites.appendChild(resolutionFactor);
        req.documentElement.appendChild(satellites);
    }

    document.body.style.cursor = 'wait';

    req.documentElement.appendChild(getOutputOptions());

    const serializer = new XMLSerializer();
    const xmlRequest = serializer.serializeToString(req);
  
    let dataRequest = {
        method: 'POST',
        body: xmlRequest,
        headers: new Headers({
            'Content-Type': 'application/xml'
        })
    }

    try {
  
      const response = await fetch(sscUrl + '/locations', dataRequest);
      if (!response.ok) {

        alert(`${sscUrl + '/locations'} HTTP error status = ${response.status}`);
        console.log(xmlRequest)
        return;
      }
      const reply = await response.text();
      const parser = new DOMParser();
      const xmlReply = parser.parseFromString(reply, 'application/xml');
      displayData(xmlReply);
    }
    catch (error) {

      console.error(error.message);
    }
}


/** 
 * Makes an * SSC web service call to get the available observatories.  The
 * displayObservatories function is called to handle the results
 * of web service call.
 */ 
async function getObservatories() {
    
  try {
    
    const response = await fetch(sscUrl + '/observatories', {
                                 headers: new Headers({
                                   'Accept': 'application/json'
                                 })
                               }); 
    if (!response.ok) {
    
      alert(`${sscUrl + '/observatories'} HTTP error status = ${response.status}`); 
      return;             
    }
    const observatories = await response.json();
    displayObservatories(observatories);
  } 
  catch (error) {

    console.error(error.message);
  }
}


/**
 * Called when the browser finished construction the DOM.  It makes an
 * SSC web service call to get the available observatories.  The
 * displayObservatories function is registered to handle the results
 * of web service call.
 */
$(document).ready(function() {
    $('#dataTableVisibility').click(function() {
        $('#data').toggle();
    });
    document.body.style.cursor = 'wait';
    getObservatories();
});
