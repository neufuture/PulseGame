#include "Node.cpp"
#include "Pulse.cpp"
#include "Zone.cpp"

#define numStrands 5
#define numNodes   50
#define numZones   15
#define numPulses  100
#define numPads    10

Zone zones[numZones];
Pulse pulses[numPulses];
Node nodes[numStrands][numNodes];
bool strandActive[5];

// Zone switch variables
int zoneTime;
int zoneSwitchTime;

// scoring
int scoreA = 0;
int scoreB = 0;

// pulses
int power[numPads]; 
int powerDrain = 128;
int boost = 2;
int zonePoints = 10;
int fade = 1;

#define blue 170
#define purple 212



// Defining pins for input pads
int padPins[] = {
  0,1,2,3,4,5,6,7,8,9
};


void setup(){
  Serial.begin(57600);
  Serial.println("setup begin");
  

  // initalize pulses
  for (int i=0; i<numPulses; i++) {
    pulses[i] = Pulse();
  }
  
 
  for (int i=0; i<numStrands; i++) {
    // Setup Zones
    for (int j=0; j<3; j++) {
      zones[i*3+j] = Zone(); //start, end, strand
      zones[i*3+j].setZone(j*10+10, i, i*3+j);
    }
  }
  
  
  // initalize Power
  for (int i=0; i<numPads; i++) {
    power[i] = 1;
  }

Serial.println("setup complete");

}


/////////// MAIN LOOP /////////// 
void loop() {
  
/*
  // Create fading tail for pulse
  for (int i=0; i<numStrands; i++) {
    for (int j=0; j<50; j++) {
       if (nodes[i][j].b>fade) nodes[i][j].b -= fade;
    }
  }


  // Run the zones
  for (int i=0; i<numZones; i++) {
    runZone(i);
  }



  // Timer for switching zones
  if (millis() - zoneSwitchTime > zoneTime) {
    zoneTime =  int(random(500, 1500));
    zoneSwitchTime = millis();
    startZone((int) random(numZones));
  }

  // Determins the power for each player
  for (int i=0; i<numStrands; i++) {
    setHSB(i, 1,255,0, power[i]);
    setHSB(i,49,255,0, power[i+5]);
    if (power[i]  <255) power[i]   += boost;
    if (power[i+5]<255) power[i+5] += boost;
  }

  // collision testing
  checkCollide();

  // incrament pulses and remove when at the end
  for (int i = 0; i < numPulses; i++) { 
    if (pulses[i].active) {
      incrementPulse(i);
    }
  }

  for (int i=0; i<numStrands; i++) {
    for (int j=0; j<numNodes; j++) {

      Serial.print(nodes[i][j].b);
      Serial.print("\t");
    }
    Serial.println();
  }
  Serial.println();
*/

}


/////////// Collisions /////////// 
void checkCollide() {

  // iterate through all active pulses
  for (int i = 0; i< numPulses; i++) { 
    if (pulses[i].active) {

      // check for pulse on pulse action
      for (int j = i+1; j < numPulses; j++) { 
        if (pulses[j].active) {      
          if (pulses[i].strandId == pulses[j].strandId &&
            pulses[i].direction != pulses[j].direction &&
            (pulses[i].loc == pulses[j].loc ||  pulses[i].loc == pulses[j].loc+1)) {

            nodes[pulses[i].strandId][pulses[i].loc].b = 0;
            if ( pulses[i].loc == pulses[j].loc+1) {
              nodes[pulses[i].strandId][pulses[i].loc].b = 0;
            }
            pulses[i].active = false;
            pulses[j].active = false;
            Serial.println("Pulse collision!!!");
          }
        }
      }


      // Check collision with zones
      for (int j =0; j<numZones; j++) {
        if (zones[j].active && pulses[i].strandId == zones[j].strandId) {
          if (pulses[i].direction == 1) { //  pulses going right
            if (pulses[i].loc == zones[j].start) {
              scoreA+= zonePoints;
              pulses[i].active = false;
              Serial.println("Zone collision (A)!!!");
              break;
            }
          }
          else {                      // pulses going left
            if (pulses[i].loc == zones[j].end) {
              scoreB+=zonePoints;
              pulses[i].active = false;
              Serial.println("Zone collision (B) !!!");
              break;
            }
          }
        }
      }
    }
  }
}





/////////// Pulses   /////////
void incrementPulse(int id) {
  if (millis() - pulses[id].lastTime > pulses[id].speed) {
    pulses[id].loc += pulses[id].direction;

    if (pulses[id].direction == -1 && pulses[id].loc <= 2) {
      if (scoreA>0) scoreA--;
      pulses[id].active = false;
    }
    else if (pulses[id].direction == 1 && pulses[id].loc >= 48) {
      if (scoreB>0) scoreB--;
      pulses[id].active=false;
    }

    if (pulses[id].direction==1) setHSB(pulses[id].strandId, pulses[id].loc ,purple, 255,255);
    else setHSB(pulses[id].strandId, pulses[id].loc ,blue, 255,255);      

    pulses[id].lastTime = millis();
  }
  
}



///////// ZONE ///////////

void runZone(int id) {
  if (zones[id].active) {
    for (int i=zones[id].start; i<zones[id].end; i++) {
      setHSB(zones[id].strandId,i,0, 0, 255);
    }
  }

  if (millis()-zones[id].startTime>zones[id].duration) endZone(id);
}

void endZone(int id) {
  if (zones[id].active) { 
    for (int i=zones[id].start; i<zones[id].end; i++) {
      nodes[zones[id].strandId][i].b = 0;
    }
    strandActive[zones[id].strandId] = false;
    zones[id].active = false;
  }
}

void startZone(int id) {
  if (!strandActive[zones[id].strandId]) {
    zones[id].startTime = millis();
    zones[id].duration = (long)random(1000, 2000);
    strandActive[zones[id].strandId] = true;
    zones[id].active = true;
  }
}



/////////// NODES   /////////

void setHSB(int strand, int loc, char h, char s, char b){
  nodes[strand][loc].h = h;
  nodes[strand][loc].s = s;
  nodes[strand][loc].b = b;
}

///////// UTILITIES ///////////


