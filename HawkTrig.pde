
// See https://amsi.org.au/teacher_modules/further_trigonometry.html
// for math basis of the following functions,
// OR JUST IGNORE THEIR TRIG INTERNALS & USE THEM.
float [] getDisplayPath(float refsitex, float refsitey, float pathDegrees, 
  boolean pathDegreesIsDestination) {
  // Get the edge-of-window intercepts, where refsitex,refsitey is global coordinate
  // and returned [0],[1] gives incoming
  // location on window, [2],[3] gives outgoing, relative to 0,0 at window upper left
  // pathDegreesIsDestination should be true if flyingObjects are flying that direction,
  // pathDegreesIsDestination should be false is WindDIR is coming from that direction.
  float [] result = new float[4];
  if (! pathDegreesIsDestination) {
    pathDegrees = (pathDegrees+180.0) % 360 ;  // opposite direction
  }
  // Constrain pathDegrees:
  while (pathDegrees >= 360) {
    pathDegrees -= 360 ;
  }
  while (pathDegrees < 0) {
    pathDegrees += 360 ;
  }
  // Deal with directions along axis first. Avoid divide by 0, etc.
  if (pathDegrees == 0) {
    // This is due North. They are going north.
    result[0] = result[2] = refsitex ;
    result[1] = height-1 ;
    result[3] = 0 ;
  } else if (pathDegrees == 180) {
    // This is due South.  They are going south.
    result[0] = result[2] = refsitex ;
    result[1] = 0 ;
    result[3] = height-1 ;
  } else if (pathDegrees == 90) {
    // This is due East. They are going east.
    result[1] = result[3] = refsitey ;
    result[0] = 0 ;
    result[2] = width-1 ;
  } else if (pathDegrees == 270) {
    // This is due West. They are going west.
    result[1] = result[3] = refsitey ;
    result[2] = 0 ;
    result[0] = width-1 ;
  } else {
    // Determine slope from angle, use slope to find endpoints of window edge.
    float slope = 0 ;
    if (pathDegrees < 90) {
      // upper right, i.e., NE
      // positive slope, decrease in magnitude as it approaches 90
      // reverse direction around 45, i.e., 10 becomes 80, 80 becomes 10, etc.
      float distfrom45 = 45.0 - pathDegrees ;
      slope = tan(radians(45.0 + distfrom45));
      result = findEndpoints(refsitex, refsitey, slope, 0);
    } else if (pathDegrees < 180) {
      float distfrom135 = 135.0 - pathDegrees ;
      slope = tan(radians(135.0 + distfrom135));
      result = findEndpoints(refsitex, refsitey, slope, 1);
    } else if (pathDegrees < 270) {
      float distfrom225 = 225.0 - pathDegrees ;
      slope = tan(radians(225.0 + distfrom225));
      result = findEndpoints(refsitex, refsitey, slope, 2);
    } else {
      // upper left, NW
      float distfrom315 = 315.0 - pathDegrees ;
      slope = tan(radians(315.0 + distfrom315));
      result = findEndpoints(refsitex, refsitey, slope, 3);
    }
  }
  return result ;
}

float [] findEndpoints(float refsitex, float refsitey, float slope, int quadrant) {
  float [] result = new float [ 4 ];
  float invslope = 1.0 / slope ;
  float flippedy = height - refsitey ;  // distance grows from bottom of display
  // slope is Ydelta/Xdelta, invslope is Xdelta/Ydelta
  /*
  float xincoming = refsitex-invslope*(flippedy) ;  // y=0 crossing
   float yincoming = height-(refsitey-slope*(refsitex-0))-1; // x=0 crossing
   float xoutgoing = refsitex+invslope*(flippedy) ;  // y=0 crossing
   float youtgoing = height-(refsitey+slope*(refsitex-0)); // x=0 crossing
   */
  float xincoming = -(invslope * flippedy - refsitex) ; // y=0  at bottom crossing
  float yincoming = height+(slope * refsitex - flippedy); // x=0 crossing
  float xoutgoing = invslope * (height-flippedy) + refsitex ; 
  float youtgoing = height-(slope * (width-1-refsitex) + flippedy);
  switch (quadrant) {
  case 0 :    // NE
    // Entry X is 0 or Y is height-1. Exit X is width-1 or Y is 0
    if (xincoming >= 0 && xincoming < width) {
      result[0] = xincoming ;
      result[1] = height-1 ;
    } else {
      result[0] = 0 ;
      result[1] = yincoming;
    }
    if (xoutgoing >= 0 && xoutgoing < width) {
      result[2] = xoutgoing ;
      result[3] = 0 ;
    } else {
      result[2] = width-1 ;
      result[3] = youtgoing ;
    }
    break ;
  case 1 :    // SE
    if (xoutgoing >= 0 && xoutgoing < width) {
      result[0] = xoutgoing ; //xincoming ;
      result[1] = 0 ; // DEBUG height-1 ;
    } else {
      result[0] = 0 ;
      result[1] = yincoming;
    }
    if (xincoming >= 0 && xincoming < width) {
      result[2] = xincoming ; //xoutgoing ;
      result[3] = height - 1 ; // 0 ;
    } else {
      result[2] = width-1 ;
      result[3] = youtgoing ;
    }
    break ;
  case 2 :    // SW
    // swap entry and exit points from case 0. Slope is still 1.
    if (xincoming >= 0 && xincoming < width) {
      result[2] = xincoming ;
      result[3] = height-1 ;
    } else {
      result[2] = 0 ;
      result[3] = yincoming;
    }
    if (xoutgoing >= 0 && xoutgoing < width) {
      result[0] = xoutgoing ;
      result[1] = 0 ;
    } else {
      result[0] = width-1 ;
      result[1] = youtgoing ;
    }
    break  ;
  case 3 :    // NW
    // Swap entry and exit points from case 1.
    if (xoutgoing >= 0 && xoutgoing < width) {
      result[2] = xoutgoing ; //xincoming ;
      result[3] = 0 ; // DEBUG height-1 ;
    } else {
      result[2] = 0 ;
      result[3] = yincoming;
    }
    if (xincoming >= 0 && xincoming < width) {
      result[0] = xincoming ; //xoutgoing ;
      result[1] = height - 1 ; // 0 ;
    } else {
      result[0] = width-1 ;
      result[1] = youtgoing ;
    }
    break ;
  }
  println("DEBUG SLOPE OF " + slope);
  println("DEBUG endpoints = " + result[0]+","+result[1]+" to "+result[2]+","+result[3]);
  return result ;
}
