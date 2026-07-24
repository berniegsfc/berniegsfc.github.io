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
 : Copyright (c) 2022-2026 United States Government as represented by 
 : the National Aeronautics and Space Administration. No copyright is 
 : claimed in the United States under Title 17, U.S.Code. All Other 
 : Rights Reserved.
 :
 :)

(:~
 : This library module provides constants and functions related to
 : HDP'S SPASE.
 :
 : @author B. Harris
 :)

module namespace hdpspase = "http://heliophysicsdata.gsfc.nasa.gov/spase";

declare default element namespace "http://www.spase-group.org/data/schema";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace test="http://exist-db.org/xquery/xqsuite";

declare namespace xsd="http://www.w3.org/2001/XMLSchema";

declare namespace spase="http://www.spase-group.org/data/schema";


(:~
 : Path to SPASE schema in HDP database.
 :)
declare variable $hdpspase:spaseSchema := "/db/SPASE1.2.0/spase.xsd";


(:~
 : Regular expression representing a valid
 : Spase/NumericalData/ResourceID value.
 :)
declare variable $hdpspase:validResourceIdPattern :=
    "^spase://[-a-zA-Z]{3,8}/\w+(/\w+)*";


(:~
 : Regular expression for heliophysics dataset digital object
 : identifier (DOI) values.  Note that the regex below is based
 : upon "typical" DOI syntax and is stricter than the what the DOI
 : specification allows.  Whereas the DOI specification allows
 : "most legal Unicode characters" in the DOI "character string"
 : value, the pattern below only allows digits (and periods) in
 : the prefix and letter/digit/hyphen characters in the suffix.  The
 : pattern may need to be changed if it is ever found to be
 : too strict for actual, valid DOIs.  The expression contains
 : the following capture groups:
 :   1 = "https://doi.org/" or null
 :   2 = the actual DOI value (both the prefix and suffix)
 :)
declare variable $hdpspase:validDoiPattern := 
    "^(https://doi.org/)?(10\.\d+/[-a-zA-Z0-9]+)$";


(:~
 : Provides all SPASE document nodes.
 : 
 : @return all SPASE document nodes.
 :)
declare
function hdpspase:getSpaseDocs()
as item()*
{
    for $path in ('/db/SPASE1.2.0', '/db/aggregate')
        return collection($path)  
};


(:~
 : Returns the case-insensitive intersection of the given sequences.  That
 : is, $sequence1[.=$sequence2] with values differing only in case being
 : included.  Note that the result may contain duplicates.
 :
 : @param $sequence1 first sequence.
 : @param $sequence2 second sequence.
 : @return the case-insensitive intersection of the given sequences. Note
 :     that the result may contain duplicates.
 :)
declare
    %test:arg("sequence1", "a", "b", "c")
    %test:arg("sequence2", "B", "C", "d")
        %test:assertEquals("b", "c")
    %test:arg("sequence1", "Accept", "Content-Type")
    %test:arg("sequence2", "Accept", "Content-Type", "Origin", "User-Agent")
        %test:assertEquals("Accept", "Content-Type")
function hdpspase:caseBlindIntersection(
    $sequence1 as xs:string*,
    $sequence2 as xs:string*)
as xs:string*
{
    for $item1 in sort($sequence1)
    for $item2 in sort($sequence2)
    return
        if (lower-case($item1) eq lower-case($item2))
        then
            $item1
        else (
        )
};


(:~
 : Returns the SPASE schema version.
 :
 : @return the SPASE schema version.
 :)
declare 
        %test:assertEquals("2.7.2")
function hdpspase:getSchemaVersion()
as xs:string*
{
    let $version := doc($hdpspase:spaseSchema)/xsd:schema/@version
    return
        $version
};


(:~
 : Returns the specified enumeration values from the SPASE schema.
 :
 : @param $name enumeration name.
 : @return the specified SPASE enumeration values.
 :)
declare 
    %test:arg("name", "MeasurementType")
        %test:assertEquals("ActivityIndex", "Dopplergram", "Dust",
            "ElectricField", "EnergeticParticles", "Ephemeris", 
            "ImageIntensity", "InstrumentStatus", "IonComposition",
            "Irradiance", "MagneticField", "Magnetogram", 
            "NeutralAtomImages", "NeutralGas", "NotProvided", "Profile",
            "Radiance",
            "Spectrum", "SPICE", "ThermalPlasma", "Waves", "Waves.Active",
            "Waves.Passive")
function hdpspase:getSpaseEnumeration(
    $name as xs:string)
as xs:string*
{
    let $values := doc($hdpspase:spaseSchema)/xsd:schema/xsd:simpleType[@name = $name]/xsd:restriction/xsd:enumeration/@value
    for $value in $values
    return
        string($value)
};


(:~
 : Determines if the given values are valid for the specified SPASE 
 : enumeration.
 :
 : @param $name the name of a SPASE enumeration.
 : @param $values the values to be tested.
 : @return sequence of boolean values indicating whether the given values
 :     are valid for the named SPASE enumeration.
 :)
declare 
    %test:arg("name", "MeasurementType")
    %test:arg("values", "ActivityIndex")
        %test:assertEquals("true")
    %test:arg("name", "MeasurementType")
    %test:arg("values", "bad")
        %test:assertEquals("false")
function hdpspase:isValidEnumeration(
    $name as xs:string,
    $values as xs:string*)
as xs:boolean*
{
    let $types := hdpspase:getSpaseEnumeration($name)
    for $value in $values
    return
        index-of($types, $value) > 0
};


(:~
 : Determines if the given values consist solely of valid SPASE
 : ResourceID values.
 :
 : @param values string values that are to be tested.
 : @return sequence of boolean values indicating whether each input
 :     value is a valid SPASE ResourceID.
 :)
declare
    %test:arg("values")
        %test:assertEmpty
    %test:arg("values", "spase://ESA-NASA/NumericalData/Cluster/C1/WBD/VariableCadence")
        %test:assertEquals("true")
    %test:arg("values", "spase://HamSCI/NumericalData/HFRadars/AmateurRadioSignalReport/AmateurRadioSignalReport")
        %test:assertEquals("true")
    %test:arg("values", "spase://SMWG/Repository/JHU_APL/AMPTE-CCE")
        %test:assertEquals("true")
    %test:arg("values", "spase://SMWG/Repository/JHU_APL/AMPTE-CCE",
                        "spase://NASA/NumericalData/ACE/CRIS/L2/PT1H")
        %test:assertEquals("true", "true")
    %test:arg("values", "pase://NASA/NumericalData/ACE/CRIS/L2/PT1H")
        %test:assertEquals("false")
function hdpspase:isValidResourceId(
    $values as xs:string*)
as xs:boolean*
{
    for $value in $values
    return
        matches($value, $hdpspase:validResourceIdPattern)
};


(:~
 : Determines if the given values are valid Heliophysics Digital Object 
 : Identifiers (DOI) values.
 : 
 : @param $dois the values to be tested.
 : @return sequence of boolean values indicating whether the given values
 :     are valid DOI values.
 :)
declare
    %test:arg("dois", "https://doi.org/10.48322/f2a8-nm36", "10.48322/f2a8-nm36", "10.48322/e0dc-0h53")
        %test:assertEquals("true", "true", "true")
    %test:arg("dois", "bad")
        %test:assertEquals("false")
function hdpspase:isValidDoi(
    $dois as xs:string*)
as xs:boolean*
{
    for $doi in $dois
    return
        matches($doi, $hdpspase:validDoiPattern)
};


(:~
 : Gets the basic DOI value (without the landing page prefix) for the 
 : given values.  The given values may already be basic DOI values or
 : they may contain the landing page prefix.
 : 
 : @param values values with or without landing page URL prefix.
 : @return basic DOI values for given values.
 :)
declare
    %test:arg("values")
        %test:assertEmpty
    %test:arg("values", "https://doi.org/10.48322/e0dc-0h53", 
                        "10.48322/e0dc-0h53")
        %test:assertEquals("10.48322/e0dc-0h53", 
                           "10.48322/e0dc-0h53")
function hdpspase:getDoi(
    $values as xs:string*)
as xs:string*
{
    for $value in $values
    return
        replace($value, "https://doi.org/", "")
};



(:~
 : Gets the canonical DOI values of the given DOI values.  That is,
 : the values that are lower case and without any "https://doi.org/"
 : prefix.
 :
 : @param values DOI values to convert.
 : @return canonical DOI values.
 :)
declare
    %test:arg("values", "https://doi.org/10.48322/e0dc-0h53", 
                        "10.48322/E0DC-0H53",
                        "10.48322/e0dc-0h53")
        %test:assertEquals("10.48322/e0dc-0h53", 
                           "10.48322/e0dc-0h53",
                           "10.48322/e0dc-0h53")
function hdpspase:getCanonicalDoi(
    $values as xs:string*)
as xs:string*
{
    for $value in $values
    return
        lower-case(replace($value, "https://doi.org/", ""))
};


(:~
 : Gets the DOI landing page URL(s) for the given DOI values.  The given DOI
 : values may or may already be URLs.
 : 
 : @param values DOI values with or without landing page URL prefix.
 : @return DOI URL values for given values.
 :)
declare
    %test:arg("values")
        %test:assertEmpty
    %test:arg("values", "10.48322/e0dc-0h53", "https://doi.org/10.48322/e0dc-0h53")
        %test:assertEquals("https://doi.org/10.48322/e0dc-0h53", 
                            "https://doi.org/10.48322/e0dc-0h53")
function hdpspase:getDoiUrl(
    $values as xs:string*)
as xs:string*
{
    for $value in $values
    return
        if (starts-with($value, "https://doi.org/"))
        then $value
        else "https://doi.org/" || $value
};


(:~
 : Determines if the given values consist solely of word characters
 : (lower/upper case ascii, underscore, and digit characters).
 :
 : @param values string values that are to be tested.
 : @return sequence of boolean values indicating whether each input
 :     value consists solely of word characters.
 :)
declare
    %test:arg("values", "abc")
    %test:assertTrue
    %test:arg("values", "$bc")
    %test:assertFalse
function hdpspase:isWord(
    $values as xs:string*)
as xs:boolean*
{
    for $value in $values
    return
        matches($value, "^[a-zA-Z_0-9]+$")
};


(:~
 : Gets the basic naming authority from a SPASE ResourceID.
 : 
 : @param values ResourceID values.
 : @return naming authority values for given ResourceID values.
 :)
declare
    %test:arg("values")
        %test:assertEmpty
    %test:arg("values", "spase://NA/a/b/c",
                        "spase://CCMC/Repository/metadata",
                        "spase://NASA/NumericalData/SOHO/CELIAS/PM/CDF/PT30S")
        %test:assertEquals("NA", "CCMC", "NASA")
function hdpspase:getNamingAuthority(
    $values as xs:string*)
as xs:string*
{
    for $value in $values
    return
        analyze-string($value, 'spase://([A-Z]*)/.*')//fn:group[@nr = 1]/text()
};



