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
 * Copyright (c) 2012-2025 United States Government as represented by
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
 * @copyright 2012-2025 United States Government as represented by
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
/*
const sscUrl=window.location.protocol + '//' +
           window.location.hostname + '/WS/sscr/2';
                                       // beginning part of URL for the
                                       // SSC web services
*/
const sscUrl='https://sscweb.gsfc.nasa.gov/WS/sscr/2';

/**
 * Regular expression pattern for an ISO 8601 time value.
 */
const timePattern='(\\d{4})-(\\d{2})-(\\d{2})([T\\s](\\d{2}))?(:(\\d{2}))?(:(\\d{2}))?(\\.(\\d{3}))?Z?';

/**
 * Regular expression for an ISO 8601 time value.
 */
const iso8601RegExp=new RegExp(timePattern);

/**
 * Satellite descriptions sorted by Name, indexed by Id, and with
 * duplicates (except for different spase resource ids) removed.
 */
let sats = new Object;

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
    }
    else if (a.Name > b.Name) {
      return 1;
    }
    return 0;
  });
  // eliminate duplicates, save resulting descriptions in sats, and
  // append an <option> element to <select> element
  let lastName;                        // value of last name encountered
  for (let i = 0; i < observatories[1].Observatory[1].length; i++) {

    observ = observatories[1].Observatory[1][i][1];
    if (lastName != observ.Name) {
      sats[observ.Id] = observ;
      if (observ.Id == 'themisa' || observ.Id == 'themisb') {

        $("#satSel").append('<option value="' + observ.Id + '" title="' +
                            observ.StartTime[1] + ' to ' + 
                            observ.EndTime[1] +
                            '" selected="selected">' + observ.Name +
                            '</option>');
      }
      else {

        $("#satSel").append('<option value="' + observ.Id + '" title="' +
                            observ.StartTime[1] + ' to ' + 
                            observ.EndTime[1] +
                            '">' + observ.Name + '</option>');
      }
    }
    lastName = observ.Name;
  }
}

/**
 * SSC web services XML namespace.
 */
const sscwsNs = "http://sscweb.gsfc.nasa.gov/schema";

/**
 * Gets a Mapped <GraphOptions> xml element.
 *
 * @param {Object} graphOptions - the GraphOptions XML DOM fragment to
 *     add the required Mapped options to.
 */
function getOrbitGraphOptions(graphOptions) {

    graphOptions.setAttribute('xmlns:xsi',
                          'http://www.w3.org/2001/XMLSchema-instance');
    graphOptions.setAttribute('xsi:type', 'OrbitGraphOptions');
    const coordinateSystem = document.createElementNS(sscwsNs, "CoordinateSystem");
    coordinateSystem.textContent = 'Gse';
    graphOptions.appendChild(coordinateSystem);
    const combined = document.createElementNS(sscwsNs, "Combined");
    combined.textContent = 'true';
    graphOptions.appendChild(combined);
    const xyView = document.createElementNS(sscwsNs, "XyView");
    xyView.textContent = 'true';
    graphOptions.appendChild(xyView);
    const xzView = document.createElementNS(sscwsNs, "XzView");
    xzView.textContent = 'true';
    graphOptions.appendChild(xzView);
    const yzView = document.createElementNS(sscwsNs, "YzView");
    yzView.textContent = 'true';
    graphOptions.appendChild(yzView);
    const xrView = document.createElementNS(sscwsNs, "XrView");
    xrView.textContent = 'true';
    graphOptions.appendChild(xrView);
    const sunToRight = document.createElementNS(sscwsNs, "SunToRight");
    sunToRight.textContent = 'false';
    graphOptions.appendChild(sunToRight);
    const evenAxisScale = document.createElementNS(sscwsNs, "EvenAxesScale");
    evenAxisScale.textContent = 'false';
    graphOptions.appendChild(evenAxisScale);
    const showBowShockMagnetopause = document.createElementNS(sscwsNs, "ShowBowShockMagnetopause");
    showBowShockMagnetopause.textContent = 'true';
    graphOptions.appendChild(showBowShockMagnetopause);
    const solarWindPressure = document.createElementNS(sscwsNs, "SolarWindPressure");
    solarWindPressure.textContent = '2.1';
    graphOptions.appendChild(solarWindPressure);
    const imfBz = document.createElementNS(sscwsNs, "ImfBz");
    imfBz.textContent = '0.0';
    graphOptions.appendChild(imfBz);
    return graphOptions;
}

/**
 * Gets a MapProjection <GraphOptions> xml element.
 *
 * @param {Object} graphOptions - the GraphOptions XML DOM fragment to
 *     add the required MapProjection options to.
 */
function getMappedGraphOptions(graphOptions) {

    graphOptions.setAttribute('xmlns:xsi',
                          'http://www.w3.org/2001/XMLSchema-instance');
    graphOptions.setAttribute('xsi:type', 'MapProjectionGraphOptions');
    const trace = document.createElementNS(sscwsNs, "Trace");
    trace.textContent = 'BFieldNorth';
    graphOptions.appendChild(trace);
    const coordinateSystem = document.createElementNS(sscwsNs, "CoordinateSystem");
    coordinateSystem.textContent = 'Geo';
    graphOptions.appendChild(coordinateSystem);
    const showContinents = document.createElementNS(sscwsNs, "ShowContinents");
    showContinents.textContent = 'true';
    graphOptions.appendChild(showContinents);
    const projection = document.createElementNS(sscwsNs, "Projection");
    projection.textContent = 'Cylindrical';
    graphOptions.appendChild(projection);
    const gs1 = document.createElementNS(sscwsNs, "GroundStations");
    gs1.textContent = 'FSMI';
    graphOptions.appendChild(gs1);
    const gs2 = document.createElementNS(sscwsNs, "GroundStations");
    gs2.textContent = 'WHOR';
    graphOptions.appendChild(gs2);
    const gs3 = document.createElementNS(sscwsNs, "GroundStations");
    gs3.textContent = 'FSIM';
    graphOptions.appendChild(gs3);
    const gs4 = document.createElementNS(sscwsNs, "GroundStations");
    gs4.textContent = 'GAK';
    graphOptions.appendChild(gs4);
    const mapLimits = document.createElementNS(sscwsNs, "MapLimits");
      const minLatitude = document.createElementNS(sscwsNs, "MinLatitude");
      minLatitude.textContent = '-90.0';
      mapLimits.appendChild(minLatitude);
      const maxLatitude = document.createElementNS(sscwsNs, "MaxLatitude");
      maxLatitude.textContent = '90.0';
      mapLimits.appendChild(maxLatitude);
      const maxLongitude = document.createElementNS(sscwsNs, "MaxLongitude");
      maxLongitude.textContent = '-180.0';
      mapLimits.appendChild(maxLongitude);
      const minLongitude = document.createElementNS(sscwsNs, "MinLongitude");
      minLongitude.textContent = '-180.0';
      mapLimits.appendChild(minLongitude);
    graphOptions.appendChild(mapLimits);
    const polarMapOrientation = document.createElementNS(sscwsNs, "PolarMapOrientation");
    polarMapOrientation.textContent = 'Equatorial';
    graphOptions.appendChild(polarMapOrientation);
    const longitudeVerticalDown = document.createElementNS(sscwsNs, "LongitudeVerticalDown");
    longitudeVerticalDown.textContent = '0.0';
    graphOptions.appendChild(longitudeVerticalDown);
    const title = document.createElementNS(sscwsNs, "Title");
    title.textContent = 'Mapped Plot Test';
    graphOptions.appendChild(title);

    return graphOptions;
}

/**
 * Gets a TimeSeries <GraphOptions> xml element.
 *
 * @param {Object} graphOptions - the GraphOptions XML DOM fragment to
 *     add the required TimeSeries options to.
 */
function getTimeSeriesGraphOptions(graphOptions) {

    graphOptions.setAttribute('xmlns:xsi',
                          'http://www.w3.org/2001/XMLSchema-instance');
    graphOptions.setAttribute('xsi:type', 'TimeSeriesGraphOptions');
    const coordinateOptions1 = document.createElementNS(sscwsNs, "CoordinateOptions");
      const coordinateSystem1 = document.createElementNS(sscwsNs, "CoordinateSystem");
      coordinateSystem1.textContent = 'Gse';
      coordinateOptions1.appendChild(coordinateSystem1);
      const component1 = document.createElementNS(sscwsNs, "Component");
      component1.textContent = 'X';
      coordinateOptions1.appendChild(component1);
    graphOptions.appendChild(coordinateOptions1);
    const coordinateOptions2 = document.createElementNS(sscwsNs, "CoordinateOptions");
      const coordinateSystem2 = document.createElementNS(sscwsNs, "CoordinateSystem");
      coordinateSystem2.textContent = 'Gse';
      coordinateOptions2.appendChild(coordinateSystem2);
      const component2 = document.createElementNS(sscwsNs, "Component");
      component2.textContent = 'Y';
      coordinateOptions2.appendChild(component2);
    graphOptions.appendChild(coordinateOptions2);
    const coordinateOptions3 = document.createElementNS(sscwsNs, "CoordinateOptions");
      const coordinateSystem3 = document.createElementNS(sscwsNs, "CoordinateSystem");
      coordinateSystem3.textContent = 'Gse';
      coordinateOptions3.appendChild(coordinateSystem3);
      const component3 = document.createElementNS(sscwsNs, "Component");
      component3.textContent = 'Z';
      coordinateOptions3.appendChild(component3);
    graphOptions.appendChild(coordinateOptions3);
    const valueOptions = document.createElementNS(sscwsNs, "ValueOptions");
      const radialDistance = document.createElementNS(sscwsNs, "RadialDistance");
      radialDistance.textContent = 'true';
      valueOptions.appendChild(radialDistance);
      const bFieldStrength = document.createElementNS(sscwsNs, "BFieldStrength");
      bFieldStrength.textContent = 'true';
      valueOptions.appendChild(bFieldStrength);
      const dipoleLValue = document.createElementNS(sscwsNs, "DipoleLValue");
      dipoleLValue.textContent = 'true';
      valueOptions.appendChild(dipoleLValue);
      const dipoleInvLat = document.createElementNS(sscwsNs, "DipoleInvLat");
      dipoleInvLat.textContent = 'true';
      valueOptions.appendChild(dipoleInvLat);
    graphOptions.appendChild(valueOptions);

    const distanceFromOptions = document.createElementNS(sscwsNs, "DistanceFromOptions");
      const neutralSheet = document.createElementNS(sscwsNs, "NeutralSheet");
      neutralSheet.textContent = 'true';
      distanceFromOptions.appendChild(neutralSheet);
      const bowShock = document.createElementNS(sscwsNs, "BowShock");
      bowShock.textContent = 'true';
      distanceFromOptions.appendChild(bowShock);
      const mPause = document.createElementNS(sscwsNs, "MPause");
      mPause.textContent = 'true';
      distanceFromOptions.appendChild(mPause);
      const bGseXyz = document.createElementNS(sscwsNs, "BGseXYZ");
      bGseXyz.textContent = 'true';
      distanceFromOptions.appendChild(bGseXyz);
    graphOptions.appendChild(distanceFromOptions);

    const bFieldTraceOptions = document.createElementNS(sscwsNs, "BFieldTraceOptions");
      const coordinateSystem = document.createElementNS(sscwsNs, "CoordinateSystem");
      coordinateSystem.textContent = 'Geo';
      bFieldTraceOptions.appendChild(coordinateSystem);
      const hemisphere = document.createElementNS(sscwsNs, "Hemisphere");
      hemisphere.textContent = 'North';
      bFieldTraceOptions.appendChild(hemisphere);
      const footpointLatitude = document.createElementNS(sscwsNs, "FootpointLatitude");
      footpointLatitude.textContent = 'true';
      bFieldTraceOptions.appendChild(footpointLatitude);
      const footpointLongitude = document.createElementNS(sscwsNs, "FootpointLongitude");
      footpointLongitude.textContent = 'true';
      bFieldTraceOptions.appendChild(footpointLongitude);
      const fieldLineLength = document.createElementNS(sscwsNs, "FieldLineLength");
      fieldLineLength.textContent = 'true';
      bFieldTraceOptions.appendChild(fieldLineLength);
    graphOptions.appendChild(bFieldTraceOptions);

    return graphOptions;
}


/**
 * Gets a <GraphOptions> xml element corresponding to the specified
 * option.
 *
 * @param {String} option - the GraphOptions option to get.
 */
function getGraphOptions(option) {

  const graphOptions = document.createElementNS(sscwsNs, "GraphOptions");

  if (option == 'Orbit') {

    return getOrbitGraphOptions(graphOptions);
  }
  else if (option == 'Mapped') {

    return getMappedGraphOptions(graphOptions);
  }
  else {

    return getTimeSeriesGraphOptions(graphOptions);
  }
}


/**
 * Displays the resulting plot.
 *
 * @param {Object} result - plot request result.
 */
function displayPlot(result) {

  $("#requestButton").prop("disabled", false);

  let urls = $(result).find('Name').map(function () {
                return $(this).text();
            }).get();

  for (let i = 0; i < urls.length; i++) {

    if (urls[i].endsWith('.gif')) {

      $('#plotImg').attr('src', urls[i]);
    }
    else if (urls[i].endsWith('.pdf')) {
//      $('#plotObject').attr('data', urls[i]);
      $('#plotIframe').attr('src', urls[i]);
//      $('#plotEmbed').attr('src', urls[i]);
    }
  }

  $('#notes').slideUp(3000);
}


/**
 * Gets an ISO 8601 date/time value from the input date/time value.
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
 */
function validTimeRange(sat, startDate, endDate) {

  let satStartDate = getDateFromIso8601(sat.StartTime);
  let satEndDate = getDateFromIso8601(sat.EndTime);

  if (startDate >= satStartDate && endDate <= satEndDate) {

      return '';
  }
  else {

      return 'Time range outside of data for ' + sat.Name +
              '.\n\nIt must be within ' + sat.StartTime + '\nto ' + 
              sat.EndTime + '.';
  }
}

/**
 * Performs final validation and constructs an XML GraphRequest from the 
 * user's input.  The XML request is used to make a web service request 
 * to SSC to request the data.  The displayPlot function is called
 * to handle the results.
 */
async function requestData() {

  // disable rapid, repeated requests
  $("#requestButton").prop("disabled", true);


  let selectedSats = $('#satSel option:selected').map(
    function(){ 
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

  const req = document.implementation.createDocument(sscwsNs, "GraphRequest");

  const timeInterval = document.createElementNS(sscwsNs, "TimeInterval");
  const start = document.createElementNS(sscwsNs, "Start");
  start.textContent = iso8601Start;
  const end = document.createElementNS(sscwsNs, "End");
  end.textContent = iso8601End;
  timeInterval.appendChild(start);
  timeInterval.appendChild(end);
  req.documentElement.appendChild(timeInterval);

  const bFieldModel = document.createElementNS(sscwsNs, "BFieldModel");
  const internalBFieldModel = document.createElementNS(sscwsNs, "InternalBFieldModel");
  internalBFieldModel.textContent = 'IGRF';
  bFieldModel.appendChild(internalBFieldModel);
  const externalBFieldModel = document.createElementNS(sscwsNs, "ExternalBFieldModel");
  externalBFieldModel.setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
  externalBFieldModel.setAttribute('xsi:type', 'Tsyganenko89cBFieldModel');
  const keyParameterValues = document.createElementNS(sscwsNs, "KeyParameterValues");
  keyParameterValues.textContent = 'KP3_3_3';
  externalBFieldModel.appendChild(keyParameterValues);
  bFieldModel.appendChild(externalBFieldModel);
  const traceStopAltitude = document.createElementNS(sscwsNs, "TraceStopAltitude");
  traceStopAltitude.textContent = '100';
  bFieldModel.appendChild(traceStopAltitude);
  req.documentElement.appendChild(bFieldModel);

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
    const resolutionFactor = document.createElementNS(sscwsNs, "ResolutionFactor");
    resolutionFactor.textContent = '2';
    satellites.appendChild(id);
    satellites.appendChild(resolutionFactor);
    req.documentElement.appendChild(satellites);
  }

  let opt = $('input:radio[name=DISPLAY_TYPE]:checked').val();
  req.documentElement.appendChild(getGraphOptions(opt));

  const serializer = new XMLSerializer();
  const xmlRequest = serializer.serializeToString(req);


  let graphRequest = {
      method: 'POST',
      body: xmlRequest,
      headers: new Headers({
          'Content-Type': 'application/xml'
      })
  }

  try {

    const response = await fetch(sscUrl + '/graphs', graphRequest);
    if (!response.ok) {

      alert(`${sscUrl + '/graphs'} HTTP error status = ${response.status}`);
      console.log(xmlRequest)
      return;
    }
    const reply = await response.text();
    const parser = new DOMParser();
    const xmlReply = parser.parseFromString(reply, 'application/xml');
    displayPlot(xmlReply);
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
 * Called when the browser is finished construction of the DOM.
 */
$(document).ready(getObservatories);

