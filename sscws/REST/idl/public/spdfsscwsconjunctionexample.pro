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
; Portions Copyright [yyyy] [name of copyright owner}
;
; NOSA HEADER END
;
; Copyright (c) 2021 United States Government as represented by
; the National Aeronautics and Space Administration. No copyright is
; claimed in the United States under Title 17, U.S.Code. All Other
; Rights Reserved.
;
;

;+
; This program is an example to demonstrate calling the
; <a href="https://sscweb.gsfc.nasa.gov/">Satellite Situation Center's</a>
; <a href="https://sscweb.gsfc.nasa.gov/WebServices/REST/">
; REST Web Services</a> from an
; <a href="https://www.l3harrisgeospatial.com/Software-Technology/IDL">
; L3Harris Interactive Data Language (IDL)</a> program.  It demonstrates the
; following:
;   <ul>
;     <li>Using the IDL/Python bridge to find magnetic field line
;         conjunctions using the Python 
;         <a href="https://pypi.org/project/sscws/">sscws library</a>.
;         The python sscws library is used because, at this time, the IDL
;         <a href="https://sscweb.gsfc.nasa.gov/WebServices/REST/SscIdlLibrary.html">
;         sscws library</a> lacks support for conjunction query requests.</li>
;   </ul>
; To successfully run this program, you must do the following:
; <ul>
;   <li>Configure your IDL environment to support the IDL to Python bridge
;       as described in the IDL documentation.</li>
;   <li>Configure your Python environment to support the sscws library.  That
;       is, <code>$ pip install sscws</code>.</li>
; </ul>
;
; @copyright Copyright (c) 2021 United States Government as
;     represented by the National Aeronautics and Space Administration.
;     No copyright is claimed in the United States under Title 17,
;     U.S.Code. All Other Rights Reserved.
;
; @author B. Harris
;-



;+
; Creates an example conjunction query request.  The object returned is a
; Python <a href="https://pypi.org/project/sscws/">sscws</a>.request 
; QueryRequest object for use in the sscws.sscws.get_conjunctions() method.
; The query is for magnetic field line conjunctions of at least 2 THEMIS
; satellites with one of 4 THEMIS ground stations duing 2008 doy = 1 - 5.
;
; @returns an example Python sscws.request QueryRequest.
;-
function SpdfGetExampleConjunctionRequest

    compile_opt idl2

    np = Python.Import('numpy')
    cj = Python.Import('sscws.conjunctions')
    co = Python.Import('sscws.coordinates')
    req = Python.Import('sscws.request')
    ti = Python.Import('sscws.timeinterval')
    tr = Python.Import('sscws.tracing')

    sats = Python.Wrap(List($
        cj.Satellite('themisa', tr.BFieldTraceDirection.SAME_HEMISPHERE), $
        cj.Satellite('themisb', tr.BFieldTraceDirection.SAME_HEMISPHERE), $
        cj.Satellite('themisc', tr.BFieldTraceDirection.SAME_HEMISPHERE), $
        cj.Satellite('themisd', tr.BFieldTraceDirection.SAME_HEMISPHERE), $
        cj.Satellite('themise', tr.BFieldTraceDirection.SAME_HEMISPHERE) $
    ))

    satellite_condition = cj.SatelliteCondition(sats, 2)
    box_conjunction_area = cj.BoxConjunctionArea(cj.TraceCoordinateSystem.GEO, 3.0, 10.0)
    ground_stations = Python.Wrap(List($
        cj.GroundStationConjunction('FSMI', 'THM_Fort Smith',$
            co.SurfaceGeographicCoordinates(59.98, -111.84),$
            box_conjunction_area),$
        cj.GroundStationConjunction('WHIT', 'THM_White Horse',$
            co.SurfaceGeographicCoordinates(61.01, -135.22),$
            box_conjunction_area),$
        cj.GroundStationConjunction('FSIM', 'THM_Fort Simpson',$
            co.SurfaceGeographicCoordinates(61.80, -121.20),$
            box_conjunction_area),$
        cj.GroundStationConjunction('GAK', 'THM_HAARP/Gakona',$
            co.SurfaceGeographicCoordinates(62.40, -145.20),$
            box_conjunction_area)$
    ))
    ground_station_condition = $
        cj.GroundStationCondition(ground_stations,$
            cj.TraceCoordinateSystem.GEO, tr.TraceType.B_FIELD)

    conditions = Python.Wrap(List(satellite_condition, ground_station_condition))

    query_request = $
        req.QueryRequest('Magnetic conjunction of at least 2 THEMIS satellites with one of 4',$
            ti.TimeInterval('2008-01-05T10:00:00Z', '2008-01-05T11:59:59Z'),$
            cj.ConditionOperator.ALL, conditions)

    return, query_request
end


;+
; Prints a Python Dict representation of a QueryResult as defined in
; <a href="https://sscweb.gsfc.nasa.gov/WebServices/REST/SSC.xsd">
; SSC.xsd</a>.
;
; @param result {in} {type=hash}
;            QueryResult to print.
;-
pro SpdfPrintConjunctionResult, result
    compile_opt idl2
    foreach conjunction, result['Conjunction'] do begin

        print, (conjunction['TimeInterval'])['Start'].isoformat(), ' to ', $
               (conjunction['TimeInterval'])['End'].isoformat()
        print, 'Satellite', 'Lat', 'Lon', 'Radius', 'Ground Station', $
               'Lat', 'Lon', 'ArcLen', $
            format='%10s %7s %7s %9s %20s %7s %7s %9s'

        foreach sat, conjunction['SatelliteDescription'] do begin

            foreach description, sat['Description'] do begin

                trace = description['TraceDescription']
                print, sat['Satellite'], $
                       (description['Location'])['Latitude'], $
                       (description['Location'])['Longitude'], $
                       (description['Location'])['Radius'], $
                       (trace['Target'])['GroundStation'], $
                       (trace['Location'])['Latitude'], $
                       (trace['Location'])['Longitude'], $
                       trace['ArcLength'], $
                    format='%10s %7.2f %7.2f %9.2f %20s %7.2f %7.2f %9.2f'
            endforeach
        endforeach
    endforeach
end


;+
; This procedure is an example to demonstrate calling the SSC REST Web 
; Services from an IDL program.  It demonstrates the following:
;   <ul>
;     <li>Using the IDL/Python bridge to find magnetic field line
;         conjunctions using the Python 
;         <a href="https://pypi.org/project/sscws/">sscws library</a>.
;         The python sscws library is used because, at this time, the IDL
;         <a href="https://sscweb.gsfc.nasa.gov/WebServices/REST/SscIdlLibrary.html">
;         sscws library</a> lacks support for conjunction query requests.</li>
;   </ul>
;-
pro SpdfSscWsConjunctionExample
    compile_opt idl2

    sscws = Python.Import('sscws.sscws')

    ssc = sscws.SscWs()

    ;observatories = ssc.get_observatories()
    ;foreach observatory,observatories['Observatory'] do print, observatory['Name']

    result = ssc.get_conjunctions(SpdfGetExampleConjunctionRequest())

    SpdfPrintConjunctionResult, result
end

