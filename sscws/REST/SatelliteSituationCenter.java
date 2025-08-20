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
 * Copyright (c) 2012-2023 United States Government as represented by 
 * the National Aeronautics and Space Administration. No copyright is 
 * claimed in the United States under Title 17, U.S.Code. All Other 
 * Rights Reserved.
 *
 */

package gov.nasa.gsfc.spdf.ssc.test.conjunction;

import java.io.OutputStream;
import java.net.SocketException;
import java.util.List;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.Marshaller;
import jakarta.xml.bind.Unmarshaller;

import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.XMLGregorianCalendar;

import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.client.Invocation;
import jakarta.ws.rs.client.Invocation.Builder;
import jakarta.ws.rs.client.WebTarget;

import org.w3._1999.xhtml.Html;

import gov.nasa.gsfc.sscweb.schema.*;



/**
 * This class provides a client interface to NASA's 
 * <a href="https://sscweb.gsfc.nasa.gov/">Satellite Situation 
 * Center</a>(SSC).  It utilizes the JAX-RS 2.x client API 
 * to access the 
 * <a href="https://sscweb.gsfc.nasa.gov/WebServices/REST">SSC RESTful 
 * Web Services</a>.
 *
 * @author B. Harris
 */
public class SatelliteSituationCenter {

    /**
     * JAX-RS client.
     */
    private Client client = ClientBuilder.newClient();

    /**
     * HTTP user-agent value.
     */
    private static final String USER_AGENT = "ConjunctionExample";

    /**
     * JAXB context for SSC XML data.
     */
    private JAXBContext sscJaxbContext =
        JAXBContext.newInstance("gov.nasa.gsfc.sscweb.schema");

    /**
     * JAXB context for XHTML data.
     */
    private JAXBContext xhtmlJaxbContext =
        JAXBContext.newInstance("org.w3._1999.xhtml");

    /**
     * Factory that creates new <code>javax.xml.datatype</code> 
     * Objects that map XML to/from Java Objects.
     */
    private DatatypeFactory datatypeFactory = null;

    /**
     * Factory that creates new <code>gov.nasa.gsfc.sscweb.schema</code>
     * objects.
     */
    private ObjectFactory sscFactory = new ObjectFactory();

    /**
     * Endpoint address of SSC REST web service.
     */
    private String endpoint = "https://sscweb.gsfc.nasa.gov/WS/sscr/2";


    public SatelliteSituationCenter(String endpoint)
        throws JAXBException {

        this.endpoint = endpoint;

        try {

            datatypeFactory = DatatypeFactory.newInstance();
        }
        catch (DatatypeConfigurationException e) {

            System.err.println(
                "DatatypeFactory.newInstance failed with exception: " +
                e.getMessage());
        }

    }


    public ObjectFactory getObjectFactory() {

        return sscFactory;
    }


    public List<ObservatoryDescription> getObservatories()
        throws SocketException {

        String url = endpoint + "/observatories/";

        WebTarget ssc = client.target(url);
        Invocation.Builder request = 
            ssc.request(MediaType.APPLICATION_XML);
        Invocation invocation = 
            request.header("User-Agent", USER_AGENT).buildGet();

        ObservatoryResponse response =
            invocation.invoke(ObservatoryResponse.class);

        return response.getObservatory();
    }


    public List<GroundStation> getGroundStations() {

        String url = endpoint + "/groundStations/";

        WebTarget ssc = client.target(url);
        Invocation.Builder request = 
            ssc.request(MediaType.APPLICATION_XML);
        Invocation invocation = 
            request.header("User-Agent", USER_AGENT).buildGet();

        GroundStationResponse response =
            invocation.invoke(GroundStationResponse.class);

        return response.getGroundStation();
    }



    public QueryResult getConjunctions(
        QueryRequest queryRequest) {

try {

    marshal(System.out, queryRequest);
}
catch (JAXBException e) {

    System.err.println("getConjunctions: JAXBException: " +
        e.getMessage());

    return null;
}

        String url = endpoint + "/conjunctions/";

        WebTarget ssc = client.target(url);

        Entity<QueryRequest> queryRequestEntity =
            Entity.entity(queryRequest, MediaType.APPLICATION_XML);

        Invocation.Builder request = 
            ssc.request(MediaType.APPLICATION_XML);

        Invocation invocation = 
            request.header("User-Agent", USER_AGENT).
                buildPost(queryRequestEntity);

        QueryResponse response =
            invocation.invoke(QueryResponse.class);

try {

    marshal(System.out, response);
}
catch (JAXBException e) {

    System.err.println("getConjunctions: JAXBException: " +
        e.getMessage());

    return null;
}

        return response.getQueryResult();
    }



    private void marshal(OutputStream out, Object value)
        throws JAXBException {

        Marshaller marshaller = null;

        if (value instanceof ObservatoryResponse ||
            value instanceof GroundStationResponse ||
            value instanceof QueryResponse ||
            value instanceof QueryRequest) {

            marshaller = sscJaxbContext.createMarshaller();
        }
        else if (value instanceof org.w3._1999.xhtml.Html) {

            marshaller = xhtmlJaxbContext.createMarshaller();
        }
        else {

            System.err.println("Don't know how to marshall " +
                value.getClass().getName());
        }
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT,
                               Boolean.TRUE);

        marshaller.marshal(value, out);
    }


    public static void main(String[] args) 
        throws Exception {

        String endpoint = "https://sscweb.gsfc.nasa.gov/WS/sscr/2";

        if (args.length == 1) {

            endpoint = args[0];
        }

        SatelliteSituationCenter ssc = 
            new SatelliteSituationCenter(endpoint);

        List<ObservatoryDescription> observatories = 
            ssc.getObservatories();

        List<GroundStation> groundStations = 
            ssc.getGroundStations();

        QueryRequest testRequest = getTestQueryRequest(ssc);

        QueryResult conjunctions = ssc.getConjunctions(testRequest);
    }


    private static QueryRequest getTestQueryRequest(
        SatelliteSituationCenter ssc) {

        QueryRequestType conjunctionRequest =
            ssc.getObjectFactory().createQueryRequestType();

        ExecuteOptions executeOptions =
            ssc.getObjectFactory().createExecuteOptions();
        executeOptions.setWaitForResult(true);

        conjunctionRequest.setExecuteOptions(executeOptions);

        ResultOptions resultOptions =
            ssc.getObjectFactory().createResultOptions();
        resultOptions.setIncludeQueryInResult(false);
        resultOptions.setQueryResultType(QueryResultType.XML);
        resultOptions.setTraceCoordinateSystem(
            TraceCoordinateSystem.GEO);
        resultOptions.setSubSatelliteCoordinateSystem(
            CoordinateSystem.GEO);
        resultOptions.setSubSatelliteCoordinateSystemType(
            CoordinateSystemType.SPHERICAL);

        conjunctionRequest.setResultOptions(resultOptions);

        conjunctionRequest.setConditionOperator(
            ConditionOperator.ALL);

        DatatypeFactory datatypeFactory = null;
        try {

            datatypeFactory = DatatypeFactory.newInstance();
        }
        catch (DatatypeConfigurationException e) {

            System.err.println(
                "DatatypeFactory.newInstance failed with exception: " +
                e.getMessage());
        }

        XMLGregorianCalendar start = 
            datatypeFactory.newXMLGregorianCalendar(
                2008, 1, 2, 11, 0, 0, 0, 0);
        XMLGregorianCalendar end = 
            datatypeFactory.newXMLGregorianCalendar(
                2008, 1, 2, 11, 59, 59, 0, 0);

        TimeInterval timeInterval =
            ssc.getObjectFactory().createTimeInterval();
        timeInterval.setStart(start);
        timeInterval.setEnd(end);

        conjunctionRequest.setTimeInterval(timeInterval);

        BFieldModel bFieldModel =
            ssc.getObjectFactory().createBFieldModel();
        bFieldModel.setTraceStopAltitude(100);
        bFieldModel.setInternalBFieldModel(
            InternalBFieldModel.IGRF);

        Tsyganenko89CBFieldModel t89c =
            ssc.getObjectFactory().createTsyganenko89CBFieldModel();
        t89c.setKeyParameterValues(Tsyganenko89CKp.KP_3_3_3);

        bFieldModel.setExternalBFieldModel(t89c);

        conjunctionRequest.setBFieldModel(bFieldModel);

        SatelliteCondition satCondition = 
            ssc.getObjectFactory().createSatelliteCondition();
        satCondition.setSatelliteCombination(3);

        String[] ids = {
            "themisa", "themisb", "themisc", "themisd", "themise"
        };

        for (String id : ids) {

            Satellite sat = ssc.getObjectFactory().createSatellite();
            sat.setBFieldTraceDirection(
                BFieldTraceDirection.SAME_HEMISPHERE);
            sat.setId(id);

            satCondition.getSatellite().add(sat);
        }

        LeadSatelliteCondition leadSatelliteCondition =
            ssc.getObjectFactory().createLeadSatelliteCondition();

        Satellite leadSat = ssc.getObjectFactory().createSatellite();
        leadSat.setBFieldTraceDirection(
            BFieldTraceDirection.SAME_HEMISPHERE);
        leadSat.setId(ids[0]);

        leadSatelliteCondition.getSatellite().add(leadSat);

        DistanceConjunctionArea conjunctionArea =
            ssc.getObjectFactory().createDistanceConjunctionArea();
        conjunctionArea.setRadius(400.0);

        leadSatelliteCondition.setConjunctionArea(conjunctionArea);
        leadSatelliteCondition.setTraceType(TraceType.B_FIELD);

/*
        Conditions conditions = 
            ssc.getObjectFactory().createConditions();

        conditions.setSatelliteCondition(satCondition);
        conditions.setLeadSatelliteCondition(leadSatelliteCondition);
        
        conjunctionRequest.setConditions(conditions);
*/
        conjunctionRequest.getConditions().add(satCondition);
        conjunctionRequest.getConditions().add(leadSatelliteCondition);

        QueryRequest queryRequest =
            ssc.getObjectFactory().createQueryRequest();
        queryRequest.setRequest(conjunctionRequest);

        return queryRequest;
    }

}
