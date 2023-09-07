float massCoordy,
      massCoordx,
      massVirtualx,
      massVirtualy,
      massRadius,
      pivotCoordx,
      pivotCoordy,
      pivotRadius;

float energyKinetic,
      energyPotential,
      energyMeccanic;

color massColor,
      pivotColor,
      springColor,
      backgroundColor,
      textColor,
      forceColor1,
      forceColor2,
      forceColor3;
int   backgroundFading;

float springLength,
      springLengthVelocity,
      springLengthAcceleration,
      springAngle,
      springAngleVelocity,
      springAngleAcceleration;

float gravityConstant,
      springConstant,
      springLengthRest,
      springLengthEquilibrium,
      massConstant,
      frictionLengthConstant,
      frictionAngleConstant,
      timeConstant,
      zoomFactor;

PGraphics screen;
PrintWriter logFile;
PFont textFont;

int update,
    pause,
    screenshotIndex,
    logBegin,
    displayForces;

String modeCurrent;

void setup(){
  gravityConstant      = 981;
  massConstant         = 60 * 1e-3;
  springConstant       = 40;
  springLengthRest     = 55.5;
  frictionLengthConstant
                       = 1;
  frictionAngleConstant
                       = .05;
  zoomFactor           = 10;
  
  timeConstant         = 1e-5;
  
  springLengthEquilibrium
                       = springLengthRest + (gravityConstant * massConstant) / springConstant;
  
  backgroundFading     = 255;
 
  applyPalette("EFFSANDZEROS");
  
  pivotCoordx          = width / 2;
  pivotCoordy          = height / 4;
  pivotRadius          = 20;
  
  resetPositionTo("EQUILIBRIUM");
  logBegin = 0;
  
  energyKinetic        = 0;
  energyPotential      = 0;
  energyMeccanic       = 0;
  
  modeCurrent = "ELASTIC";
  
  massRadius           = 10;
  
  size(640, 640);
  background(backgroundColor);
  
  screen = createGraphics(width, height);
  logFile = createWriter("pendulumData.csv");
  logFile.println("Tempo,Angolo,Velocità angolare,Accelerazione angolare,Lunghezza,Velocità di allungamento,Accelerazione di allungamento");
  
  update              = 1;
  pause               = 0;
  screenshotIndex     = 1;
  logBegin            = 0;
  displayForces       = 0;
}

void draw(){  
  if(update == 1){
    updateEnergy();
    
    for(int i = 0; i < (int)((1 / timeConstant) / frameRate); i++){  
      if(springLength < springLengthRest){
        if(modeCurrent != "FREEFALL")
          modeCurrent = "FREEFALL";
      } else
        if(modeCurrent != "ELASTIC")
          modeCurrent = "ELASTIC";
      updateDynamics();
    }
  }
  
  drawPendulum();
  if(logBegin == 1)
    printInfo();
}

void keyPressed(){
  switch(key){
    // Termino
    case 'q' :
    case 'Q' :
      exit();
      logFile.flush();
      logFile.close();
      break;
    
    // Imposto la posizione del centro di massa a quella del mouse 
    case 'm' :
    case 'M' :
      resetPositionTo("MOUSE");
      updateEnergy();
      logBegin = 1;
      update = 0;
      logFile.close();
      logFile = createWriter("pendulumData.csv");
      logFile.println("Tempo,Angolo,Velocità angolare,Accelerazione angolare,Lunghezza,Velocità di allungamento,Accelerazione di allungamento");
      break;
    
    // Imposto la posizione del centro di massa all'equilibrio
    case 'e' :
    case 'E' :
      resetPositionTo("EQUILIBRIUM");
      updateEnergy();
      logBegin = 0;
      logFile.flush();
      logFile.close();
      update = 0;
      break;
    
    // Fermo la simulazione
    case 'p' :
    case 'P' :
      pause = 1 - pause;
      logBegin = 1 - pause;
      break;
    
    // Aumento il fattore di ingrandimento
    case '+' :
      zoomFactor *= 2;
      break;
    
    // Diminuisco il fattore di ingrandimento
    case '-' :
      zoomFactor /= 2;
      break;
    
    // Applico uno schema di colori nero e bianco
    case 'b' :
      applyPalette("ZEROSANDEFFS");
      break;
    
    // Applico uno schema di colori bianco e nero
    case 'B' :
      applyPalette("EFFSANDZEROS");
      break;
    
    // Applico uno schema di colori chiaro casuale
    case 'r' :
      applyPalette("STRAVAGANZALIGHT");
      break;
    
    // Applico uno schema di colori scuro casuale
    case 'R' :
      applyPalette("STRAVAGANZADARK");
      break;
    
    // Salvo la scena come immagine
    case 's' :
    case 'S' :
      screen.save("pendulumScreenshot" + screenshotIndex + ".png");
      ++screenshotIndex;
      break;
    
    // Mostro o nascondo le forze sulla massa
    case 'h' :
    case 'H' :
        displayForces = 1 - displayForces;
        break;

    default :
      update = 1;
  }
}

void keyReleased(){
  if(update == 0)
    update = 1;
}

void updateEnergy(){
  // Aggiorno l'assetto energetico del sistema
  energyKinetic = 
   .5 * massConstant * sq(springLengthVelocity) + .5 * massConstant * sq(springAngleVelocity * springLength);
  energyPotential =
    massConstant * gravityConstant * (pivotCoordy - massCoordy);
  
  if(modeCurrent == "ELASTIC")
    energyPotential += .5 * springConstant * sq(springLength - springLengthRest);
  
  energyMeccanic =
    energyKinetic + energyPotential;
}

void updateDynamics(){
  if(pause == 1)
    modeCurrent = "NONE";
    
  switch(modeCurrent){
    // In elasticità l'accelerazione radiale è data dalla legge di Hook per le forze elastiche
    case "ELASTIC" : 
      springAngleAcceleration   =
        - (gravityConstant / springLength) * sin(springAngle)
        - (2 / springLength) * springLengthVelocity * springAngleVelocity;
        
      springLengthAcceleration  =
        - (springConstant / massConstant) * (springLength - springLengthRest)
        + gravityConstant * cos(springAngle)
        + springLength * sq(springAngleVelocity);
      
      springLengthEquilibrium   =
        springLengthRest + (gravityConstant * massConstant) / springConstant;
      break;

    // In tensione l'accelerazione radiale è nulla in quanto la lenza è inestensibile
    case "TENSION" : 
      springAngleAcceleration  =
        - (gravityConstant / springLength) * sin(springAngle)
        - (2 / springLength) * springLengthVelocity * springAngleVelocity;
        
      springLengthAcceleration  = 0;
      springLengthVelocity      = 0;
      
      springLengthEquilibrium   =
        springLengthRest + (gravityConstant * massConstant) / springConstant;
      break;
    
    // In caduta libera è presente solo la forza di gravità che punta verso il basso
    case "FREEFALL" :
      springAngleAcceleration  =
        - (gravityConstant / springLength) * sin(springAngle)
        - (2 / springLength) * springLengthVelocity * springAngleVelocity;
      
      springLengthAcceleration  =
        gravityConstant * cos(springAngle)
        + springLength * sq(springAngleVelocity);
      
      springLengthEquilibrium = 0;
    break;
    case "NONE" :
      return;
    default :
      break;
  }
  
  // Aggiungo dei termini dissipativi per le accelerazioni
  springLengthAcceleration -= frictionLengthConstant * springLengthVelocity; 
  springAngleAcceleration  -= frictionAngleConstant  * springAngleVelocity;
  
  springLengthVelocity =
    springLengthVelocity + springLengthAcceleration * timeConstant;
  springAngleVelocity =
    springAngleVelocity + springAngleAcceleration * timeConstant;
  
  // Aggiorno l'angolo della lenza
  springAngle =
    springAngle + springAngleVelocity * timeConstant;
  springLength =
    springLength + springLengthVelocity * timeConstant;
  
  // Aggiorno la posizione del centro di massa
  massCoordx =
    pivotCoordx + springLength * sin(springAngle);
  massCoordy =
    pivotCoordy + springLength * cos(springAngle);
  
  // Aggiorno la posizione del centro di massa relativa alla finestra  
  if(massVirtualx > width || massVirtualy > height || massVirtualx < 0 || massVirtualy < 0)
    zoomFactor /= 2;
  
  massVirtualx = (massCoordx - pivotCoordx) * zoomFactor + pivotCoordx;
  massVirtualy = (massCoordy - pivotCoordy) * zoomFactor + pivotCoordy;
}

void resetPositionTo(String string){
  switch(string){
    case "MOUSE" :
      massCoordx = min((mouseX - pivotCoordx) / zoomFactor + pivotCoordx, width);
      massCoordy = (mouseY - pivotCoordy) / zoomFactor + pivotCoordy;
      
      break;
    case "EQUILIBRIUM" :
      massCoordx = pivotCoordx;
      massCoordy = pivotCoordy + springLengthEquilibrium;
      
      break;
  }
      
  springLength =
    sqrt(sq(pivotCoordx - massCoordx) + sq(pivotCoordy - massCoordy));
  springLengthVelocity = 0;
  springLengthAcceleration = 0;
  
  springAngle = atan2(massCoordx - pivotCoordx, massCoordy - pivotCoordy);
  springAngleVelocity = 0;
  springAngleAcceleration = 0;
  
  massCoordx =
    pivotCoordx + springLength * sin(springAngle);
  massCoordy =
    pivotCoordy + springLength * cos(springAngle);
}

void drawPendulum(){
  // Disegno lo sfondo
  screen.beginDraw();
  screen.fill(backgroundColor, backgroundFading);
  screen.stroke(backgroundColor, 255);
  screen.rect(0, 0, width, height);
  
  // Disegno la lenza
  screen.stroke(springColor, 255);
  screen.strokeWeight(massRadius / 10);
  screen.fill(springColor, 255);
  screen.line(pivotCoordx, pivotCoordy, massVirtualx, massVirtualy);
  
  // Disegno un arco con raggio pari alla lunghezza di riposo della lenza
  screen.stroke(springColor, 255);
  screen.fill(springColor, 0);
  screen.strokeWeight(massRadius / 10);
  screen.arc(pivotCoordx, pivotCoordy, 2 * springLengthRest * zoomFactor, 2 * springLengthRest * zoomFactor, - TAU, - PI);
  
  // Disegno la massa
  screen.stroke(springColor, 0);
  screen.fill(massColor, 255);
  screen.circle(massVirtualx, massVirtualy, massRadius);
  
  // Disegno il pivot
  screen.stroke(springColor, 255);
  screen.fill(pivotColor, 255);
  screen.circle(pivotCoordx, pivotCoordy, pivotRadius);
  
  if(displayForces == 1){
      screen.strokeWeight(massRadius / 5);
      
      // Disegno il vettore della forza di gravità
      screen.stroke(forceColor1);
      screen.line(massVirtualx, massVirtualy,
        massVirtualx, massVirtualy + zoomFactor * massConstant * gravityConstant
      );
     
      // Disegno il vettore della tensione (se presente) 
      if((modeCurrent == "NONE" && springLength >= springLengthRest) || (modeCurrent != "FREEFALL" && modeCurrent != "NONE")){
        screen.stroke(forceColor2);
        screen.line(massVirtualx, massVirtualy,
          massVirtualx - zoomFactor / springLength * springConstant * (massCoordx - pivotCoordx), massVirtualy - zoomFactor / springLength * springConstant * (massCoordy - pivotCoordy)
        );
      }

      // Disegno il vettore della forza dissipante
      screen.stroke(forceColor3);
      screen.line(massVirtualx, massVirtualy,
        massVirtualx - zoomFactor * frictionAngleConstant * springAngleVelocity * cos(springAngle) - zoomFactor * frictionLengthConstant * springLengthVelocity * sin(springAngle),
        massVirtualy + zoomFactor * frictionAngleConstant * springAngleVelocity * sin(springAngle) - zoomFactor * frictionLengthConstant * springLengthVelocity * cos(springAngle)
      );
  }
  
  screen.endDraw();
  
  image(screen, 0, 0);
}

void printInfo(){
  // Scrivo su file i parametri variabili del sistema
  logFile.println(
    millis() + "," +
    degrees(springAngle) + "," +
    degrees(springAngleVelocity) + "," +
    degrees(springAngleAcceleration) + "," +
    springLength + "," +
    springLengthVelocity + "," +
    springLengthAcceleration + "," +
    (energyKinetic * 1e-4) + "," + 
    (energyPotential * 1e-4)
  );
}

void applyPalette(String paletteName){
  switch(paletteName){
    case "STRAVAGANZALIGHT" :
      springColor          = randomColorLuminance(127);
      pivotColor           = randomColorLuminance(15);
      massColor            = randomColorLuminance(255);
      backgroundColor      = randomColorLuminance(31);
      textColor            = randomColorLuminance(255);
      forceColor1          = randomColorLuminance(63);
      forceColor2          = randomColorLuminance(63);
      forceColor3          = randomColorLuminance(63);

      break;
    case "STRAVAGANZADARK" :
      springColor          = randomColorLuminance(31);
      pivotColor           = randomColorLuminance(255);
      massColor            = randomColorLuminance(15);
      backgroundColor      = randomColorLuminance(127);
      textColor            = randomColorLuminance(15);
      forceColor1          = randomColorLuminance(63);
      forceColor2          = randomColorLuminance(63);
      forceColor3          = randomColorLuminance(63);      

      break;
    case "EFFSANDZEROS" :
      springColor          = 127;
      pivotColor           = 255;
      massColor            = 0;
      backgroundColor      = 255;
      textColor            = 0;
      forceColor1          = 63;
      forceColor2          = 63;
      forceColor3          = 63;  
    
      break;
    case "ZEROSANDEFFS" :
    default :  
      springColor          = 127;
      pivotColor           = 0;
      massColor            = 255;
      backgroundColor      = 0;
      textColor            = 255;
      forceColor1          = 63;  
      forceColor2          = 63;  
      forceColor3          = 63;  

        
      break;
  }
}

color randomColorLuminance(int luminance){
  int red = (int) random(0, 255), green = (int) random(0, 255), blue = (int) random(0, 255);
  int average = (red + green + blue) / 3;
  
  red   = min((red   * luminance) / average, 255);
  green = min((green * luminance) / average, 255);
  blue  = min((blue  * luminance) / average, 255);
  
  return(color(red, green, blue));
}
