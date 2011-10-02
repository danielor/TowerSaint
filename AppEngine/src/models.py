'''
Created on Sep 16, 2010

Note 1:
It should be noted that the order of the __readamf__, and __writeamf__ functions
are important. The flex, and gae must be consistent.

@author: danielo
'''
from google.appengine.ext import db
import logging, random, string, datetime
from math import fabs, pow
from xml.etree import cElementTree as cTree
from geomodel.geomodel import GeoModel
from geomodel.geotypes import Box

def createRandomString(length = 10):
    """Create the random string"""
    return "".join([random.choice(string.letters) for _ in range(length)])


"""
A class full of constans used to purchase items
"""
class PurchaseConstants(object):
    
    @classmethod
    def getWoodCost(cls, obj, level):
        """
        Return the cost of build/upgrading an object in the game
        """
        if isinstance(obj, Tower):
            return PurchaseConstants.getTowerWoodCost(level)
        elif isinstance(obj, Portal):
            return PurchaseConstants.getPortalWoodCost(level)
        elif isinstance(obj, Road):
            return PurchaseConstants.getRoadWoodCost(level)
        else: 
            return 0.0;
    
    @classmethod
    def getTowerWoodCost(cls, level): 
        """Get the wood cost for a tower"""
        return pow(10, 2 * level) * 1000;
    
    @classmethod
    def getPortalWoodCost(cls, level):
        """Get the wood cost for a portal"""
        return pow(10, level) * 500;
    
    @classmethod
    def getRoadWoodCost(cls, level):
        """Get the wood cost of a road""" 
        return pow(10, level) * 250;
    
    @classmethod
    def getStoneCost(cls, obj, level):
        """
        Return the cost of build/upgrading an object in the game
        """
        if isinstance(obj, Tower):
            return PurchaseConstants.getTowerStoneCost(level)
        elif isinstance(obj, Portal):
            return PurchaseConstants.getPortalStoneCost(level)
        elif isinstance(obj, Road):
            return PurchaseConstants.getRoadStoneCost(level)
        else: 
            return 0.0;
        
    @classmethod
    def getTowerStoneCost(cls, level): 
        """Get the wood cost for a tower"""
        return pow(10, 2 * level) * 1000;
    
    @classmethod
    def getPortalStoneCost(cls, level):
        """Get the wood cost for a portal"""
        return pow(10, level) * 500;
    
    @classmethod
    def getRoadStoneCost(cls, level):
        """Get the wood cost of a road""" 
        return pow(10, level) * 250;
    
    @classmethod
    def getManaCost(cls, obj, level):
        """
        Return the cost of build/upgrading an object in the game
        """
        if isinstance(obj, Tower):
            return PurchaseConstants.getTowerManaCost(level)
        elif isinstance(obj, Portal):
            return PurchaseConstants.getPortalManaCost(level)
        elif isinstance(obj, Road):
            return PurchaseConstants.getRoadManaCost(level)
        else: 
            return 0.0;
        
    @classmethod
    def getTowerManaCost(cls, level): 
        """Get the wood cost for a tower"""
        return pow(10, 2 * level) * 1000;
    
    @classmethod
    def getPortalManaCost(cls, level):
        """Get the wood cost for a portal"""
        return pow(10, level) * 500;
    
    @classmethod
    def getRoadManaCost(cls, level):
        """Get the wood cost of a road""" 
        return 0.0

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
    def getBoundingBoxPerLevel(cls, klass, position):
        """Return the maximum bounding box around a position"""
        influence = Constants.maxInfluence(klass)
        
        # These offsets are approximate sizes that come from a initial tower's boundary (Level 0)
        lonOffset = .002 / 2.
        latOffset = .003 / 2.
        
        return Box(position.lat + influence *latOffset, position.lon + influence * lonOffset, 
                   position.lat - influence *latOffset, position.lon - influence * lonOffset)
    
    @classmethod
    def getGameObjects(cls):
        """Return the game objects"""
        return [Tower, Portal, Road]
    
    @classmethod
    def lonIndex(cls):
        """The distance between longitude lattice points"""
        return .001
    
    @classmethod
    def getBaseDistance(cls):
        """Returns the base distance of the map"""
        return .013
    
    @classmethod
    def getBaseZoomLevel(cls):
        """Returns the zoom level associated with the map"""
        return 16
    
    @classmethod
    def getMapPixelWidth(cls):
        """The width of the map in pixels"""
        return 619
    
    @classmethod
    def getMapPixelHeight(cls):
        """The height of the map in pixels"""
        return 419
    
    
    @classmethod
    def maxInfluence(cls, klass):
        """The maximum influence(in lattice points) any object can have"""
        # Tower objects are handled differently because they have a boundary
        if isinstance(klass, Tower) or isinstance(klass, int):
            if isinstance(klass, int):
                level = klass
            else:
                level = klass.Level
            if level == 0:
                return 1.
            elif level == 1:
                return 2.
            elif level == 2:
                return 4.
            elif level == 3:
                return 8.
        else:
            return .2           # The approximate size of the object on the map(.2 *(.002, .003))
    
    @classmethod
    def minInfluence(cls):
        """The minimum influence(in lattice points) any object can have"""
        return 3
    
    @classmethod
    def latToMiles(cls):
        """Converts a latitude constant to miles"""
        return 69
    
    @classmethod
    def levelFromExperience(cls, u):
        """Get the level from the experience of a user"""
        return u.Experience / 1000
    

class GameChannel(db.Model):
    """Tokens sent to the user to the user to run the relevant javascript clients"""
    token = db.StringProperty()

class User(db.Model):
    """The user of the game"""

    # AMF/XML information    
    FacebookID = db.IntegerProperty()
    Experience = db.IntegerProperty()
    Empire = db.StringProperty()
    isEmperor = db.BooleanProperty()
    completeManaProduction = db.IntegerProperty()
    completeStoneProduction = db.IntegerProperty()
    completeWoodProduction = db.IntegerProperty()
    totalMana = db.IntegerProperty()                                    # The total mana harvested
    totalStone = db.IntegerProperty()                                   # The total stone mined 
    totalWood = db.IntegerProperty()                                    # The total wood cut
    productionDate = db.DateTimeProperty()                              # The date, and time when the production changed last
    alias = db.StringProperty()
    neighbors = db.ListProperty(db.Key)                                 # A list of keys to users that are close 
    
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
                    <alias>%s</alias>
                 </User>""" % (self.FacebookID, self.completeWoodProduction, self.completeStoneProduction,
                               self.completeManaProduction, self.isEmperor, self.Empire, self.Experience,
                               self.alias)

    def toJSON(self):
        """Get the json equivalent of the model. The JSON should be consistent throughout
        all of the models"""
        return {"Class" : "User", "Value" : {'alias' : self.alias}}
    

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

    @classmethod
    def getClass(cls):
        """Return the class object of the object"""
        return cls
    
    def setComplete(self):
        """Set the complete state to true"""
        self.isComplete = True
        self.foundingDate = datetime.datetime.now()
        
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
    isComplete = db.BooleanProperty()
    foundingDate = db.DateTimeProperty()
    
    # A Reference to the user
    user = db.ReferenceProperty(User)
    
    # The latitude and longitude associated with the objects
    startLatitude = db.FloatProperty() 
    startLongitude = db.FloatProperty()
    endLatitude = db.FloatProperty()
    endLongitude = db.FloatProperty()
    
   
    @classmethod
    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("latIndex", "lonIndex")]
    
    def toXML(self):
        """Return an xml representation of the google app engine model"""
        if self.user is not None:
            userString = self.user.toXML()
        else:
            userString = ""
        
        return """<Road>
                    <hitpoints>%s</hitpoints>
                    <level>%s</level>
                    <startlatitude>%s</startlatitude>
                    <startlongitude>%s</startlongitude>
                    <endlatitude>%s</endlatitude>
                    <endlongitude>%s</endlongitude>
                    <isComplete>%s</isComplete>
                    %s
                  </Road>""" %(self.hitPoints, self.level, self.startLatitude, self.startLongitude,
                               self.endLatitude, self.endLongitude, self.isComplete, userString)

    def toJSON(self):
        """Get the json equivalent of the model. The JSON should be consistent throughout
        all of the models"""
        return {"Class" : "Road", "Value" : {'level' : self.level,
                                             'startlatitude' : self.startLatitude,
                                             'endlatitude' : self.endLatitude,
                                             'startlongitude' : self.startLongitude,
                                             'endlongitude' : self.endLongitude,
                                             'user' : self.user.toJSON()}}
        
    def toCompleteJSON(self):
        """Get the complete json equivalent of the model. This object is sent only to the users
        that own the object"""
        return {"Class" : "Road", "Value" : {'level' : self.level,
                                             'hitpoints' : self.hitPoints,
                                             'startlatitude' : self.startLatitude,
                                             'endlatitude' : self.endLatitude,
                                             'startlongitude' : self.startLongitude,
                                             'endlongitude' : self.endLongitude,
                                             'iscomplete' : self.isComplete,
                                             'user' : self.user.toJSON()}}

    def setRandomlyInBounds(self, bounds):
        """
        Setup an object randomly in some model.Bounds
        """
        location = bounds.createRandomLocationInBounds()
        self.startLatitude = location.latitude
        self.startLongitude = location.startLongitude
        self.latIndex = int(self.startLatitude / Constants.latIndex())
        self.lonIndex = int(self.startLongitude / Constants.lonIndex())
        self.location = db.GeoPt(self.startLatitude, self.startLongitude)
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
    
    def getPosition(self):
        """Returns a list of positions associated with this object"""
        return [db.GeoPt(self.startLatitude, self.startLatitude), db.GeoPt(self.endLatitude, self.endLongitude)]
    
class Tower(GeoModel, BoundsPlugin):
#class Tower(db.Model):
    """The tower object integrates with AMF"""

#    class __amf__:
#        external = True
#    
#    def __readamf__(self, i):
#        self.readAMF(i)
#    def __writeamf__(self, o):
#        self.writeAMF(o)
#    
#    def writeAMF(self, output):
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
#        output.writeObject(self.foundingDate)
#        
#    def readAMF(self, input):
#        """Decoding of the information"""
#        logging.error("Iam here")
#        logging.error(str(input))
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
#        self.manaProduction = input.readInt()
#        self.stoneProduction = input.readInt()
#        self.woodProduction = input.readInt()
#        self.Level = input.readInt()
#        self.latIndex = input.readInt()
#        self.lonIndex = input.readInt()
#        self.latitude = input.readFloat()
#        self.longitude = input.readFloat()
#        self.foundingDate = input.readObject()
        
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
    isComplete = db.BooleanProperty()
    hasRuler = db.BooleanProperty()
    foundingDate = db.DateTimeProperty()

    
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
    
    @classmethod
    def getTowerLevelRange(cls):
        """Returns the tower level ranges"""
        return [3, 2, 1, 0]
    
    def toXML(self):
        """Return an xml representation of the google app engine model"""
        if self.user is not None:
            userString = self.user.toXML()
        else:
            userString = ""
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
                    <isComplete>%s</isComplete>
                    %s
                  </Tower>""" % (self.Experience, self.Speed, self.Power, self.Armor, self.Range,
                                 self.Accuracy, self.HitPoints, self.isIsolated, self.isCapital,
                                 self.hasRuler, self.Level, self.manaProduction, self.stoneProduction,
                                 self.woodProduction, self.latitude, self.longitude, self.isComplete,
                                 userString)

    def toJSON(self):
        """Get the json equivalent of the model. The JSON should be consistent throughout
        all of the models"""
        return {"Class" : "Tower", "Value" : {"level" : self.Level,
                                             'latitude' : self.latitude,
                                             'longitude' : self.longitude,
                                             'user' : self.user.toJSON()}}
        
    def toCompleteJSON(self):
        """Get the complete json equivalent of the model. This object is sent only to the users
        that own the object"""
        return {"Class" : "Tower", "Value" : {"experience" : self.Experience, "speed" : self.Speed,
                                             "power" : self.Power, "armor" : self.Armor,
                                             "range" : self.Range, "accuracy" : self.Accuracy,
                                             "hitpoints" : self.HitPoints, "isisolated" : self.isIsolated,
                                             "iscapital" : self.isCapital, "hasruler" : self.hasRuler,
                                             "level" : self.Level, "manaproduction" : self.manaProduction,
                                             "stoneproduction" : self.stoneProduction, 'woodproduction' : self.woodProduction,
                                             'latitude' : self.latitude,'longitude' : self.longitude,
                                             'iscomplete': self.isComplete,  'user' : self.user.toJSON()}}

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
    
    def getPosition(self):
        """Returns a list of positions associated with this object"""
        return [db.GeoPt(self.latitude, self.longitude)]

class Portal(GeoModel, BoundsPlugin):
    """The portal objects integrates with AMF"""

    # Descriptive
    hitPoints = db.IntegerProperty()
    level = db.IntegerProperty()
    isComplete = db.BooleanProperty()
    foundingDate = db.DateTimeProperty()

    # A Reference to the user
    user = db.ReferenceProperty(User)
    
    # The start/end location of the portal
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    
    def setRandomlyInBounds(self, bounds):
        """
        Setup an object randomly in some model.Bounds
        """
        location = bounds.createRandomLocationInBounds()
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.location = db.GeoPt(self.latitude, self.longitude)
        self.update_location()
   
            
    def toJSON(self):
        """Get the json equivalent of the model. The JSON should be consistent throughout
        all of the models"""
        return {"Class" : "Portal", "Value" : {'level' : self.level,
                                             'latitude' : self.latitude,
                                             'longitude' : self.longitude,
                                             'user' : self.user.toJSON()}}
    def toCompleteJSON(self):
        """Get the complete json equivalent of the model. This object is sent only to the users
        that own the object"""
        return {"Class" : "Portal", "Value" : {'level' : self.level,
                                             "hitpoints" : self.hitPoints,
                                             'latitude' : self.latitude,
                                             'longitude' : self.longitude,
                                             'iscomplete' : self.isComplete,
                                             'user' : self.user.toJSON()}}
    
    @classmethod
    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("startLocationLatitudeIndex", "startLocationLongitudeIndex"),
                ("endLocationLatitudeIndex", "endLocationLongitudeIndex")]

    def toXML(self):
        """Return an xml representation of the google app engine model"""
        if self.user is not None:
            userString = self.user.toXML()
        else:
            userString = ""
        return """<Portal>
                    <hitpoints>%s</hitpoints>
                    <level>%s</level>
                    <latitude>%s</latitude>
                    <longitude>%s</longitude>
                    <isComplete>%s</isComplete>
                    %s
                  </Portal>""" %(self.hitPoints, self.level, self.latitude,
                                 self.longitude,self.isComplete, userString)

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
    
    def getPosition(self):
        """Returns a list of positions associated with this object"""
        return [db.GeoPt(self.latitude, self.longitude)]
    
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
    
    def asBox(self):
        """Return a box(geotypes.Box representation for a bounding_box_fetch"""
        return Box(self.northeastLocation.latitude, self.northeastLocation.longitude,  
                   self.southwestLocation.latitude, self.southwestLocation.longitude)
    
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
    