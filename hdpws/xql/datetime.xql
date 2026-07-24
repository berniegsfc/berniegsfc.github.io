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
 :   https://sscweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
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
 : Copyright (c) 2020-2023 United States Government as represented by
 : the National Aeronautics and Space Administration. No copyright is
 : claimed in the United States under Title 17, U.S.Code. All Other
 : Rights Reserved.
 :
 :)

(:~
 : This library module provides xs:dateTime related functions not found 
 : in the standard XQuery library.  They are minimal implementations that 
 : may not be suited for general use.
 :
 : Note: This module is incomplete and a mere demonstration.
 :
 : @author B. Harris
 :)
module namespace spdfdatetime = "http://spdf.gsfc.nasa.gov/datetime";


declare namespace util="http://exist-db.org/xquery/util";
declare namespace test="http://exist-db.org/xquery/xqsuite";


(:~
 : A "null" xs:dateTime value to indicate "no value".  This is useful
 : when needing to store a null value in a sequence.
 :)
declare variable $spdfdatetime:nullDateTime :=
    xs:dateTime("-9999-01-01T00:00:00Z");


(:~
 : format-dateTime format pattern for date time value found in an HTTP
 : headers (RFC 2616).
 :)
declare variable $spdfdatetime:rfc2616DateTimeFormat :=
    "[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] GMT";



(:~
 : Returns the basic (minimal separators) 8601 string representation of
 : the given dateTime.
 :
 : @param $value a dateTime.
 : @return $value basic 8601 string representation of the given $value.
 :)
declare
    %test:arg("value", "2020-01-01T00:00:00.123Z")
        %test:assertEquals("20200101T000000Z")
function spdfdatetime:basic8601(
    $value as xs:dateTime)
as xs:string
{
    let $floor := spdfdatetime:floor($value)
    return
        replace($floor, '[-:]', '')
};


(:~
 : Returns the largest dateTime not greater than the given value.
 :
 : @param $value a dateTime.
 : @return $value without the factional seconds.
 :)
declare
    %test:arg("value", "2020-01-01T00:00:00.123Z")
        %test:assertEquals("2020-01-01T00:00:00Z")
function spdfdatetime:floor(
    $value as xs:dateTime)
as xs:dateTime
{
    let $seconds := seconds-from-dateTime($value)
    let $fraction := $seconds - floor($seconds)
    let $roundDown := xs:dayTimeDuration(
                          concat("-PT0", 
                              format-number($fraction, ".###"), 
                              "S"))
    return
        $value + $roundDown
};


(:~
 : Determines if the given year is a leap year in the Gregorian calendar.
 :
 : @param $value year to test.
 : @return true if the value is a leap year.  Otherwise, false.
 :)
declare
    %test:arg("value", 1900) %test:assertFalse
    %test:arg("value", 1999) %test:assertFalse
    %test:arg("value", 2000) %test:assertTrue
function spdfdatetime:isLeapYear(
    $value as xs:int)
    as xs:boolean
{
    let $result := ($value mod 4 = 0 and $value mod 100 != 0) or
                   $value mod 400 = 0
    return
        $result
};


(:~
 : Parses an RFC 2616 date time value.  Note that this does not currently
 : support all formats allowed by the RFC -- only the most common.
 :
 : @param $value string to parse.
 : @return dateTime value corresponding to the given string representation.
 :)
declare
    %test:arg("value", "Sat, 04 Jul 2020 21:12:12 GMT") 
        %test:assertEquals("2020-07-04T21:12:12Z")
function spdfdatetime:parseRfc2616dateTime(
    $value as xs:string)
    as xs:dateTime?
{
    let $fields := tokenize($value, "\s+")
    let $month := switch(lower-case($fields[3]))
                  case "jan" return "01"
                  case "feb" return "02"
                  case "mar" return "03"
                  case "apr" return "04"
                  case "may" return "05"
                  case "jun" return "06"
                  case "jul" return "07"
                  case "aug" return "08"
                  case "sep" return "09"
                  case "oct" return "10"
                  case "nov" return "11"
                  case "dec" return "12"
                  default return ()
    let $tz := switch(lower-case($fields[6]))
               case "gmt" return xs:dayTimeDuration("PT0H")
               default return xs:dayTimeDuration("PT0H")
    let $date := string-join(($fields[4], $month, $fields[2]), "-")
    let $iso8601 := string-join(($date, $fields[5]), "T")
    let $dateTime := xs:dateTime($iso8601)
    let $dateTimeWithTz := adjust-dateTime-to-timezone($dateTime, $tz)
    return
        adjust-dateTime-to-timezone($dateTime, $tz)
    (: catch err:FORG0001 {??? or just allow it to propagate up} :)
};


(:~
 : Produces the month and day-of-month from an ordinal date (year and
 : day-of-year).
 :
 : @param $year year value.
 : @param $doy day-of-year value.
 : @return sequence containing the corresponding month and day-of-month.
 :)
declare
    %test:args(2020, 5) %test:assertEquals(1, 5)
    %test:args(2020, 31) %test:assertEquals(1, 31)
    %test:args(2020, 32) %test:assertEquals(2, 1)
    %test:args(2020, 60) %test:assertEquals(2, 29)
    %test:args(2020, 61) %test:assertEquals(3, 1)
    %test:args(2019, 59) %test:assertEquals(2, 28)
    %test:args(2019, 60) %test:assertEquals(3, 1)
function spdfdatetime:monthDayFromOrdinalDate(
    $year as xs:int,
    $doy as xs:int)
as xs:int*
{
(:
                  then (31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 336)
:)
    let $monthDays := if (spdfdatetime:isLeapYear($year))
                  then (366, 335, 305, 274, 244, 213, 182, 152, 121, 91, 60, 31, 0)
                  else (365, 334, 304, 273, 243, 212, 181, 151, 120, 90, 59, 31, 0)
    for $daysInMonths at $month in $monthDays
    where $doy >= $daysInMonths
    let $dayInMonth := $doy - $daysInMonths
    let $daysInThisMonth := $monthDays[$month - 1] - $daysInMonths  + 1
    return
        if ($dayInMonth > 0 and $dayInMonth < $daysInThisMonth)
        then (14 - $month, $dayInMonth)
        else ()
};


(:~
 : Produces the xs:dateTime value corresponding to the given ISO 8601 
 : representation containing a year/day-of-year value.
 :
 : @param $value string to parse.
 : @return dateTime value corresponding to the given string representation.
 :)
declare 
    %test:args("2020-366T00:00:00Z") %test:assertEquals("2020-12-31T00:00:00Z")
    %test:args("2019-365T00:00:00Z") %test:assertEquals("2019-12-31T00:00:00Z")
function spdfdatetime:dateTimeFromIso8601Doy(
    $value as xs:string)
as xs:dateTime?
{
    let $components := tokenize($value, "[\-T]")
    let $monthDay := if (count($components) = 3)
            then (
                spdfdatetime:monthDayFromOrdinalDate(
                    xs:int($components[1]), xs:int($components[2]))
            )
            else ()
    return
        if (count($monthDay) = 2)
        then (
            xs:dateTime(concat($components[1], '-', format-number($monthDay[1], '00'), '-',
                                format-number($monthDay[2], '00'), 'T', $components[3]))
        )
        else ()
};


(:~
 : Produces the xs:dateTime value corresponding to the given ISO 8601.
 : This function supports more formats than the xs:dateTime constructor.
 : The additional formats are a date with no time and a date containing
 : a year and day-of-year value instead of a year, month, day-of-month.
 :
 : @param $value string to parse.
 : @return dateTime value corresponding to the given string representation.
 :)
declare 
    %test:args("2020-12-31T00:00:00Z") %test:assertEquals("2020-12-31T00:00:00Z")
    %test:args("2020-12-31") %test:assertEquals("2020-12-31T00:00:00Z")
    %test:args("2020-12-31TZ") %test:assertEquals("2020-12-31T00:00:00Z")
    %test:args("2020-366T00:00:00Z") %test:assertEquals("2020-12-31T00:00:00Z")
    %test:args("2019-365T00:00:00Z") %test:assertEquals("2019-12-31T00:00:00Z")
function spdfdatetime:dateTimeFromIso8601(
    $iso8601 as xs:string)
as xs:dateTime?
{
    let $result :=
        if ($iso8601 castable as xs:dateTime)
        then (
            xs:dateTime($iso8601)
        )    
        else if (tokenize($iso8601,"T")[1] castable as xs:date)
        then (
            dateTime(xs:date(tokenize($iso8601, "T")[1]), xs:time("00:00:00Z"))
        )    
        else (
            spdfdatetime:dateTimeFromIso8601Doy($iso8601)
        )
    return
        $result
};
