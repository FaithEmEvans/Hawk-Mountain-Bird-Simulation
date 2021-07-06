# Hawk-Mountain-Bird-Simulation

By: Faith Evans & Dr. Dale Parson
Completed May 2020

Hawk Mountain Sanctuary (Pennsylvania) staff and volunteers create in-depth recordings of raptor sightings that occur at their North Lookout trail. Using data sourced during the years of 2017-2018, this visualizer gives a demo representation of the raptor’s flights.


-	preHawkMigration558Apr19B.pde  	// The main Sketch
-	HawkTrig.pde				// Sketch that contains trig calculations for FlightDir
-	Raptor.pde				// Sketch that contains the Raptor class 
-	Data (folder) 
-	
    o	HMS_F2017_2018_NUMERIC_DECOMMAS.arff
    
    o	HMS_F2017_2018_NUMERIC_DECOMMAS.csv
    
    o	HMS_F2017_2018_NUMERIC_DECOMMAS.csv.bak
    
    o	NorthLookout.jpg
    
    o	accipiter.png
    
    o	eagle.png
    
    o	falcon.png
    
    o	hawk.png
    
    o	unid.png
    
    o	vulture.png


Key ‘S’ = If pressed, the Sketch will skip over the instances without any reported bird instances. 
Key ‘F’ = If pressed, the Sketch will skip to the next frame which contains an instance where the bird count for that hour exceeds 42. 42 was set because it triggers a timeframe on 9/10/17 where there is a high number of birds coming in at once.


Dataset Attributes:

Start 		year, month, day, hour

End 		year, month, day, hour

Duration 	

Observer 	

BV 		Black Vulture

TV		Turkey Vulture

UV 		Unidentified Vulture

MK 		Mississippi Kite

OS		Osprey

BE 		Bald Eagle

NH 		Northern Harrier

SS		Sharp-shinned Hawk

CH		Cooper’s Hawk

NG		Northern Goshawk

UA		Unidentified Accipiter

RS		Red-shouldered Hawk

BW		Broad-winged Hawk

SW		Swainson’s Hawk

RT		Red-tailed Hawk

RL		Rough-legged hawk

UB		Unidentified Buteo

GE		Golden Eagle

UE		Unidentified Eagle

AK		American Kestrel

ML		Merlin

PG		Peregrine Falcon

UF		Unidentified Falcon

UR		Unidentified Raptor 

Total 		The total count of birds seen that day

WindSpd	The speed of the wind nominally 

WindDir	The wind direction nominally (N=0, E=90, S=180, W=270)

Temp		In Celsius 

CloudCover	Unknown measurement units

Visibility	North Lookout visibility

FlightDIR	Bird flight direction nominally (N=0, E=90, S=180, W=270)

FlightHT	Flight height

SkyCode	'0: Clear' '1: Partly Cloudy' '2: Mostly Cloudy' '3: Overcast''4: wind driven sand; snow; dust' '5: Fog or Dense Haze' 6:  Drizzle' '7: Rain' '8.  Snow'

Counter	    Primary bird counter 

Observer1	Additional observer

Observer2	Additional observer

Observer3	Additional observer

Observer4 	Additional observer

HawkYear	The year for that instance



Within these recorded attributes, not all are being used for this visualizer demonstration. The primary attributes being used include: Start, BV-UR, Total, WindSpd, WIndDir, CloudCover, FlightDIR. Potentially the attributes FlightHT, SkyCode and Temp may be included in the visualizer. WindSpd and WindDir will be represented in some fashion, likely using some form of subtle graphic. CloudCover is represented as a white screen over the window with transparency that changes depending on the value, 0-100 (0.0-1.0 in opacity values).

