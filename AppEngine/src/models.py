'''
Created on Sep 16, 2010

@author: danielo
'''
from google.appengine.ext import db
import logging
from math import fabs
from constants import Constants

class User(db.Model):
    """The user of the game"""
    FacebookID = db.FloatProperty()
    Experience = db.IntegerProperty
    Empire = db.StringProperty()
    isEmperor = db.BooleanProperty()
    completeManaProduction = db.IntegerProperty()
    completeStoneProduction = db.IntegerProperty()
    completeWoodProduction = db.IntegerProperty()

class FilterPlugin(object):
    """
    The filter plugin adds filter functionality to all of the model object.
    Static methods will be inherited by all of children methods
    """
    @staticmethod
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


class Road(db.Model, FilterPlugin):
    """The road object integrates with AMF"""
    # Descriptive
    hitPoints = db.IntegerProperty()
    level = db.IntegerProperty()
    
    # The index represesents the lattice site on the map
    latIndex = db.IntegerProperty()
    lonIndex = db.IntegerProperty()
    
    # The geolocation
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    
    # A Reference to the user
    user = db.ReferenceProperty(User)
    
    # The latitude and longitude associated with the objects
    lonIndex = db.IntegerProperty()
    latIndex = db.IntegerProperty()
    latitude = db.IntegerProperty() 
    longitude = db.IntegerProperty()

    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("latIndex", "lonIndex")]

class Tower(db.Model, FilterPlugin):
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
    latitude = db.IntegerProperty() 
    longitude = db.IntegerProperty()
    
    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("latIndex", "lonIndex")]
    
class Portal(db.Model):
    """The portal objects integrates with AMF"""
    # Descriptive
    hitPoints = db.IntegerProperty()
    level = db.IntegerProperty()
    
    # The start location
    startLocationLatitude = db.FloatProperty()
    startLocationLongitude = db.FloatProperty()
    startLocationLatitudeIndex = db.IntegerProperty()
    startLocationLongitudeIndex = db.IntegerProperty()
            
    # The end location
    endLocationLatitude = db.FloatProperty()
    endLocationLongitude = db.FloatProperty()
    endLocationLatitudeIndex = db.IntegerProperty()
    endLocationLongitudeIndex = db.IntegerProperty()
    
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
    
    def getLocationIndex(self):
        """Get the lat/lon indices"""
        return [("startLocationLatitudeIndex", "startLocationLongitudeIndex"),
                ("endLocationLatitudeIndex", "endLocationLongitudeIndex")]

class Location(db.Model):
    """The location object integrates with AMF"""
    # The index represesents the lattice site on the map
    latIndex = db.IntegerProperty()
    lonIndex = db.IntegerProperty()
    
    # The geolocation
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    

class Bounds(db.Model):
    """The bound object integrates with AMF"""
    southwestLocation = db.ReferenceProperty(Location, collection_name ="southwestCollection")
    northeastLocation = db.ReferenceProperty(Location, collection_name = "northeastCollection")
    
    def getArea(self):
        """Returns the are of the bounds"""
        width = fabs(self.northeastLocation.longitude - self.southwestLocation.longitude)
        height = fabs(self.southwestLocation.latitude - self.northeastLocation.latitude)
        return width * height
    
    @staticmethod
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
        fBoundSouthWest = Location(min(latitudeList), max(latitudeList))
        fBoundNorthEast = Location(min(longitudeList), max(longitudeList))
        
        # Return a Bounds objects
        return Bounds(fBoundSouthWest, fBoundNorthEast)
    
    @staticmethod
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