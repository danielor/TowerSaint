'''
Created on Sep 16, 2010

@author: danielo
'''
from google.appengine.ext import db


class User(db.Model):
    """The user of the game"""
    FacebookID = db.FloatProperty()
    Experience = db.IntegerProperty
    Empire = db.StringProperty()
    isEmperor = db.BooleanProperty()
    completeManaProduction = db.IntegerProperty()
    completeStoneProduction = db.IntegerProperty()
    completeWoodProduction = db.IntegerProperty()

class Road(db.Model):
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
    
class Tower(db.Model):
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
    
