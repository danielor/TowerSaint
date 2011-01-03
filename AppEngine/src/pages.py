'''
Created on November 13, 2010

@author: danielo
'''
import logging
from google.appengine.ext import webapp
from google.appengine.api import memcache
from models import Bounds, User, Road, Portal, Tower,Constants, Location


class UserPage(webapp.RequestHandler):
    def __init__(self):
        """Initialize the request to this webapp object"""
        webapp.RequestHandler.__init__(self)
         
    def get(self, fID):
        """Get the user data"""    
        
        # Get the results
        u = User.createRandomUserWithID(int(fID))
        writeString = '<?xml version="1.0" encoding="UTF-8"?>'
        writeString += "<response>" 
        if u:
            writeString += u.toXML()
        writeString += "</response>" 
        
            
        # Write the response back to the user
        self.response.out.write(writeString)
        

class BoundsPage(webapp.RequestHandler):
    def __init__(self):
        """Initialize the webappa request with some state"""
        webapp.RequestHandler.__init__(self)
        
        # Delete all objects in the database
        self.deleteAllObjects()
    
    def get(self, swLat, swLon, neLat, neLon):
        """Handles a post request to this page"""
        aEBounds = Bounds.createBoundsFromSimpleData(float(swLat), float(swLon), float(neLat), float(neLon))
        logging.error(aEBounds)
        # Check if one of the objects is on the map
        results = Road.getObjectInBounds(aEBounds)
        if len(results) == 0:
            self.loadRandomDataInBounds(aEBounds)
        
        # Find all of the drawable object within the bounds
        listOfObjects = []
        listOfObjects.extend(Road.getObjectInBounds(aEBounds))
        listOfObjects.extend(Portal.getObjectInBounds(aEBounds))
        listOfObjects.extend(Tower.getObjectInBounds(aEBounds))
        
        # Convert the list of objects into a response
        writeString = '<?xml version="1.0" encoding="UTF-8"?>'
        writeString += "<response>" 
        if listOfObjects is not None:
            for model in listOfObjects:
                if model:
                    writeString += model.toXML()
        writeString += "</response>" 
        
        logging.error(writeString )
        
        # Write the response back to the user
        self.response.out.write(writeString)
        
    def deleteAllObjects(self):
        """Remove all objects in the database"""
        for cls in [Bounds, User, Road, Portal, Tower, Location]:
            query = cls.all()
            for obj in query.fetch(1000):           # For intial testing it would be rare for their to be more than 1000
                obj.delete()
                
    def loadRandomDataInBounds(self, bounds, numberOfRandomObjects = 5):
        """Load random data in the bounds of the data"""
        for _ in range(numberOfRandomObjects):
            # Create objects with the bounds
            for obj in [Road, Tower, Portal]:
                ins = obj.createRandomObjectInBounds(bounds)
                ins.put()