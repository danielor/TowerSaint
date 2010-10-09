'''
Created on Sep 17, 2010

@author: danielo
'''
from google.appengine.ext import db 
import pyamf, random, string, logging
from pyamf import amf3
from pyamf.flex import ArrayCollection, ObjectProxy

def drange(start, stop, step):
    """Get the range"""
    r = start
    while r < stop:
        yield r
        r += step

def createListOfLocations(latlng, latOffset = .001, lonOffset = .001, numberOfLocations = 5):
    """Create a list of locations"""
    southwestLocation = latlng.southwestLocation
    northeastLocation = latlng.northeastLocation
    
    # Get the range of the latitude/longitude
    latitudeList = [northeastLocation['latitude'], southwestLocation['latitude']]
    longitudeList = [northeastLocation['longitude'], southwestLocation['longitude']]
    minLatitude, maxLatitude = min(latitudeList), max(latitudeList)
    minLongitude, maxLongitude = min(longitudeList), max(longitudeList)
    listOfLatitude = [a for a in drange(minLatitude, maxLatitude, latOffset)]
    listOfLongitude = [l for l in drange(minLongitude, maxLongitude, lonOffset)]
    
    # The number of the proxy
    listOfLocation = []
    for _ in range(numberOfLocations):
        
        # Create the location data
        longitude = listOfLongitude[random.randrange(0, len(listOfLongitude) - 1)]
        latitude = listOfLatitude[random.randrange(0, len(listOfLatitude) - 1)]
        longitudeIndex = int(longitude / lonOffset)
        latitudeIndex = int(latitude / latOffset)
        
        # Create the location, and the object proxy
        l = createLocation(latitudeIndex, longitudeIndex, latitude, longitude)
        #location = ObjectProxy(l)
        listOfLocation.append(l)
    return listOfLocation

def createRandomString(length = 10):
    """Create the random string"""
    return "".join([random.choice(string.letters) for _ in range(length)])

def createRandomUser():
    """Factory function for random user"""
    u = createUser(random.random(), random.randint(0, 1000), createRandomString(), random.randint(0, 1) == 0,
             random.randint(0, 1000), random.randint(0, 1000), random.randint(0, 1000))
    return u

def createListOfPairs(seq):
    """Create a list of consecutive pairs"""
    it = iter(seq)
    try:
        while True:
            yield it.next(), it.next()
    except StopIteration:
        return

# The AMF objects - AMF requires these classes to be effectively empty since the
# package embeds its own constructors for different use cases.
class Portal(object):
    pass
class Location(object):
    pass
"""
class Location(db.Model):
    """"""
    Abstraction of a location model
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    latIndex = db.IntegerProperty()                 
    lonIndex = db.IntegerProperty()
"""

class Road(object):
    pass

class Bounds(object):
    pass

class User(object):
    pass

class Tower(object):
    pass

# Factory functions to create the objects
def createPortal(hitPoints, level, user):
    """
    hitPoints - the number of hit points associated with the portal
    level - the level associated with the portal
    user - the user who owns the portal
    """
    p = Portal()
    p.hitPoints = hitPoints
    p.level = level
    p.user = user
    return p
    
def createLocation(latIndex, lonIndex, latitude, longitude):
    l = Location()
    l.latIndex = latIndex
    l.lonIndex = lonIndex
    l.latitude = latitude
    l.longitude = longitude
    return l
        
def createRoad(hitPoints, level, user):
    r = Road()
    r.hitPoints = hitPoints
    r.level = level
    r.user = user
    return r

def createBounds(southwestLocation, northeastLocation):
    b = Bounds()
    b.southwestLocation = southwestLocation
    b.northeastLocation = northeastLocation
    return b

def createUser(FacebookID, Experience, Empire, isEmperor, completeManaProduction,
                 completeStoneProduction, completeWoodProduction):
    u = User()
    u.FacebookID = FacebookID
    u.Experience = Experience
    u.Empire = Empire
    u.isEmperor = isEmperor
    u.completeManaProduction = completeManaProduction
    u.completeStoneProduction = completeStoneProduction
    u.completeWoodProduction = completeWoodProduction
    return u

def createTower(Experience, Speed, Power, Armor, Range, Accuracy,
                 HitPoints, isIsolated, isCapital, hasRuler, user,
                 manaProduction, stoneProduction, woodProduction, level):
    t = Tower()
    t.Experience = Experience
    t.Speed = Speed
    t.Power = Power
    t.Armor = Armor
    t.Range = Range
    t.Accuracy = Accuracy
    t.HitPoints = HitPoints
    t.isIsolated = isIsolated
    t.isCapital = isCapital
    t.hasRuler = hasRuler
    t.user = user
    t.manaProduction = manaProduction
    t.stoneProduction = stoneProduction
    t.woodProduction = woodProduction
    t.Level = level
    return t
        

        
# The services for the AMF objects
class TowerService(object):
    def __init__(self):
        """Constructor"""
        
    def getObjectInBounds(self, latlng):
        """Get all tower objects within the bounds"""
        listOfLocations = createListOfLocations(latlng)
        u = createRandomUser()
        
        # List of objects
        listOfTowers = []
        
        # From the list of locations 
        for l in listOfLocations:
            tower = createTower(random.randint(0, 1000), random.randint(0, 10), random.randint(0, 10),
                                                  random.randint(0, 10), random.randint(0, 10), random.randint(0, 10),
                                                  random.randint(0, 1000), random.randint(0, 1) == 0, random.randint(0, 1) == 0,
                                                  random.randint(0, 1) == 0, u, random.randint(0, 1000), random.randint(0, 1000),
                                                  random.randint(0, 1000), random.randint(0, 4))
            
            # Extract the tower
            tower.latIndex = l.latIndex
            tower.lonIndex = l.lonIndex
            tower.latitude = l.latitude
            tower.longitude = l.longitude
            
            
            logging.error(tower.longitude)
            logging.error(tower.latitude)
            # Get the proxy
            listOfTowers.append(tower)
        
        # Return the array collection
        return ArrayCollection(listOfTowers)
        

class PortalService(object):
    def __init__(self):
        """Constructor"""
    
    def getObjectInBounds(self, latlng):
        """Get all tower objects within the bounds"""
        
        # Create the objects
        listOfLocations = createListOfLocations(latlng)
        u = createRandomUser()
        listOfPairs = createListOfPairs(listOfLocations)
        
        # The list of portals
        listOfPortals = []
        
        for firstL, secondL in listOfPairs:
            portal = createPortal(random.randint(0, 1000), random.randint(0, 10), u)
            
            # The start location
            portal.startLocationLatitude = firstL.latitude
            portal.startLocationLongitude = firstL.longitude
            portal.startLocationLatitudeIndex = firstL.latIndex
            portal.startLocationLongitudeIndex = firstL.lonIndex
            
            # The end location
            portal.endLocationLatitude = secondL.latitude
            portal.endLocationLongitude = secondL.longitude
            portal.endLocationLatitudeIndex = secondL.latIndex
            portal.endLocationLongitudeIndex = secondL.lonIndex
            
            # Create the proxy
            proxy = ObjectProxy(portal)
            listOfPortals.append(proxy)
        
        return ArrayCollection(listOfPortals)

        
class RoadService(object):
    def __init__(self):
        """Constructor"""
    
    def getObjectInBounds(self, latlng):
        """Get all tower objects within the bounds"""
        listOfLocations = createListOfLocations(latlng)
        u = createRandomUser()
        
        # The list of road
        listOfRoads = []
        for l in listOfLocations:
            
            # Create the road
            road = createRoad(random.randint(0, 1000),random.randint(0, 10), u)
            
            # Extract the tower
            road.latIndex = l.latIndex
            road.lonIndex = l.lonIndex
            road.latitude = l.latitude
            road.longitude = l.longitude
            
            # The proxy
            proxy = ObjectProxy(road)
            listOfRoads.append(proxy)
            
        return ArrayCollection(listOfRoads)

    
    
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

    
    