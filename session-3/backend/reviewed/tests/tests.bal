import ballerina/graphql;
import ballerina/http;
import ballerina/test;

final graphql:Client cl = check new ("http://localhost:9000/reviewed");

@test:Mock {
    functionName: "getGeoClient"
}
function getMockClient() returns http:Client => test:mock(http:Client);

@test:Config
function testRetrievingPlaceIdsAndNames() returns error? {
    json payload = check cl->execute(string `{
        places {
            id
            name
            city
            country
        }
    }`);
    test:assertEquals(payload, {
        "data": {
            "places": [
                {"id": 8000, "name": "Tower Vista", "city": "Colombo", "country": "Sri Lanka"},
                {"id": 8001, "name": "TechTrail", "city": "Miami", "country": "United States"},
                {"id": 8002, "name": "TechTrail", "city": "Miami", "country": "US"}
            ]
        }
    });
}

@test:Config 
function testRetrievingTimeZone() returns error? {
    CityData cityData = {
        total_count: 1,
        results: [{
            population: 450000,
            timezone: "America/New_York"
        }]
    };

    test:prepare(geoClient)
        .when("get")
        .withArguments("/geonames-all-cities-with-a-population-500/records?refine=name:Miami&refine=country:United States")
        .thenReturn(cityData);

    json payload = check cl->execute(string `query QueryPlace($placeId: ID!) {
        place(placeId: $placeId) {
            id
            name
            city
            country
            timezone
        }
    }`, {"placeId": 8001});
    test:assertEquals(payload, {
        "data": {
            "place": {
                "id": 8001,
                "name": "TechTrail",
                "city": "Miami",
                "country": "United States",
                "timezone": "America/New_York"
            }
        }
    });
}
