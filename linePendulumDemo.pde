float massCoordY,
      massCoordX,
      massCordScreenX,
      massCordScreenY,
      massRadius,
      pivotCoordX,
      pivotCoordY,
      pivotRadius;

float energyKinetic,
      energyPotential,
      energyMeccanic;

color massColor,
      pivotColor,
      lineColor,
      backgroundColor,
      textColor,
      forceColor1,
      forceColor2,
      forceColor3;
int   backgroundFading;

float lineLength,
      lineLengthVelocity,
      lineLengthAcceleration,
      lineAngle,
      lineAngleVelocity,
      lineAngleAcceleration;

float gravityConstant,
      lineElasticConstant,
      lineLengthRest,
      lineLengthEquilibrium,
      massConstant,
      frictionLengthConstant,
      frictionAngleConstant,
      timeSimulationRate,
      zoomFactor;

PGraphics screen;
PrintWriter logFile;
PFont textFont;

int update,
    pauseSimulation,
    screenshotIndex,
    logBegin,
    displayForces;

String dynamicsMode;

void setup(){
  gravityConstant      = 981;
  massConstant         = 60 * 1e-3;
  lineElasticConstant       = 40;
  lineLengthRest     = 55.5;
  frictionLengthConstant
                       = 1;
  frictionAngleConstant
                       = .05;
  zoomFactor           = 10;
  
  timeSimulationRate         = 1e-5;
  
  lineLengthEquilibrium
                       = lineLengthRest + (gravityConstant * massConstant) / lineElasticConstant;
  
  backgroundFading     = 255;
 
  applyPalette("EFFSANDZEROS");
  
  pivotCoordX          = width / 2;
  pivotCoordY          = height / 4;
  pivotRadius          = 20;
  
  resetPositionTo("EQUILIBRIUM");
  logBegin = 0;
  
  energyKinetic        = 0;
  energyPotential      = 0;
  energyMeccanic       = 0;
  
  dynamicsMode = "ELASTIC";
  
  massRadius           = 10;
  
  size(640, 640);
  background(backgroundColor);
  
  screen = createGraphics(width, height);
  logFile = createWriter("pendulumData.csv");
  logFile.println("Tempo,Angolo,Velocità angolare,Accelerazione angolare,Lunghezza,Velocità di allungamento,Accelerazione di allungamento");
  
  update              = 1;
  pauseSimulation               = 0;
  screenshotIndex     = 1;
  logBegin            = 0;
  displayForces       = 0;
}

void draw(){  
  if(update == 1){
    updateEnergy();
    
    for(int i = 0; i < (int)((1 / timeSimulationRate) / frameRate); i++){  
      if(lineLength < lineLengthRest){
        if(dynamicsMode != "FREEFALL")
          dynamicsMode = "FREEFALL";
      } else
        if(dynamicsMode != "ELASTIC")
          dynamicsMode = "ELASTIC";
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
      pauseSimulation = 1 - pauseSimulation;
      logBegin = 1 - pauseSimulation;
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
   .5 * massConstant * sq(lineLengthVelocity) + .5 * massConstant * sq(lineAngleVelocity * lineLength);
  energyPotential =
    massConstant * gravityConstant * (pivotCoordY - massCoordY);
  
  if(dynamicsMode == "ELASTIC")
    energyPotential += .5 * lineElasticConstant * sq(lineLength - lineLengthRest);
  
  energyMeccanic =
    energyKinetic + energyPotential;
}

void updateDynamics(){
  if(pauseSimulation == 1)
    dynamicsMode = "NONE";
    
  switch(dynamicsMode){
    // In elasticità l'accelerazione radiale è data dalla legge di Hook per le forze elastiche
    case "ELASTIC" : 
      lineAngleAcceleration   =
        - (gravityConstant / lineLength) * sin(lineAngle)
        - (2 / lineLength) * lineLengthVelocity * lineAngleVelocity;
        
      lineLengthAcceleration  =
        - (lineElasticConstant / massConstant) * (lineLength - lineLengthRest)
        + gravityConstant * cos(lineAngle)
        + lineLength * sq(lineAngleVelocity);
      
      lineLengthEquilibrium   =
        lineLengthRest + (gravityConstant * massConstant) / lineElasticConstant;
      break;

    // In tensione l'accelerazione radiale è nulla in quanto la lenza è inestensibile
    case "TENSION" : 
      lineAngleAcceleration  =
        - (gravityConstant / lineLength) * sin(lineAngle)
        - (2 / lineLength) * lineLengthVelocity * lineAngleVelocity;
        
      lineLengthAcceleration  = 0;
      lineLengthVelocity      = 0;
      
      lineLengthEquilibrium   =
        lineLengthRest + (gravityConstant * massConstant) / lineElasticConstant;
      break;
    
    // In caduta libera è presente solo la forza di gravità che punta verso il basso
    case "FREEFALL" :
      lineAngleAcceleration  =
        - (gravityConstant / lineLength) * sin(lineAngle)
        - (2 / lineLength) * lineLengthVelocity * lineAngleVelocity;
      
      lineLengthAcceleration  =
        gravityConstant * cos(lineAngle)
        + lineLength * sq(lineAngleVelocity);
      
      lineLengthEquilibrium = 0;
    break;
    case "NONE" :
      return;
    default :
      break;
  }
  
  // Aggiungo dei termini dissipativi per le accelerazioni
  lineLengthAcceleration -= frictionLengthConstant * lineLengthVelocity; 
  lineAngleAcceleration  -= frictionAngleConstant  * lineAngleVelocity;
  
  lineLengthVelocity =
    lineLengthVelocity + lineLengthAcceleration * timeSimulationRate;
  lineAngleVelocity =
    lineAngleVelocity + lineAngleAcceleration * timeSimulationRate;
  
  // Aggiorno l'angolo della lenza
  lineAngle =
    lineAngle + lineAngleVelocity * timeSimulationRate;
  lineLength =
    lineLength + lineLengthVelocity * timeSimulationRate;
  
  // Aggiorno la posizione del centro di massa
  massCoordX =
    pivotCoordX + lineLength * sin(lineAngle);
  massCoordY =
    pivotCoordY + lineLength * cos(lineAngle);
  
  // Aggiorno la posizione del centro di massa relativa alla finestra  
  if(massCordScreenX > width || massCordScreenY > height || massCordScreenX < 0 || massCordScreenY < 0)
    zoomFactor /= 2;
  
  massCordScreenX = (massCoordX - pivotCoordX) * zoomFactor + pivotCoordX;
  massCordScreenY = (massCoordY - pivotCoordY) * zoomFactor + pivotCoordY;
}

void resetPositionTo(String string){
  switch(string){
    case "MOUSE" :
      massCoordX = min((mouseX - pivotCoordX) / zoomFactor + pivotCoordX, width);
      massCoordY = (mouseY - pivotCoordY) / zoomFactor + pivotCoordY;
      
      break;
    case "EQUILIBRIUM" :
      massCoordX = pivotCoordX;
      massCoordY = pivotCoordY + lineLengthEquilibrium;
      
      break;
  }
      
  lineLength =
    sqrt(sq(pivotCoordX - massCoordX) + sq(pivotCoordY - massCoordY));
  lineLengthVelocity = 0;
  lineLengthAcceleration = 0;
  
  lineAngle = atan2(massCoordX - pivotCoordX, massCoordY - pivotCoordY);
  lineAngleVelocity = 0;
  lineAngleAcceleration = 0;
  
  massCoordX =
    pivotCoordX + lineLength * sin(lineAngle);
  massCoordY =
    pivotCoordY + lineLength * cos(lineAngle);
}

void drawPendulum(){
  // Disegno lo sfondo
  screen.beginDraw();
  screen.fill(backgroundColor, backgroundFading);
  screen.stroke(backgroundColor, 255);
  screen.rect(0, 0, width, height);
  
  // Disegno la lenza
  screen.stroke(lineColor, 255);
  screen.strokeWeight(massRadius / 10);
  screen.fill(lineColor, 255);
  screen.line(pivotCoordX, pivotCoordY, massCordScreenX, massCordScreenY);
  
  // Disegno un arco con raggio pari alla lunghezza di riposo della lenza
  screen.stroke(lineColor, 255);
  screen.fill(lineColor, 0);
  screen.strokeWeight(massRadius / 10);
  screen.arc(pivotCoordX, pivotCoordY, 2 * lineLengthRest * zoomFactor, 2 * lineLengthRest * zoomFactor, - TAU, - PI);
  
  // Disegno la massa
  screen.stroke(lineColor, 0);
  screen.fill(massColor, 255);
  screen.circle(massCordScreenX, massCordScreenY, massRadius);
  
  // Disegno il pivot
  screen.stroke(lineColor, 255);
  screen.fill(pivotColor, 255);
  screen.circle(pivotCoordX, pivotCoordY, pivotRadius);
  
  if(displayForces == 1){
      screen.strokeWeight(massRadius / 5);
      
      // Disegno il vettore della forza di gravità
      screen.stroke(forceColor1);
      screen.line(massCordScreenX, massCordScreenY,
        massCordScreenX, massCordScreenY + zoomFactor * massConstant * gravityConstant
      );
     
      // Disegno il vettore della tensione (se presente) 
      if((dynamicsMode == "NONE" && lineLength >= lineLengthRest) || (dynamicsMode != "FREEFALL" && dynamicsMode != "NONE")){
        screen.stroke(forceColor2);
        screen.line(massCordScreenX, massCordScreenY,
          massCordScreenX - zoomFactor / lineLength * lineElasticConstant * (massCoordX - pivotCoordX), massCordScreenY - zoomFactor / lineLength * lineElasticConstant * (massCoordY - pivotCoordY)
        );
      }

      // Disegno il vettore della forza dissipante
      screen.stroke(forceColor3);
      screen.line(massCordScreenX, massCordScreenY,
        massCordScreenX - zoomFactor * frictionAngleConstant * lineAngleVelocity * cos(lineAngle) - zoomFactor * frictionLengthConstant * lineLengthVelocity * sin(lineAngle),
        massCordScreenY + zoomFactor * frictionAngleConstant * lineAngleVelocity * sin(lineAngle) - zoomFactor * frictionLengthConstant * lineLengthVelocity * cos(lineAngle)
      );
  }
  
  screen.endDraw();
  
  image(screen, 0, 0);
}

void printInfo(){
  // Scrivo su file i parametri variabili del sistema
  logFile.println(
    millis() + "," +
    degrees(lineAngle) + "," +
    degrees(lineAngleVelocity) + "," +
    degrees(lineAngleAcceleration) + "," +
    lineLength + "," +
    lineLengthVelocity + "," +
    lineLengthAcceleration
  );
}

void applyPalette(String paletteName){
  switch(paletteName){
    case "STRAVAGANZALIGHT" :
      lineColor          = randomColorLuminance(127);
      pivotColor           = randomColorLuminance(15);
      massColor            = randomColorLuminance(255);
      backgroundColor      = randomColorLuminance(31);
      textColor            = randomColorLuminance(255);
      forceColor1          = randomColorLuminance(63);
      forceColor2          = randomColorLuminance(63);
      forceColor3          = randomColorLuminance(63);

      break;
    case "STRAVAGANZADARK" :
      lineColor          = randomColorLuminance(31);
      pivotColor           = randomColorLuminance(255);
      massColor            = randomColorLuminance(15);
      backgroundColor      = randomColorLuminance(127);
      textColor            = randomColorLuminance(15);
      forceColor1          = randomColorLuminance(63);
      forceColor2          = randomColorLuminance(63);
      forceColor3          = randomColorLuminance(63);      

      break;
    case "EFFSANDZEROS" :
      lineColor          = 127;
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
      lineColor          = 127;
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
