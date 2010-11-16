'''
Created on Sep 16, 2010

@author: danielo
'''
from google.appengine.ext import db
import logging, random, string
from math import fabs
from xml.etree import cElementTree as cTree

def createRandomString(length = 10):
    """Create the random string"""
    return "".join([random.choice(string.letters) for _ in range(length)])

"""
A class full of the constants used to runs the game
"""
class Constants(object):
    """Server side constants"""
    # TODO: Make these accurate.
    @classmethod
    def latIndex(cls):
        """The distance between latitude lattice points"""
        return .001                 
    
    @classmethod
    def lonIndex(cls):
        """The distance between longitude lattice points"""
        return .001                
    
    @classmethod
    def maxInfluence(cls):
        """The maximum influence(in lattice points) any object can have"""
        return 10
    
    

class User(db.Model):
    """The user of the game"""
    FacebookID = db.FloatProperty()
    Experience = db.IntegerProperty
    Empire = db.StringProperty()
    isEmperor = db.BooleanProperty()
    completeManaProduction = db.IntegerProperty()
    completeStoneProduction = db.IntegerProperty()
    completeWoodProduction = db.IntegerProperty()
    
    def toXML(self):
        """Return an xml representation of the google app engine model"""
        return """<User>
                    <facebookid>%s</facebookid>
                    <completewoodproduction>%s</completewoodproduction>
                    <completestoneproduction>%s</completestoneproduction>
                    <completemanaproduction>%s</completemanaproduction>
                    <isemperor>%s</isemperor>
                    <empire>%s</empire>
                    <experience>%s</experience>
                 </User>""" % (self.FacebookID, self.completeWoodProduction, self.completeStoneProduction,
                               self.completeManaProduction, self.isEmperor, self.Empire, self.Experience)

    @classmethod
    def createRandomUser(self):
        """Create a random user"""
        u = User()
        u.FacebookID = random.random()
        u.Experience = random.randint(0, 1000)
        u.Empire = createRandomString()
        u.isEmperor = random.randint(0, 1) == 0
        u.completeManaProduction = random.randint(0, 1000)
        u.completeStoneProduction = random.randint(0, 1000)
        u.completeWoodProduction = random.randint(0, 1000)
        u.put()
        return u
        
        
class BoundsPlugin(object):
    """
    The filter plugin adds filter functionality to all of the model object.
    Static methods will be inherited by all of children methods
    """
    @classmethod
    def createRandomObjectInBounds(cls, bounds):
        """
        Function expects a @class-model.Bounds objects as the argument, and
        returns a random object in the bounds
        """
        obj = cls.createRandomObject()
        obj.setRandomlyInBounds(bounds)
        return obj
    
    @classmethod
    def getObjectInBounds(cls, bounds):
        """
        Function expects a @class-model.Bounds objects as the argument
        """
        # Check for the type
        if not isinstance(cls, Bounds):
            logging.error("ERROR : getObjectInBounds requires a model.Bounds object as an argument")
            return []
        
        # Get the locations within the bounds
        sWL = bounds.southwestLocation
        nEL = bounds.northeastLocation
        
        # The result list
        rList = []
        
        # Create a filter object of the class object. Keys only are set to true to make it 
        # the filtering much faster.
        query = cls.all(keys_only = True)
        for lIndex in cls.getLocationIndex():
            
            # The box bounds in filter form
            query.filter("%s > %d" % (lIndex[0], sWL.latIndex))
            query.filter("%s < %d" % (lIndex[0], nEL.latIndex))
            query.filter("%s > %d" % (lIndex[1], sWL.lonIndex))
            query.filter("%s < %d" % (lIndex[1], nEL.lonIndex))
            
            # Extend the list of results
            rList.extend([cls.get(key) for key in query.fetch(1000)])
        
        return rList
    
    def getLocationIndex(self):
        """
        Return a list of location index pairs
        """
        raise NotImplementedError("FilterPlugin.getLocation Need to implement in inherited class")
    
    def setRandomlyInBounds(self, bounds):
        """
        Setup an object randomly in some model.Bounds
        """
        raise NotImplementedError("FilterPlugin.getLocation Need to implement in inherited class")

    @classmethod
    def createRandomObject(cls):
        """
        Create a random object of a certain type
        """
        raise NotImplementedError("FilterPlugin.createRandomObject needs to be implemented in inherited class")

class Road(db.Model, BoundsPlugin):
    """The road object integrates with AMF"""
    # Descriptive
    hitPoints = db.IntegerProperty()
    level = db.IntegerProperty()
    
    
    # A Reference to the user
    user = db.ReferenceProperty(User)
    
    # The latitude and longitude associated with the objects
    lonIndex = db.IntegerProperty()
    latIndex = db.IntegerProperty()
    latitude = db.FloatProperty() 
    longitude = db.FloatProperty()

    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("latIndex", "lonIndex")]
    
    def toXML(self):
        """Return an xml representation of the google app engine model"""
        return """<Road>
                    <hitpoints>%s</hitpoints>
                    <level>%s</level>
                    <latitude>%s</latitude>
                    <longitude>%s</longitude>
                    %s
                  </Road>""" %(self.hitPoints, self.level, self.latitude, self.longitude, self.user.toXML())

    def setRandomlyInBounds(self, bounds):
        """
        Setup an object randomly in some model.Bounds
        """
        location = bounds.createRandomLocationInBounds()
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.latIndex = int(self.latitude / Constants.latIndex())
        self.lonIndex = int(self.longitude / Constants.lonIndex())
        
    @classmethod
    def createRandomObject(cls):
        """
        Create a random Road
        """
        r = Road()
        r.hitPoints = random.randint(0, 1000)
        r.level = random.randint(0, 10)
        r.user = User.createRandomUser()
        return r
    
class Tower(db.Model, BoundsPlugin):
    """The tower object integrates with AMF"""
    # Description of the objects
    Experience = db.IntegerProperty()
    Speed = db.IntegerProperty()
    Power = db.IntegerProperty()
    Armor = db.IntegerProperty()
    Range = db.IntegerProperty()
    Accuracy = db.FloatProperty()
    HitPoints = db.IntegerProperty()
    isIsolated = db.BooleanProperty()
    isCapital = db.BooleanProperty()
    hasRuler = db.BooleanProperty()
    
    # The user who owns the object
    user = db.ReferenceProperty(User)
    
    # Mining capabilities
    manaProduction = db.IntegerProperty()
    stoneProduction = db.IntegerProperty()
    woodProduction = db.IntegerProperty()
    Level = db.IntegerProperty()
    
    # The latitude and longitude associated with the objects
    lonIndex = db.IntegerProperty()
    latIndex = db.IntegerProperty()
    latitude = db.FloatProperty() 
    longitude = db.FloatProperty()
    
    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("latIndex", "lonIndex")]
    
    def toXML(self):
        """Return an xml representation of the google app engine model"""
        return """<Tower>
                    <experience>%s</experience>
                    <speed>%s</speed>
                    <power>%s</power>
                    <armor>%s</armor>
                    <range>%s</range>
                    <accuracy>%s</accuracy>
                    <hitpoints>%s</hitpoints>
                    <isisolated>%s</isisolated>
                    <iscapital>%s</iscapital>
                    <hasruler>%s</hasruler>
                    <level>%s</level>
                    <manaproduction>%s</manaproduction>
                    <stoneproduction>%s</stoneproduction>
                    <woodproduction>%s</woodproduction>
                    <latitude>%s</latitude>
                    <longitude>%s</longitude>
                    %s
                  </Tower>""" % (self.Experience, self.Speed, self.Power, self.Armor, self.Range,
                                 self.Accuracy, self.HitPoints, self.isIsolated, self.isCapital,
                                 self.hasRuler, self.Level, self.manaProduction, self.stoneProduction,
                                 self.woodProduction, self.latitude, self.longitude, self.user.toXML())


    def setRandomlyInBounds(self, bounds):
        """
        Setup an object randomly in some model.Bounds
        """
        location = bounds.createRandomLocationInBounds()
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.latIndex = int(self.latitude / Constants.latIndex())
        self.lonIndex = int(self.longitude / Constants.lonIndex())
        
    @classmethod
    def createRandomObject(cls):
        """
        Create a random Tower
        """
        t = Tower()
        t.Experience = random.randint(0, 1000)
        t.Speed = random.randint(0, 10)
        t.Power = random.randint(0, 10)
        t.Armor = random.randint(0, 10)
        t.Range = random.randint(0, 10)
        t.Accuracy = random.random()
        t.HitPoints = random.randint(0, 1000)
        t.isIsolated = random.randint(0, 1) == 0
        t.isCapital = random.randint(0, 1) == 0
        t.hasRuler = random.randint(0, 1) == 0
        t.user = User.createRandomUser()
        t.Level = random.randint(0, 4)
        t.stoneProduction = random.randint(0, 1000)
        t.woodProduction = random.randint(0, 1000)
        t.manaProduction = random.randint(0, 1000)
        return t

class Portal(db.Model, BoundsPlugin):
    """The portal objects integrates with AMF"""
    # Descriptive
    hitPoints = db.IntegerProperty()
    level = db.IntegerProperty()
    
    # A Reference to the user
    user = db.ReferenceProperty(User)
    
    # The start/end location of the portal
    startLocationLatitude = db.FloatProperty()
    startLocationLongitude = db.FloatProperty()
    startLocationLatitudeIndex = db.IntegerProperty()
    startLocationLongitudeIndex = db.IntegerProperty()
    endLocationLatitude = db.FloatProperty()
    endLocationLongitude = db.FloatProperty()
    endLocationLatitudeIndex = db.IntegerProperty()
    endLocationLongitudeIndex = db.IntegerProperty()
    
    
    def setRandomlyInBounds(self, bounds):
        """
        Setup an object randomly in some model.Bounds
        """
        location = bounds.createRandomLocationInBounds()

        if random.randint(0, 1) == 0:
            self.startLocationLatitude = location.latitude
            self.startLocationLongitude = location.longitude
            self.startLocationLatitudeIndex = int(self.startLocationLatitude / Constants.latIndex())
            self.startLocationLongitudeIndex = int(self.startLocationLongitude / Constants.lonIndex())
        else:
            self.endLocationLatitude = location.latitude
            self.endLocationLongitude = location.longitude
            self.endLocationLatitudeIndex = int(self.endLocationLatitude / Constants.latIndex())
            self.endLocationLongitudeIndex = int(self.endLocationLongitude / Constants.lonIndex())

    
    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("startLocationLatitudeIndex", "startLocationLongitudeIndex"),
                ("endLocationLatitudeIndex", "endLocationLongitudeIndex")]

    def toXML(self):
        """Return an xml representation of the google app engine model"""
        return """<Portal>
                    <hitpoints>%s</hitpoints>
                    <level>%s</level>
                    <startlatitude>%s</startlatitude>
                    <startlongitude>%s</startlongitude>
                    <endlatitude>%s</endlatitude>
                    <endlongitude>%s</endlongitude>
                    %s
                  </Portal>""" %(self.hitPoints, self.level, self.startLocationLatitude,
                                 self.startLocationLongitude, self.endLocationLatitude,
                                 self.endLocationLongitude, self.user.toXML())

    @classmethod
    def createRandomObject(cls):
        """
        Create a random Portal
        """
        p = Portal()
        p.hitPoints = random.randint(0, 1000)
        p.level = random.randint(0, 10)
        p.user = User.createRandomUser()
        return p
class Location(db.Model):
    """The location object integrates with AMF"""
    # The index represesents the lattice site on the map
    latIndex = db.IntegerProperty()
    lonIndex = db.IntegerProperty()
    
    # The geolocation
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    
    def __str__(self):
        return "<Location %s, %s, %s, %s>" % (self.latIndex, self.lonIndex, self.latitude, self.longitude)
    

class Bounds(db.Model):
    """The bound object integrates with AMF"""
    southwestLocation = db.ReferenceProperty(Location, collection_name ="southwestCollection")
    northeastLocation = db.ReferenceProperty(Location, collection_name = "northeastCollection")
    
    def getArea(self):
        """Returns the are of the bounds"""
        width = fabs(self.northeastLocation.longitude - self.southwestLocation.longitude)
        height = fabs(self.southwestLocation.latitude - self.northeastLocation.latitude)
        return width * height
    
    def __str__(self):
        return "<Bounds %s, %s>" % (self.southwestLocation, self.northeastLocation)
    
    def createRandomLocationInBounds(self):
        """Create a random location in the bounds"""
        randomLatitude = random.uniform(self.southwestLocation.latitude, self.northeastLocation.latitude)
        randomLongitude = random.uniform(self.southwestLocation.longitude, self.northeastLocation.longitude)
        return Location(latIndex = int(randomLatitude / Constants.latIndex()), lonIndex = int(randomLongitude / Constants.lonIndex()), 
                        latitude = randomLatitude, longitude = randomLongitude)
    
    @classmethod
    def createBoundsFromAMFData(cls, bounds):
        """
        Extract the relevant information from the AMF data
        """
        southwestLocation = bounds.southwestLocation
        northeastLocation = bounds.northeastLocation
        
        # Get the range of the latitude/longitude
        latitudeList = [northeastLocation['latitude'], southwestLocation['latitude']]
        longitudeList = [northeastLocation['longitude'], southwestLocation['longitude']]
        
        # Create the bounds
        minLat, minLon = min(latitudeList), min(longitudeList)
        maxLat, maxLon = max(latitudeList), max(longitudeList)
        fBoundSouthWest = Location(latIndex = int(minLat / Constants.latIndex()), lonIndex = int(minLon / Constants.lonIndex()), 
                                   latitude = minLat, longitude = minLon)
        fBoundNorthEast =  Location(latIndex = int(maxLat / Constants.latIndex()), lonIndex = int(maxLon / Constants.lonIndex()), 
                                    latitude = maxLat, longitude = maxLon)
        fBoundSouthWest.put()
        fBoundNorthEast.put()
        
        # Return a Bounds objects
        return Bounds(southwestLocation = fBoundSouthWest, northeastLocation = fBoundNorthEast)
    
    @classmethod
    def createBoundsFromPhoneXMLData(cls, data):
        """
        Convert the xml data into an object. The format of the xml is defined
        in the iphone appication
        """
        xml = cTree.ElementTree(cTree.fromstring(data))
        
        # Get the objects from the xml
        sWLatitude = cls.dataFromXML(xml, "bounds/southwestlocation/latitude")
        sWLongitude = cls.dataFromXML(xml, "bounds/southwestlocation/longitude")
        nELatitude = cls.dataFromXML(xml, "bounds/northeastlocation/latitude")
        nELongitude = cls.dataFromXML(xml, "bounds/northeastlocation/longitude")
   
        # Create the location
        sWLocation = Location(sWLatitude, sWLongitude)
        nELocation = Location(nELatitude, nELongitude)
        
        # Return the bounds
        return Bounds(sWLocation, nELocation)
    @classmethod
    def createAllBoundsAroundCentralBound(cls, bounds):
        """
        Function create all bounds around a central bound. The central bound is the visible bound.
        8 bounds around the central bound are calculated using the maximum influence an object can
        have in the game. 
        """
        boundList = []
        
        # Constants
        latInc = Constants.latIndex() * Constants.maxInfluence()
        lonInc = Constants.lonIndex() * Constants.maxInfluence()
        
        # Top Left
        topLeftLocationSW = Location(bounds.northeastLocation.latitude, bounds.southwestLocation.longitude - lonInc)
        topLeftLocationNE = Location(bounds.northeastLocation.latitude + latInc, bounds.southwestLocation.longitude)
        topLeftBound = Bounds(topLeftLocationSW,topLeftLocationNE)
        boundList.append(topLeftBound)
        
        # Top Center
        topCenterLocationSW = Location(bounds.northeastLocation.latitude, bounds.southwestLocation.longitude)
        topCenterLocationNE = Location(bounds.northeastLocation.latitude + latInc, bounds.northeastLocation.longitude)
        topCenterBound = Bounds(topCenterLocationSW,topCenterLocationNE)
        boundList.append(topCenterBound)
        
        # Top Right
        topRightLocationSW = Location(bounds.northeastLocation.latitude, bounds.northeastLocation.longitude)
        topRightLocationNE = Location(bounds.northeastLocation.latitude + latInc, bounds.northeastLocation.longitude + lonInc)
        topRightBound = Bounds(topRightLocationSW,topRightLocationNE)
        boundList.append(topRightBound)
        
        # Bottom Left
        bottomLeftLocationSW = Location(bounds.southwestLocation.latitude - latInc, bounds.southwestLocation.longitude - lonInc)
        bottomLeftLocationNE = Location(bounds.southwestLocation.latitude, bounds.southwestLocation.longitude)
        bottomLeftBound = Bounds(bottomLeftLocationSW,bottomLeftLocationNE)
        boundList.append(bottomLeftBound)
        
        # Bottom Center
        bottomCenterLocationSW = Location(bounds.southwestLocation.latitude - latInc, bounds.southwestLocation.longitude)
        bottomCenterLocationNE = Location(bounds.southwestLocation.latitude, bounds.northeastLocation.longitude)
        bottomCenterBound = Bounds(bottomCenterLocationSW,bottomCenterLocationNE)
        boundList.append(bottomCenterBound)
        
        # Bottom Right
        bottomRightLocationSW = Location(bounds.southwestLocation.latitude - latInc, bounds.northeastLocation.longitude)
        bottomRightLocationNE = Location(bounds.southwestLocation.latitude, bounds.northeastLocation.longitude + lonInc)
        bottomRightBound = Bounds(bottomRightLocationSW,bottomRightLocationNE)
        boundList.append(bottomRightBound)
        
        # Left
        leftLocationSW = Location(bounds.southwestLocation.latitude, bounds.southwestLocation.longitude - lonInc)
        leftLocationNE = Location(bounds.northeastLocation.latitude, bounds.southwestLocation.longitude)
        leftBound = Bounds(leftLocationSW,leftLocationNE)
        boundList.append(leftBound)
        
        # Right
        rightLocationSW = Location(bounds.southwestLocation.latitude, bounds.northeastLocation.longitude)
        rightLocationNE = Location(bounds.northeastLocation.latitude, bounds.northeastLocation.longitude)
        rightBound = Bounds(rightLocationSW,rightLocationNE)
        boundList.append(rightBound)
        
        return boundList
    
    def dataFromXML(self, xml, name):
        """Get the data from the xml corresponding to elem"""
        element = xml.find(name)
        return element.text