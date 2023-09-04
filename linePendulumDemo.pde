// Autore
// Lorenzo Casavecchia <lnzcsv@gmail.com>

// Descrizione
// `springyPendulumDemo.pde` consiste in una semplice simulazione di un pendolo
// elastico, cioè una massa soggetta alla forza di gravità vincolata da una molla
// collegata ad essa e ad un pivot
// 
// Ad esecuzione verrà aperta una finestra a schermo intero divisa in 2:
//     - a sinistra è disegnato il sistema in evoluzione
//     - a destra sono riportati i valori dei parametri costanti e variabili nel
//       tempo del sistema
// 
// La simulazione è stata implementata considerando il bilancio delle forze al
// centro di massa, quindi le componenti radiale e tangenziale delle forze
// applicate
// 
// Dal valore della forza è possibile ricavarne l'accelerazione radiale ed angolare
// quindi anche le velocità radiale e angolare (ricordando che l'accelerazione è
// la variazione della velocità nel tempo)
// 
// Similmente vengono calcolati i valori del raggio e l'angolo della molla rispetto
// la verticale (ricordando che la velocità è la variazione della posizione o dell'angolo
// nel tempo)
// 
// Nel caso in cui la distanza superi un valore fisso (`springLengthMaximum`)
// le componenti radiali della velocità e accelerazione verranno annullati,
// di fatto rendendo il sistema un pendolo semplice
// 
// La funzione `setup` viene eseguita una sola volta all'inizio dell'esecuzione ed è
// responsabile di impostare i valori base dei parametri
// La funzione `draw` viene eseguita 60 volte in un secondo ed è responsabile dei calcoli
// e della grafica
// 
// E' importante osservare che la grafica (la visualizzazione del sistema e dei parametri)
// viene gestita prima del calcolo dei parametri
// La funzione `mousePressed` gestisce tutte le interazioni con l'utente attualmente previste
// 
// Premendo i seguenti tasti è possibile modificare la simulazione:
//     - 'q' e 'Q' chiudono la simulazione
//     - 'm' e 'M' muove la massa alla posizione del cursore
//     - 'e' e 'E' muove la massa alla posizione d'equilibrio
//     - 'p' e 'P' mettono in pausa la simulazione
//     - '+' e '-' aumentano e diminuiscono il fattore di ingrandimento
//     del disegno o del testo a seconda della posizione del mouse

float massCoordy,  massCoordx,  massRadius;
float pivotCoordx, pivotCoordy, pivotRadius;

float massVirtualx, massVirtualy;

float energyKinetic, energyPotential, energyMeccanic;

color massColor, pivotColor, springColor;

color backgroundColor, backgroundFading, textColor;

float springLength, springLengthVelocity, springLengthAcceleration;
float springAngle,  springAngleVelocity,  springAngleAcceleration;

float gravityConstant, springConstant, springLengthRest, springLengthEquilibrium, massConstant, frictionConstant, timeConstant, zoomFactor;

float textOffsetx, textOffsety, textPositionx;
PGraphics screen;
PFont textFont;

int update, pause;

String modeCurrent;

void setup(){
  gravityConstant      = 981;
  massConstant         = 60 * 1e-3;
  springConstant       = 60 * 1e4;
  springLengthRest     = 55.5;
  frictionConstant     = 1;
  zoomFactor           = 1;
  
  timeConstant         = 1e-5;
  
  springLengthEquilibrium
                       = springLengthRest + (gravityConstant * massConstant) / springConstant;
  
  applyPalette("ZEROSANDEFFS");
  backgroundFading     = 63;
  
  textOffsetx          = 20;
  textOffsety          = 16;
  
  pivotCoordx          = displayWidth / 4;
  pivotCoordy          = displayHeight / 4;
  pivotRadius          = 20;
  
  resetPositionTo("EQUILIBRIUM");
  
  energyKinetic        = 0;
  energyPotential      = 0;
  energyMeccanic       = 0;
  
  modeCurrent = "ELASTIC";
  
  massRadius           = 20;
  
  textFont = createFont("Tlwg Typo Bold", textOffsety);
  
  fullScreen();
  screen = createGraphics(width, height);
   
  update = 1;
  pause  = 0;
  
  textPositionx = width / 2 + textOffsetx;
  frameRate(59);
  background(backgroundColor);
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
  drawInfo();
}

void keyPressed(){
  switch(key){
    case 'q' :
    case 'Q' :
      exit();
      break;
    case 'm' :
    case 'M' :
      resetPositionTo("MOUSE");
      updateEnergy();
      update = 0;
      break;
    case 'p' :
    case 'P' :
      pause = 1 - pause;
      break;
    case 'e' :
    case 'E' :
      resetPositionTo("EQUILIBRIUM");
      updateEnergy();  
      update = 0;
      break;
    case '+' :
      if(mouseX < width / 2)
        zoomFactor *= 2;
      else
        textOffsety += 2;
      break;
    case '-' :
      if(mouseX < width / 2)
        zoomFactor /= 2;
      else
        textOffsety -= 2;
      break;
    case 'b' :
      applyPalette("ZEROSANDEFFS");
      break;
    case 'B' :
      applyPalette("EFFSANDZEROS");
      break;
    case 'r' :
      applyPalette("STRAVAGANZALIGHT");
      break;
    case 'R' :
      applyPalette("STRAVAGANZADARK");
      break;
    case '0' :
      modeCurrent = "NONE";
      break;
    case '1' :
      modeCurrent = "FREEFALL";
      break;
    case '2' :
      modeCurrent = "ELASTIC";
      break;
    case '3' :
      modeCurrent = "TENSION";
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
  // Calcolo i nuovi valori dell'angolo rispetto la verticale e la lunghezza della molla
  if(pause == 1)
    modeCurrent = "NONE";
    
  switch(modeCurrent){
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
    case "TENSION" : 
      springAngleAcceleration  =
        - (gravityConstant / springLength) * sin(springAngle)
        - (2 / springLength) * springLengthVelocity * springAngleVelocity;
        
      springLengthAcceleration  = 0;
      springLengthVelocity      = 0;
      
      springLengthEquilibrium   =
        springLengthRest + (gravityConstant * massConstant) / springConstant;
      break;
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
  
  springLengthAcceleration  -= frictionConstant * springLengthVelocity; 
  // springAngleAcceleration   -= frictionConstant * springAngleVelocity;
  
  springLengthVelocity      =
    springLengthVelocity + springLengthAcceleration * timeConstant;
  springAngleVelocity       =
    springAngleVelocity + springAngleAcceleration * timeConstant;
  
  springAngle               =
    springAngle + springAngleVelocity * timeConstant;
  springLength              =
    springLength + springLengthVelocity * timeConstant;
  
  // Aggiorno la posizione del centro di massa
  massCoordx =
    pivotCoordx + springLength * sin(springAngle);
  massCoordy =
    pivotCoordy + springLength * cos(springAngle);
    
  massVirtualx = (massCoordx - pivotCoordx) * zoomFactor + pivotCoordx;
  massVirtualy = (massCoordy - pivotCoordy) * zoomFactor + pivotCoordy;
  
  if(massVirtualx > width /2 || massVirtualy > height || massVirtualx < 0 || massVirtualy < 0)
    zoomFactor /= 2;
}

void resetPositionTo(String string){
  switch(string){
    case "MOUSE" :
      massCoordx = min((mouseX - pivotCoordx) / zoomFactor + pivotCoordx, width / 2);
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
  // Disegno la molla, il pivot e la massa
  screen.beginDraw();
  screen.fill(backgroundColor, backgroundFading);
  screen.stroke(backgroundColor, 255);
  screen.rect(0, 0, width / 2, height);
  
  screen.stroke(springColor, 255);
  screen.strokeWeight(massRadius / 10);
  screen.fill(springColor, 255);
  screen.line(pivotCoordx, pivotCoordy, massVirtualx, massVirtualy);
  
  screen.stroke(springColor, 255);
  screen.fill(springColor, 0);
  screen.strokeWeight(massRadius / 10);
  screen.arc(pivotCoordx, pivotCoordy, 2 * springLengthRest * zoomFactor, 2 * springLengthRest * zoomFactor, - TAU, - PI);
  
  screen.stroke(springColor, 0);
  screen.fill(massColor, 255);
  screen.circle(massVirtualx, massVirtualy, massRadius);
  
  screen.stroke(springColor, 255);
  screen.fill(pivotColor, 255);
  screen.circle(pivotCoordx, pivotCoordy, pivotRadius);
  
  screen.endDraw();
  
  image(screen, 0, 0);
}

void drawInfo(){
// Stampo sullo schermo i parametri del sistema
  screen.beginDraw();
  
  screen.textFont(textFont);
  screen.textSize(textOffsety);
  
  screen.fill(backgroundColor, 255);
  screen.stroke(backgroundColor, 255);
  screen.rect(width / 2, 0, width, height);
  
  screen.fill(textColor, 255);
  
  // Stampo sullo schermo i parametri variabili
  textPositionx = width / 2 + textOffsetx;
  screen.text("Angolo [°] = "
    + degrees(springAngle),
    textPositionx, textOffsety);
  screen.text("Velocità angolare [°/s] = "
    + degrees(springAngleVelocity),  
    textPositionx, 2 * textOffsety);
  screen.text("Accelerazione angolare [°/s2] = "
    + degrees(springAngleAcceleration),
    textPositionx, 3 * textOffsety);
  
  screen.text("Raggio [cm] = "
    + springLength,
    textPositionx, 5 * textOffsety);
  screen.text("Velocità radiale [cm/s] = "
    + springLengthVelocity,
    textPositionx, 6 * textOffsety);
  screen.text("Accelerazione radiale [cm/s2] = "
    + springLengthAcceleration,
    textPositionx, 7 * textOffsety);
  
  screen.text("Discostamento orizzontale [cm] = "
    + (massCoordx - pivotCoordx),
    textPositionx, 9 * textOffsety);
  screen.text("Discostamento verticale [cm] = "
    + (massCoordy - pivotCoordy), textPositionx,
    10 * textOffsety);
  
  screen.text("Energia cinetica [J] = "
    + (energyKinetic * 1e-4),
    textPositionx, 12 * textOffsety
  );
  screen.text("Energia potenziale [J] = "
    + (energyPotential * 1e-4),
    textPositionx, 13 * textOffsety
  );
  screen.text("Energia meccanica [J] = "
    + (energyMeccanic * 1e-4),
    textPositionx, 14 * textOffsety
  );
  
  // Stampo sullo schermo i parametri costanti
  screen.text("Accelerazione di gravità [cm/s2] = " + gravityConstant,
    textPositionx, height - 7 * textOffsety);
  screen.text("Lunghezza a riposo [cm] = " + springLengthRest,
    textPositionx, height - 6 * textOffsety);
  screen.text("Costante di elasticità [N/cm] = " + springConstant,
    textPositionx, height - 5 * textOffsety);
  screen.text("Massa [kg] = " + massConstant,
    textPositionx, height - 4 * textOffsety);
  screen.text("Coefficiente di attrito [kg*cm/s] = " + frictionConstant,
    textPositionx, height - 3 * textOffsety);
  screen.text("Velocità di simulazione [s] = " + timeConstant,
    textPositionx, height - 2 * textOffsety);
  screen.text("Zoom [%] = " + ((zoomFactor - 1) * 100),
    textPositionx, height - textOffsety);  
  screen.endDraw();
  
  image(screen, 0, 0);
}

void applyPalette(String paletteName){
  switch(paletteName){
    case "STRAVAGANZALIGHT" :
      springColor          = randomColorLuminance(127);
      pivotColor           = randomColorLuminance(15);
      massColor            = randomColorLuminance(255);
      backgroundColor      = randomColorLuminance(31);
      textColor            = randomColorLuminance(255);
      
      break;
    case "STRAVAGANZADARK" :
      springColor          = randomColorLuminance(31);
      pivotColor           = randomColorLuminance(255);
      massColor            = randomColorLuminance(15);
      backgroundColor      = randomColorLuminance(127);
      textColor            = randomColorLuminance(15);
      
      break;
    case "EFFSANDZEROS" :
      springColor          = 127;
      pivotColor           = 255;
      massColor            = 0;
      backgroundColor      = 255;
      textColor            = 0;
      
      break;
    case "ZEROSANDEFFS" :
    default :  
      springColor          = 127;
      pivotColor           = 0;
      massColor            = 255;
      backgroundColor      = 0;
      textColor            = 255;
      
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
