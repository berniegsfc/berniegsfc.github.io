xquery version "3.1";

(:
 : NOSA HEADER START
 :
 : The contents of this file are subject to the terms of the NASA Open
 : Source Agreement (NOSA), Version 1.3 only (the "Agreement").  You may
 : not use this file except in compliance with the Agreement.
 :
 : You can obtain a copy of the agreement at
 :   docs/NASA_Open_Source_Agreement_1.3.txt
 : or
 :   https://cdaweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
 :
 : See the Agreement for the specific language governing permissions
 : and limitations under the Agreement.
 :
 : When distributing Covered Code, include this NOSA HEADER in each
 : file and include the Agreement file at
 : docs/NASA_Open_Source_Agreement_1.3.txt.  If applicable, add the
 : following below this NOSA HEADER, with the fields enclosed by
 : brackets "[]" replaced with your own identifying information:
 : Portions Copyright [yyyy] [name of copyright owner]
 :
 : NOSA HEADER END
 :
 : Copyright (c) 2016-2024 United States Government as represented by
 : the National Aeronautics and Space Administration. No copyright is
 : claimed in the United States under Title 17, U.S.Code. All Other
 : Rights Reserved.
 :
 :)


(:~
 : This library module provides common constants and functions for
 : accessing the Coordinated Data Analysis System (CDAS) Web Services
 : @see https://cdaweb.gsfc.nasa.gov/WebServices/.
 :
 : Note: This module is incomplete and a mere demonstration.
 :
 : @author B. Harris
 :)
module namespace cdasws = "http://cdaweb.gsfc.nasa.gov/cdasws";


declare namespace hc="http://expath.org/ns/http-client";
declare namespace util="http://exist-db.org/xquery/util";
(: For eXist-db 3.x, change above to the following
declare namespace console="http://exist-db.org/xquery/console";
:)
declare namespace json="http://www.json.org";

declare namespace cdas="http://cdaweb.gsfc.nasa.gov/schema";
declare namespace hapi="http://hpde.gsfc.nasa.gov/hapi";

import module namespace spdfdatetime = "http://spdf.gsfc.nasa.gov/datetime"
  at "https://cdaweb.gsfc.nasa.gov/WebServices/hapi/datetime.xql";



(:~
 : The /Spase/NumericalData/AccessInformation/AccessURL/Name value
 : for CDAWeb.
 :)
declare variable $cdasws:accessUrlName := "CDAWeb";


(:~
 : Common part of URL for the CDAS web services.
 :)
declare variable $cdasws:url := 
    "https://cdaweb.gsfc.nasa.gov/WS/cdasr/1/dataviews/sp_phys/datasets";
(:
    "http://cdaweb-dev.sci.gsfc.nasa.gov/WS/cdasr/1/dataviews/sp_phys/datasets";
:)



(:~
 : Produces a sequence of HTTP query paramter strings for the given
 : paramter name and values.
 :
 : @param name query parameter name.
 : @param values query parameter values.
 : @return a sequence of HTTP query paramter strings of the form
 :     "name=value" with value uri encoded.
 :)
declare function cdasws:getQueryParams(
    $name as xs:string,
    $values as xs:string*)
as xs:string*
{
    for $value in $values 
    return 
        $name || "=" || encode-for-uri($value)
};


(:~ 
 : Gets the CDAS datasets.
 :
 : @param $observatoryGroups observatory group values.  Omitting this
 :     parameter indicates that no datasets are eliminated based upon
 :     their observatoryGroup value.
 : @param $instrumentType an instrument type value.  Omitting this
 :     parameter indicates that no datasets are eliminated based upon
 :     their instrumentType value.
 : @param $observatory an observatory value.  Omitting this
 :     parameter indicates that no datasets are eliminated based upon
 :     their observatory value.
 : @param $instrument an instrument value.  Omitting this
 :     parameter indicates that no datasets are eliminated based upon
 :     their instrument value.
 : @param $startDate the start of a time interval.  If this parameter 
 :     is ommited, the time interval will begin infinitely in the past.
 : @param $stopDate the start of a time interval.  If this parameter 
 :     is ommited, the time interval will begin infinitely in the future.
 : @param $idPattern a java.util.regex compatible regular expression 
 :     that must match the dataset's identifier value.  Omitting this 
 :     parameter is equivalent to ".*".
 : @param $labelPattern a java.util.regex compatible regular expression 
 :     that must match the dataset's label value.  Omitting this 
 :     parameter is equivalent to ".*".
 : @param $notesPattern a java.util.regex compatible regular expression 
 :     that must match the dataset's notes value.  Omitting this 
 :     parameter is equivalent to ".*".
 : @return the requested cdas:DatasetDescription.
 :)
declare function cdasws:getDatasets(
    $observatoryGroups as xs:string*,
    $instrumentType as xs:string?,
    $observatory as xs:string?,
    $instrument as xs:string?,
    $startDate as xs:dateTime?,
    $stopDate as xs:dateTime?,
    $idPattern as xs:string?,
    $labelPattern as xs:string?,
    $notesPattern as xs:string?
)
as node()*
{
    let $q1 := if (exists($observatoryGroups))
               then cdasws:getQueryParams("observatoryGroup", $observatoryGroups)
               else ()
    let $q2 := if (exists($instrumentType))
               then ($q1, "intrumentType=" || 
                          encode-for-uri($instrumentType))
               else ($q1)
    let $q3 := if (exists($observatory))
               then ($q2, "observatory=" || 
                          encode-for-uri($observatory))
               else ($q2)
    let $q4 := if (exists($instrument))
               then ($q3, "intrument=" || 
                          encode-for-uri($instrument))
               else ($q3)
    let $q5 := if (exists($startDate))
               then ($q4, "startDate=" || 
                          spdfdatetime:basic8601($startDate))
               else ($q4)
    let $q6 := if (exists($stopDate))
               then ($q5, "stopDate=" || 
                          spdfdatetime:basic8601($stopDate))
               else ($q5)
    let $q7 := if (exists($idPattern))
               then ($q6, "idPattern=" ||
                          encode-for-uri($idPattern))
               else ($q6)
    let $q8 := if (exists($labelPattern))
               then ($q7, "labelPattern=" ||
                          encode-for-uri($labelPattern))
               else ($q7)
    let $q9 := if (exists($notesPattern))
               then ($q8, "notesPattern=" ||
                          encode-for-uri($notesPattern))
               else ($q8)
    let $queryParams := string-join($q9, "&amp;")
    
    let $datasetsUrl :=  if (string-length($queryParams) gt 0)
            then (xs:anyURI(string-join(($cdasws:url, $queryParams), '?')))
            else (xs:anyURI($cdasws:url))
    let $datasets := hc:send-request(<hc:request method="get"/>,
                                      $datasetsUrl)
    let $status := $datasets[1]/@status
    return
        if ($status = 200)
        then (
            $datasets[2]/cdas:Datasets
        )   
        else (
            util:log("error", ("Call to ", $datasetsUrl, 
                               " failed with status ", $status))
        )   
};


(:~
 : Determines if the given URL is an cdaweb URL.
 :
 : @param $url value to test.
 : @return true if $url is an cdaweb URL.  Otherwise, false.
 :)
declare function cdasws:isCdasUrl(
    $url as xs:string)
as xs:boolean
{
    let $result := matches($url, ".*cdaweb.*")
    return
        $result
};


(:~
 : Gets the inventory intervals from a cdas:Inventory fragment and
 : returns the corresponding HAPI intervals.
 :
 : @param $inventory cdas:Inventory fragment to search.
 : @return HAPI intervals obtained from given cdas:Inventory.
 :)
declare function cdasws:getInventoryIntervals(
    $inventory as node()*)
as node()*
{
    for $interval in $inventory/cdas:InventoryDescription/cdas:TimeInterval
    return
        <hapi:intervals json:array="true">
            <hapi:begin>{$interval/cdas:Start/text()}</hapi:begin>
            <hapi:end>{$interval/cdas:End/text()}</hapi:end>
        </hapi:intervals>
};


(:~ 
 : Gets the inventory for the specified CDAS dataset.
 :
 : @param $datasetId CDAS dataset identifier whose inventory is being
 :     requested.
 : @return the time intervals when data is available for the specified
 :     dataset.
 :)
declare function cdasws:getCdasInventory(
    $datasetId as xs:string)
as node()*
{
    let $inventoryUrl :=  
        xs:anyURI(string-join(($cdasws:url, $datasetId, 'inventory'), '/'))
    let $inventory := hc:send-request(<hc:request method="get"/>,
                                      $inventoryUrl)
    let $status := $inventory[1]/@status
    return
        if ($status = 200)
        then (
            cdasws:getInventoryIntervals($inventory[2]/cdas:Inventory)
        )   
        else (
            util:log("error", ("Call to ", $inventoryUrl, 
                               " failed with status ", $status))
        )   
};



(:~ 
 : Gets descriptions of the variables for the specified CDAS dataset.
 :
 : @param $datasetId CDAS dataset identifier whose variable descriptions 
 :     are being requested.
 : @return descriptions of the variables for the specified CDAS dataset.
 :)
declare function cdasws:getVariableDescriptions(
    $datasetId as xs:string)
as node()*
{
    let $varsUrl :=
        xs:anyURI(string-join(($cdasws:url, $datasetId, 'variables'), '/'))
    let $vars := hc:send-request(<hc:request method="get"/>, $varsUrl)
    let $status := $vars[1]/@status
    return
        if ($status = 200)
        then (
            let $varDescriptions := $vars[2]/cdas:Variables/cdas:VariableDescription
            return
                $varDescriptions
        )
        else (
            util:log("error", ("Call to ", $varsUrl,
                               " failed with status ", $status))
        )
};


(:~ 
 : Gets the names of the variables for the specified CDAS dataset.
 :
 : @param $datasetId CDAS dataset identifier whose variable names are being
 :     requested.
 : @return names of the variables for the specified CDAS dataset.
 :)
declare function cdasws:getVariableNames(
    $datasetId as xs:string)
as xs:string*
{
    let $varDescriptions := cdasws:getVariableDescriptions($datasetId)
    return
        $varDescriptions/cdas:Name/text()
};


(:~
 : Creates CDAS DataRequest/VariableName elements for the specified
 : variables.
 :
 : @param $names names of variables to include.
 : @return CDAS DataRequest/VariableName elements for the specified
 :     variables.
 :)
declare function cdasws:createVariableNames(
    $names as xs:string*)
as node()*
{
    let $modifiedNames := if (count($names) eq 0)
                          then (
                              ("ALL-VARIABLES")
                          )
                          else (
                              $names
                          )
    for $name in $names
    return
        <VariableName xmlns="http://cdaweb.gsfc.nasa.gov/schema">{$name}</VariableName>
};


(:~
 : Calls the CDAS web services to get the specified data.
 :
 : @param $id CDAS dataset identifier.
 : @param $timeMin start of time range.
 : @param $timeMax end of time range.
 : @param $params names of variables whose data is to be obtained.
 : @param $ifModifiedSince If-Modified-Since header value.
 : @return hc:response from the call.
 :)
declare function cdasws:getCdfmlData(
    $id as xs:string,
    $timeMin as xs:dateTime,
    $timeMax as xs:dateTime,
    $params as xs:string*,
    $ifModifiedSince as xs:string?)
as node()*
{
    let $url := xs:anyURI($cdasws:url)
    let $headers := (
        element hc:header {
            attribute name {"Content-Type"},
            attribute value {"application/xml"}
        },
        element hc:header {
            attribute name {"Accept"},
            attribute value {"application/xml"}
        },
        if (string-length($ifModifiedSince) gt 0)
        then
            element hc:header {
                attribute name {"If-Modified-Since"},
                attribute value {$ifModifiedSince}
            }
        else ()
    )

    let $dataRequest := <hc:request method="post">{$headers}
      <hc:body media-type="application/xml">
        <DataRequest xmlns="http://cdaweb.gsfc.nasa.gov/schema">
          <CdfRequest>
            <TimeInterval>
              <Start>{$timeMin}</Start>
              <End>{$timeMax}</End>
            </TimeInterval>
            <DatasetRequest>
              <DatasetId>{$id}</DatasetId>
              {cdasws:createVariableNames($params)}
            </DatasetRequest>
            <CdfVersion>3</CdfVersion>
            <CdfFormat>CDFML</CdfFormat>
          </CdfRequest>
        </DataRequest>
      </hc:body>
    </hc:request>

    let $response := hc:send-request($dataRequest, $url)
    let $status := $response[1]/@status
    return
        if ($status = 200 or $status = 304)
        then (
            $response
        )
        else (
            util:log("error", ("Call to ", $url, " with ", $dataRequest, 
                     " failed with status ", $status))
        )
};



(:~
 : Gets the specified CDFML data.
 :
 : @param $url URL of CDFML data to get.
 : @param names names of variables whose record values are to be returned
 :     from the CDFML.
 : @return the requested CDFML data.
 :)
declare function cdasws:getCdfmlData(
    $url as xs:anyURI)
as node()*
{
    let $cdfml := hc:send-request(<hc:request method="get"/>, $url)
    let $status := $cdfml[1]/@status
    return
        if ($status = 200)
        then (
            $cdfml
        )
        else (
            util:log("error", ("Call to ", $url,
                               " failed with status ", $status)),
            <cdasws:result>
                <cdasws:error>CDAWeb error: {$status}.</cdasws:error>
            </cdasws:result>
        )
};


(:~
 : Gets the specified data.
 :
 : @param $id CDAS dataset idenifier of the data to get.
 : @param $timeMin start of time range.
 : @param $timeMax end of time range.
 : @param $params names of Parameters to get.
 : @param $ifModifiedSince If-Modified-Since header value.
 : @return the specified data (CDFML).
 :)
declare function cdasws:getData(
    $id as xs:string,
    $timeMin as xs:dateTime,
    $timeMax as xs:dateTime,
    $params as xs:string*,
    $ifModifiedSince as xs:string?)
as node()*
{
    let $response := cdasws:getCdfmlData($id, $timeMin, $timeMax, 
                         $params, $ifModifiedSince)
    let $status := $response[1]/@status

    let $cdasBody := $response[2]
    let $lastModified := $response[1]/hc:header[@name = "last-modified"]/@value
    let $lastModifiedHdr := if (string-length($lastModified) gt 0)
                            then
                                response:set-header("Last-Modified",
                                    $lastModified)
                            else ()
    let $cdasError := $cdasBody/cdas:DataResult/cdas:Error

    let $cdfmlUrl := $cdasBody/cdas:DataResult/cdas:FileDescription/cdas:Name/text()
    return
        if ($status eq "304")
        then (
            response:set-status-code(304),
            <cdasws:result>
                <cdasws:status>Not modified.</cdasws:status>
            </cdasws:result>
        )
        else if (count($cdasError) gt 0)
        then (
            (: this may need improving :)
            <cdasws:result>
                <cdasws:error>CDAWlib error: {$cdasError/text()}</cdasws:error>
            </cdasws:result>
        )
        else if ($cdfmlUrl)
        then (
            cdasws:getCdfmlData(xs:anyURI($cdfmlUrl))
        )
        else if (not($cdasBody/cdas:DataResult/node()))
        then (
            (: This happens when you request non-existent variables.
               Do I really want to report this as an error ??? :)
            <cdasws:result>
                <cdasws:error>CDAWeb returned no data.</cdasws:error>
            </cdasws:result>
        )
        else (
            util:log("error", ("Call to cdasws:getCdfmlData",
                               " failed with response ", $response)),
            <cdasws:result>
                <cdasws:error>Internal Server Error.</cdasws:error>
            </cdasws:result>
        )
};

