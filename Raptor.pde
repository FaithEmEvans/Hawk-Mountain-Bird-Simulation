// 19Apr start of preload PImages into speciesToImage to avoid loading during draw()

java.util.HashMap<String, PImage> speciesToImage = new java.util.HashMap<String, PImage>();

void setupSpeciesToImage() {
  // Call from setup() to minimize repeated calls to loadImage during draw() thread.
  String [] raptorNames = {
    "hawk.png", "eagle.png", "falcon.png", "accipiter.png", "vulture.png", "unid.png"
  };
  for (String name : raptorNames) {
    speciesToImage.put(name, loadImage(name));
  }
}
// PARSON 19Apr end of preload PImages

// Raptor class to display raptor image
public class Raptor{
      
  PImage raptor;

    public void display(int raptorx, int raptory) { // PARSON 19Apr use same coordinates as ellipse
      imageMode(CENTER); // PARSON 19Apr use same coordinates as ellipse
      if(fetchFloat("SS", currentInstance, -10000) > 0 || fetchFloat("CH", currentInstance, -10000) > 0 ||
         fetchFloat("BW", currentInstance, -10000)> 0 || fetchFloat("RS", currentInstance, -10000) > 0 ||
         fetchFloat("NH", currentInstance, -10000) > 0 || fetchFloat("SW", currentInstance, -10000) > 0 ||
         fetchFloat("UB", currentInstance, -10000) > 0 || fetchFloat("RT", currentInstance, -10000)> 0 ||
         fetchFloat("RL", currentInstance, -10000) > 0 || fetchFloat("OS", currentInstance, -10000) > 0){            
            // raptor = loadImage("hawk.png");
            raptor = speciesToImage.get("hawk.png"); // PARSON 19Apr use the map
      }
      
      if(fetchFloat("GE", currentInstance, -10000)> 0 || fetchFloat("BE", currentInstance, -10000) > 0 ||
         fetchFloat("UE", currentInstance, -10000) > 0){           
            // raptor = loadImage("eagle.png");
            raptor = speciesToImage.get("eagle.png");  // PARSON 19Apr use the map
      }
      
       if(fetchFloat("ML", currentInstance, -10000) > 0 || fetchFloat("UF", currentInstance, -10000) > 0 ||
          fetchFloat("PG", currentInstance, -10000) > 0 || fetchFloat("AK", currentInstance, -10000) > 0){           
            // raptor = loadImage("falcon.png");
            raptor = speciesToImage.get("falcon.png"); // PARSON 19Apr use the map
      }
      
       if(fetchFloat("MK", currentInstance, -10000) > 0 || fetchFloat("UA", currentInstance, -10000) > 0 ||
          fetchFloat("NG", currentInstance, -10000) > 0){           
            // raptor = loadImage("accipiter.png"); 
            raptor = speciesToImage.get("accipiter.png"); // PARSON 19Apr use the map
      }
      
       if(fetchFloat("BV", currentInstance, -10000) > 0 || fetchFloat("UV", currentInstance, -10000) > 0 ||
          fetchFloat("TV", currentInstance, -10000) > 0){           
            // raptor = loadImage("vulture.png");
            raptor = speciesToImage.get("vulture.png");  // PARSON 19Apr use the map
      }
      
       if(fetchFloat("UR", currentInstance, -10000) > 0){          
            // raptor = loadImage("unid.png");
            raptor = speciesToImage.get("unid.png");  // PARSON 19Apr use the map
      }
      if (raptor == null) {
        // PARSON 19Apr use the map, being safe by supplying a default
        raptor = speciesToImage.get("unid.png");  // PARSON 19Apr use the map
      }
      image(raptor, raptorx, raptory /*0, 0*/);  
  }
}

  //hawk = loadImage("hawk.png");
  //eagle = loadImage("eagle.png");
  //falcon = loadImage("falcon.png");
  //vulture = loadImage("vulture.png");
  //accipiter = loadImage("accipiter.png");
  //unid = loadImage("unid.png");
  
  //attrNameToIndex.get("BE").intValue()
   
