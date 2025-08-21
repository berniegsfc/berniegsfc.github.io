#!/usr/bin/perl -w

#
# NOSA HEADER START
#
# The contents of this file are subject to the terms of the NASA Open 
# Source Agreement (NOSA), Version 1.3 only (the "Agreement").  You may 
# not use this file except in compliance with the Agreement.
#
# You can obtain a copy of the agreement at
#   docs/NASA_Open_Source_Agreement_1.3.txt
# or 
#   https://sscweb.gsfc.nasa.gov/WebServices/NASA_Open_Source_Agreement_1.3.txt.
#
# See the Agreement for the specific language governing permissions
# and limitations under the Agreement.
#
# When distributing Covered Code, include this NOSA HEADER in each
# file and include the Agreement file at 
# docs/NASA_Open_Source_Agreement_1.3.txt.  If applicable, add the 
# following below this NOSA HEADER, with the fields enclosed by 
# brackets "[]" replaced with your own identifying information: 
# Portions Copyright [yyyy] [name of copyright owner]
#
# NOSA HEADER END
#
# Copyright (c) 2003-2017 United States Government as represented by the 
# National Aeronautics and Space Administration. No copyright is claimed 
# in the United States under Title 17, U.S.Code. All Other Rights Reserved.
#
# $Id$
#

use SOAP::Lite on_action => sub {sprintf '%s/%s', @_};
#use SOAP::Lite on_action => sub {sprintf '%s/%s', @_},
#        'trace', 'debug';

my $ssc = SOAP::Lite
  -> proxy('https://sscweb.gsfc.nasa.gov/WS/ssc/2/SatelliteSituationCenterService?WSDL')
  -> ns('http://ssc.spdf.gsfc.nasa.gov/', 'ans1');


my $agent = 'WsExample.pl ' . $ssc->transport->agent();

$ssc -> transport -> agent($agent);


my $satResult = $ssc -> getAllSatellites();

unless ($satResult -> fault) {

    print "getAllSatellites() returned:\n";

    for my $satellite ($satResult->valueof('//getAllSatellitesResponse/return')) {

      print "  $satellite->{id}  $satellite->{name}  $satellite->{startTime}  $satellite->{endTime}  $satellite->{resolution} \n";
    }
}
else {

    print join ',', $satResult -> faultcode, $satResult -> faultstring;
}


my $statResult = $ssc -> getAllGroundStations();

unless ($statResult -> fault) {

    print "getAllGroundStations() returned:\n";

    for my $station ($statResult->valueof('//getAllGroundStationsResponse/return')) {

      print "  $station->{id}  $station->{name}  $station->{latitude}  $station->{longitude}  \n";
    }
}
else {

    print join ',', $statResult -> faultcode, $statResult -> faultstring;
}


my $dataRequest = 
    SOAP::Data->name('arg0' => \SOAP::Data->value(
        SOAP::Data->name('beginTime' => '2007-06-19T00:00:00.000Z')
                  ->type('xsd:dateTime'),
        SOAP::Data->name('endTime' => '2007-06-19T01:00:00.000Z')
                  ->type('xsd:dateTime'),
        SOAP::Data->name('satellites' => \SOAP::Data->value(
            SOAP::Data->name('id' => 'fast'),
            SOAP::Data->name('resolutionFactor' => '2')
            )
        ),
        SOAP::Data->name('satellites' => \SOAP::Data->value(
            SOAP::Data->name('id' => 'moon'),
            SOAP::Data->name('resolutionFactor' => '2')
            )
        ),
        )
    ) ->attr( { 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                  'xsi:type' => 'ans1:dataRequest' } );

my $dataResult = $ssc -> getData($dataRequest);

unless ($dataResult -> fault) {

    print "getData() returned:\n";

    my $return = $dataResult->valueof('//getDataResponse/return');

    print "statuCode = $return->{statusCode} \n";
    print "statusSubCode = $return->{statusSubCode} \n";
#    print "statusText = $return->{statusText} \n";

    for my $satData ($dataResult->valueof('//getDataResponse/return/data')) {

        print "id = $satData->{'id'}\n";

        my $coords = $satData->{'coordinates'};

        print "coordinateSystem = $coords->{'coordinateSystem'}\n";

        my @xs = @{$coords->{'x'}};
        my @ys = @{$coords->{'y'}};
        my @zs = @{$coords->{'z'}};
        my @times = @{$satData->{'time'}};

        for ($i = 0; $i <= $#xs; $i++) {

            print "  $times[$i] $xs[$i], $ys[$i], $zs[$i]\n";
        }
    }
}
else {

    print join ',', $dataResult -> faultcode, $dataResult -> faultstring;
}

exit 0;
