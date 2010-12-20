'''
Created on Sep 17, 2010

@author: danielo
'''
from google.appengine.ext import db 
import pyamf, random, string, logging
from pyamf import amf3
from pyamf.flex import ArrayCollection, ObjectProxy
from models import User, Road, Tower, Portal, Location, Bounds, Constants

def drange(start, stop, step):
    """Get the range"""
    r = start
    while r < stop:
        yield r
        r += step

def createListOfLocations(latlng, numberOfLocations = 5):
    """Create a list of locations"""
    southwestLocation = latlng.southwestLocation
    northeastLocation = latlng.northeastLocation
    
    # Get the range of the latitude/longitude
    latitudeList = [northeastLocation['latitude'], southwestLocation['latitude']]
    longitudeList = [northeastLocation['longitude'], southwestLocation['longitude']]
    minLatitude, maxLatitude = min(latitudeList), max(latitudeList)
    minLongitude, maxLongitude = min(longitudeList), max(longitudeList)
    listOfLatitude = [a for a in drange(minLatitude, maxLatitude, Constants.latIndex())]
    listOfLongitude = [l for l in drange(minLongitude, maxLongitude, Constants.lonIndex())]
    
    # The number of the proxy
    listOfLocation = []
    for _ in range(numberOfLocations):
        
        # Create the location data
        longitude = listOfLongitude[random.randrange(0, len(listOfLongitude) - 1)]
        latitude = listOfLatitude[random.randrange(0, len(listOfLatitude) - 1)]
        longitudeIndex = int(longitude / Constants.lonIndex())
        latitudeIndex = int(latitude / Constants.latIndex())
        
        # Create the location, and the object proxy
        l = createLocation(latitudeIndex, longitudeIndex, latitude, longitude)
        #location = ObjectProxy(l)
        listOfLocation.append(l)
    return listOfLocation

def createRandomString(length = 10):
    """Create the random string"""
    return "".join([random.choice(string.letters) for _ in range(length)])


def createListOfPairs(seq):
    """Create a list of consecutive pairs"""
    it = iter(seq)
    try:
        while True:
            yield it.next(), it.next()
    except StopIteration:
        return

def createLocation(latIndex, lonIndex, latitude, longitude):
    l = Location()
    l.latIndex = latIndex
    l.lonIndex = lonIndex
    l.latitude = latitude
    l.longitude = longitude
    return l

        
# The services for the AMF objects
class TowerService(object):
    def __init__(self):
        """Constructor"""
        self.numberOfObjectsPerBound = 5
        
    def getObjectInBounds(self, latlng):
        """Get all tower objects within the bounds"""

        # Return the array collection
        return ArrayCollection(self._createListOfTowers(latlng, self.numberOfObjectsPerBound))
    
    def _createListOfTowers(self, bounds, howMany):
        """Create a list of towers in the bounds"""
            
        # Create the objects
        b = Bounds.createBoundsFromAMFData(bounds)
        
        # List of objects
        listOfTowers = []
        
        # From the list of locations 
        for _ in range(howMany):
            tower = Tower.createRandomObjectInBounds(b)
            tower.put()
            # Get the proxy
            listOfTowers.append(tower)
        return listOfTowers
    
    def getObjectInFunctionalBounds(self, bounds):
        """
        Get *all* objects that influence the visible screen. Objects outside of the
        map bounds can influence the drawing of the map bounds. The objects created randomly
        off the screen should be cached, so as to be consistent when the user pans. 
        """
        """
        southwestLocation = bounds.southwestLocation
        northeastLocation = bounds.northeastLocation
        
        # Get the range of the latitude/longitude
        latitudeList = [northeastLocation['latitude'], southwestLocation['latitude']]
        longitudeList = [northeastLocation['longitude'], southwestLocation['longitude']]
        
        # Create the bounds
        fBoundSouthWest = Location(min(latitudeList) - Constants.latOffset() * Constants.maxInfluence(),  
                                    max(latitudeList)  + Constants.latOffset() * Constants.maxInfluence())
        fBoundNorthEast = Location(min(longitudeList) - Constants.lonOffset() * Constants.maxInfluence(), 
                                      max(longitudeList)  + Constants.lonOffset() * Constants.maxInfluence())
        
        # The functional bounds of the pieces. Get the object of the service type in the bound
        functionalBounds = Bounds(fBoundSouthWest, fBoundNorthEast)
        """
        # The list of towers
        listOfTowers = []
        #listOfTowers.extend([f for f in Tower.getObjectInBounds(functionalBounds)])
        if len(listOfTowers) < self.numberOfObjectsPerBound:
            pass

class PortalService(object):
    def __init__(self):
        """Constructor"""
        self.numberOfObjectsPerBound = 5

    
    def getObjectInBounds(self, latlng):
        """Get all tower objects within the bounds"""
        
        # Create the objects
        b = Bounds.createBoundsFromAMFData(latlng)
        
        # The list of portals
        listOfPortals = []
        
        for _ in range(self.numberOfObjectsPerBound):
            portal = Portal.createRandomObjectInBounds(b)
            
            # Create the proxy
            listOfPortals.append(portal)
        
        return ArrayCollection(listOfPortals)
    
    def getObjectInFunctionalBounds(self, bounds):
        """
        Get *all* objects that influence the visible screen. Objects outside of the
        map bounds can influence the drawing of the map bounds. The objects created randomly
        off the screen should be cached, so as to be consistent when the user pans. 
        """

        
class RoadService(object):
    def __init__(self):
        """Constructor"""
        self.numberOfObjectsPerBound = 5

    
    def getObjectInBounds(self, latlng):
        """Get all tower objects within the bounds"""
        # Create the objects
        b = Bounds.createBoundsFromAMFData(latlng)
        
        # The list of road
        listOfRoads = []
        for _ in range(self.numberOfObjectsPerBound):
            
            # Create the road
            road = Road.createRandomObjectInBounds(b)
            
            # The proxy
            listOfRoads.append(road)
            
        return ArrayCollection(listOfRoads)

    def getObjectInFunctionalBounds(self, bounds):
        """
        Get *all* objects that influence the visible screen. Objects outside of the
        map bounds can influence the drawing of the map bounds. The objects created randomly
        off the screen should be cached, so as to be consistent when the user pans. 
        """
        
    
def register_classes(AMF_NAMESPACE = 'models'):
    """Register the amf classes in a namespace"""
    # set this so returned objects and arrays are bindable
    amf3.use_proxies_default = True

    # register domain objects that will be used with PyAMF
    pyamf.register_class(User, '%s.User' % AMF_NAMESPACE)
    pyamf.register_class(Location, '%s.Location' % AMF_NAMESPACE)
    pyamf.register_class(Portal, '%s.Portal' % AMF_NAMESPACE)
    pyamf.register_class(Road, '%s.Road' % AMF_NAMESPACE)
    pyamf.register_class(Tower, '%s.Tower' % AMF_NAMESPACE)
    pyamf.register_class(Bounds, "%s.Bounds" % AMF_NAMESPACE)

    
    