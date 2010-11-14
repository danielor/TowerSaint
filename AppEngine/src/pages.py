'''
Created on November 13, 2010

@author: danielo
'''
from google.appengine.ext import webapp
from models import Bounds, User, Road, Portal, Tower,Constants, Location

class BoundsPage(webapp.RequestHandler):
    def __init_(self):
        """Initialize the webappa request with some state"""
        webapp.RequestHandler.__init__(self)
        
        # Delete all objects in the database
        self.deleteAllObjects()
    
    def post(self):
        """Handles a post request to this page"""
        xmlParam = self.request.params['bounds']
        aEBounds = Bounds.createBoundsFromPhoneXMLData(xmlParam)
        
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
        
        # Write the response back to the user
        self.response.out.write(writeString)
        
    def deleteAllObjects(self):
        """Remove all objects in the database"""
        for cls in [Bounds, User, Road, Portal, Tower, Location]:
            query = cls.all()
            for obj in query.fetch(1000):           # For intial testing it would be rare for their to be more than 1000
                obj.delete()
                
    def loadRandomDataInBounds(self, bounds):
        """Load random data in the bounds of the data"""