'''
Created on Sep 16, 2010

Note 1:
It should be noted that the order of the __readamf__, and __writeamf__ functions
are important. The flex, and gae must be consistent.

@author: danielo
'''
from google.appengine.ext import db
import logging, random, string
from math import fabs
from xml.etree import cElementTree as cTree
from geo.geomodel import GeoModel
from geo.geotypes import Box

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
    
    @classmethod
    def minInfluence(cls):
        """The minimum influence(in lattice points) any object can have"""
        return 3
    
    @classmethod
    def latToMiles(cls):
        """Converts a latitude constant to miles"""
        return 69
    
    

class User(db.Model):
    """The user of the game"""
#    class __amf__:
#        external = True
#        amf3 = True
#        
#    def __writeamf__(self, output):
#        """Encoding of the information"""
#        output.writeInt(self.FacebookID)
#        output.writeInt(self.Experience)
#        output.writeUTF(self.Empire)
#        output.writeInt(self.completeManaProduction)
#        output.writeInt(self.completeStoneProduction)
#        output.writeInt(self.completeWoodProduction)
#        
#    def __readamf__(self, input):
#        """Decoding of the information"""
#        self.FacebookID = input.readInt()
#        self.Experience = input.readInt()
#        self.Empire = input.readUTF()
#        self.isEmperor = input.readBoolean()
#        self.completeManaProduction = input.readInt()
#        self.completeStoneProduction = input.readInt()
#        self.completeWoodProduction = input.readInt()
        
    FacebookID = db.IntegerProperty()
    Experience = db.IntegerProperty()
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
        u.FacebookID = random.randint(0, 1000)
        u.Experience = random.randint(0, 1000)
        u.Empire = createRandomString()
        u.isEmperor = random.randint(0, 1) == 0
        u.completeManaProduction = random.randint(0, 1000)
        u.completeStoneProduction = random.randint(0, 1000)
        u.completeWoodProduction = random.randint(0, 1000)
        u.put()
        return u
    
    @classmethod
    def createRandomUserWithID(cls, id):
        u = User()
        u.FacebookID = id
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
        if not isinstance(bounds, Bounds):
            logging.error("ERROR : getObjectInBounds requires a model.Bounds object as an argument")
            return []
        
        # Get the locations within the bounds
        sWL = bounds.southwestLocation
        nEL = bounds.northeastLocation
        
        # Create the box for filtering 
        box = Box(nEL.latitude, nEL.longitude, sWL.latitude, sWL.longitude)
        
        # Find all cls objects in the bounding_box
        rList = cls.bounding_box_fetch(cls.all(), box, max_results = 1000)
        
        return rList
    
    @classmethod
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

class Road(GeoModel, BoundsPlugin):
    """The road object integrates with AMF"""
#    class __amf__:
#        external = True
#        amf3 = True
#
#    def __writeamf__(self, output):
#        """Encoding of the information"""
#        output.writeInt(self.hitPoints)
#        output.writeInt(self.level)
#        output.writeObject(self.user)
#        output.writeInt(self.lonIndex)
#        output.writeInt(self.latIndex)
#        output.writeFloat(self.latitude)
#        output.writeFloat(self.longitude)
#        
#    def __readamf__(self, input):
#        """Decoding of the information"""
#        self.hitPoints = input.readInt()
#        self.level = input.readInt()
#        self.user = input.readObject()
#        self.lonIndex = input.readInt()
#        self.latIndex = input.readInt()
#        self.latitude = input.readFloat()
#        self.longitude = input.readFloat()
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
    
   
    @classmethod
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
        self.location = db.GeoPt(self.latitude, self.longitude)
        self.update_location()
        
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
    
class Tower(GeoModel, BoundsPlugin):
    """The tower object integrates with AMF"""
#    class __amf__:
#        external = True
#        amf3 = True
#        
#    def __writeamf__(self, output):
#        """Encoding of the information"""
#        output.writeInt(self.Experience)
#        output.writeInt(self.Speed)
#        output.writeInt(self.Power)
#        output.writeInt(self.Armor)
#        output.writeInt(self.Range)
#        output.writeFloat(self.Accuracy)
#        output.writeInt(self.HitPoints)
#        output.writeBoolean(self.isIsolated)
#        output.writeBoolean(self.isCapital)
#        output.writeBoolean(self.hasRuler)
#        output.writeObject(self.user)
#        output.writeInt(self.manaProduction)
#        output.writeInt(self.stoneProduction)
#        output.writeInt(self.woodProduction)
#        output.writeInt(self.Level)
#        output.writeInt(self.latIndex)
#        output.writeInt(self.lonIndex)
#        output.writeFloat(self.latitude)
#        output.writeFloat(self.longitude)
#        
#    def __readamf__(self, input):
#        """Decoding of the information"""
#        self.Experience = input.readInt()
#        self.Speed = input.readInt()
#        self.Power = input.readInt()
#        self.Armor = input.readInt()
#        self.Range = input.readInt()
#        self.Accuracy = input.readFloat()
#        self.HitPoints = input.readInt()
#        self.isIsolated = input.readBoolean()
#        self.isCapital = input.readBoolean()
#        self.hasRuler = input.readBoolean()
#        self.user = input.readObject()
#        self.manaProduction = input.readInt()
#        self.stoneProduction = input.readInt()
#        self.woodProduction = input.readInt()
#        self.Level = input.readInt()
#        self.latIndex = input.readInt()
#        self.lonIndex = input.readInt()
#        self.latitude = input.readFloat()
#        self.longitude = input.readFloat()
        
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
    
    @classmethod
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
        self.location = db.GeoPt(self.latitude, self.longitude)
        self.update_location()
        
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

class Portal(GeoModel, BoundsPlugin):
    """The portal objects integrates with AMF"""
#    class __amf__:
#        external = True
#        amf3 = True
#        
#    def __writeamf__(self, output):
#        """Encoding of the information"""
#        output.writeInt(self.hitPoints)
#        output.writeInt(self.level)
#        output.writeObject(self.user)
#        output.writeFloat(self.startLocationLatitude)
#        output.writeFloat(self.startLocationLongitude)
#        output.writeInt(self.startLocationLatitudeIndex)
#        output.writeInt(self.startLocationLongitudeIndex)
#        output.writeFloat(self.endLocationLatitude)
#        output.writeFloat(self.endLocationLongitude)
#        output.writeInt(self.endLocationLatitudeIndex)
#        output.writeInt(self.endLocationLongitudeIndex)
#    
#    def __readamf__(self, input):
#        """Decoding of the information"""
#        self.hitPoints = input.readInt()
#        self.level = input.readInt()
#        self.user = input.readObject()
#        self.startLocationLatitude = input.readFloat()
#        self.startLocationLongitude = input.readFloat()
#        self.startLocationLatitudeIndex = input.readInt()
#        self.startLocationLongitudeIndex = input.readInt()
#        self.endLocationLatitude = input.readFloat()
#        self.endLocationLongitude = input.readFloat()
#        self.endLocationLatitudeIndex = input.readInt()
#        self.endLocationLongitudeIndex = input.readInt()
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
            self.endLocationLatitude = 0.0
            self.endLocationLongitude = 0.0
            self.endLocationLatitudeIndex = 0
            self.endLocationLongitudeIndex = 0
            self.location = db.GeoPt(self.startLocationLatitude, self.startLocationLongitude)
            self.update_location()
        else:
            self.endLocationLatitude = location.latitude
            self.endLocationLongitude = location.longitude
            self.endLocationLatitudeIndex = int(self.endLocationLatitude / Constants.latIndex())
            self.endLocationLongitudeIndex = int(self.endLocationLongitude / Constants.lonIndex())
            self.startLocationLatitude = 0.0
            self.startLocationLongitude = 0.0
            self.startLocationLatitudeIndex = 0
            self.startLocationLongitudeIndex = 0
            self.location = db.GeoPt(self.endLocationLatitude, self.endLocationLongitude)
            self.update_location()
    @classmethod
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
#    class __amf__:
#        external = True
#        amf3 = True
#        
#    def __writeamf__(self, output):
#        """Encoding of the information"""
#        output.writeInt(self.latIndex)
#        output.writeInt(self.lonIndex)
#        output.writeFloat(self.latitude)
#        output.writeFloat(self.longitude)
#    
#    def __readamf__(self, input):
#        """Decoding of the information"""
#        self.latIndex = input.readInt()
#        self.lonIndex = input.readInt()
#        self.latitude = input.readFloat()
#        self.longitude = input.readFloat()
    
    
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
#    class __amf__:
#        external = True
#        amf3 = True
#        
#    def __writeamf__(self, output):
#        """Encoding of the information"""
#        output.writeObject(self.southwestLocation)
#        output.writeObject(self.northeastLocation)
#    
#    def __readamf__(self, input):
#        """Decoding of the information"""
#        logging.error("Here")
#        self.southwestLocation = input.readObject()
#        self.northeastLocation = input.readObject()
    
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
    def createBoundsFromSimpleData(cls, SWLat, SWLon, NELat, NELon):
        """
        Convert the simple data into a bounds object
        """
        fBoundSouthWest = Location(latIndex = int(SWLat / Constants.latIndex()), lonIndex = int(SWLon / Constants.lonIndex()), 
                                   latitude = SWLat, longitude = SWLon)
        fBoundNorthEast =  Location(latIndex = int(NELat / Constants.latIndex()), lonIndex = int(NELon / Constants.lonIndex()), 
                                    latitude = NELat, longitude = NELon)
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
    