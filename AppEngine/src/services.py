'''
Created on Sep 17, 2010

@author: danielo
'''
from google.appengine.ext import db 
from google.appengine.api import channel
import pyamf, random, string, logging, datetime
from pyamf import amf3
from pyamf.flex import ArrayCollection, ObjectProxy
from models import User, Road, Tower, Portal, Location, Bounds, Constants
from models import GameChannel
from geomodel.geomodel import GeoModel
from sessions import UserManager, ChatManager, GameManager
    
class TowerSaintManager(object):
    def __init__(self):
        self.numberOfObjectsPerBound = 5
        # Delete all objects in the database
        #self.deleteAllObjects()
    
    def getObjectInBounds(self, latlng):
        """Get the object within the latlng bounds of {latlng}"""
        logging.error(latlng)
        # Create the objects
        b = Bounds.createBoundsFromAMFData(latlng)
        # The list of road
        listOfObjects = []
        for obj in [Road, Portal, Tower]:
            for _ in range(self.numberOfObjectsPerBound):
                
                # Create the road
                o = obj.createRandomObjectInBounds(b)
                
                # The proxy
                listOfObjects.append(o)
        
        return ArrayCollection(listOfObjects)
        
    def saveUserObjects(self, objects, user):
        """Save user objects"""

        u =  User.all().filter('FacebookID =', user.FacebookID).get()
        for piece in objects:
            # Save the user reference
            piece.user = u
            logging.error(piece)
            
            # Put the user
            piece.put()
            
    def getAllActiveUsers(self):
        """Return all active users"""
        return ArrayCollection([{'alias': u.alias, 'level' : Constants.levelFromExperience(u)} for u in User.all().filter('isLoggedIn =', True).fetch(1000)])
        
    def setUserAlias(self, user, alias):
        """Set the alias associated with the user"""
        u = User.all().filter('FacebookID =', user.FacebookID).get()
        if not u:
            return False
        else:
            
            # Make sure that the alias is unique
            aU = User.all().filter('alias =', alias).get()
            if not aU:
                u.alias = alias
                u.put()
                return True
            else:
                return False
        return False
    
    def getCurrentUser(self, user):
        """Save the users"""
        def __getCurrentUser(cU):
            """
            cU - the user that will be returned
            """
            cU.put()
            return cU
        # Get the user with id. Makes sure that only one user is created
        # with the associated id.
        u = User.all().filter('FacebookID =', user.FacebookID).get()
       
        # Setup the login characeteristics
        if u:
            return __getCurrentUser(u)
        else:
            return __getCurrentUser(user)
    
    def updateProduction(self, user, init):
        """Update the global production variables of an empire. The function
        should be called from the client upon build events, destroy events,
        and on the initialization of the empire"""
        # Get the user with id. Makes sure that only one user is created
        # with the associated id.
        u = User.all().filter('FacebookID =', user.FacebookID).get()
        if init:
            u.totalMana = user.totalMana
            u.totalStone = user.totalStone
            u.totalWood = user.totalWood
        else:
            # How much time has passed?
            delta = user.productionDate - u.productionDate
            totalNumberOfSecond = (delta.microseconds + (delta.seconds + delta.days * 24 * 3600) * 10**6) / 10**6
            totalNumberOfMinutes = float(totalNumberOfSecond / 60.0)
            u.totalMana = u.totalMana + totalNumberOfMinutes * u.completeManaProduction
            u.totalStone = u.totalStone + totalNumberOfMinutes * u.completeStoneProduction
            u.totalWood = u.totalWood + totalNumberOfMinutes * u.completeWoodProduction

        # Save the user
        u.completeManaProduction = user.completeManaProduction
        u.completeStoneProduction = user.completeStoneProduction
        u.completeWoodProduction = user.completeWoodProduction
        u.productionDate = datetime.datetime.now()
        u.put()
        
        return True
    
    def buildObject(self, obj, user):
        """Build an object in the game"""
        # Save the object in the datastore
        u =  User.all().filter('FacebookID =', user.FacebookID).get()
        obj.user = u
        obj.put()
        
        logging.error("Inside")
        # Find out objects in the proximity
        for gameObject in [Portal, Tower, Road]:
            # Filter out users that are already part of the neighbor list
            whichObject = gameObject.all().filter('user !=', u)
            for key in u.neighbors:
                neighbor = db.get(key)
                whichObject.filter('user !=', neighbor)
            
            # Proximity fetch
            distance = Constants.getBaseDistance() * Constants.latToMiles()
            for pos in gameObject.getPosition():
                valueList = gameObject.proximity_fetch(whichObject, pos, max_results = 1000, max_distance = distance)
                if valueList is not None:
                    # Iterate over the results
                    for obj in valueList:
                        otherUser = obj.user
                        if not otherUser in u.neighbors:
                            # Add to both neighbors
                            u.neighbors.append(otherUser.key())
                            otherUser.neighbors.append(u.key())
                            otherUser.put()
        # Put the current user
        u.put()
        
        # Instantiate the game manager, and build the object                    
        manager = GameManager(u)
        manager.build(obj)
        return None
    
    def getUserObjects(self, user):
        """Get all game objects associated with a user"""
        retList = []

        # Get the datastore user 
        u = User.all().filter('FacebookID =', user.FacebookID).get()
        
        # Get all objects associated with the user
        for cls in [Tower, Portal, Road]:
            query =  cls.all().filter('user =', u)
            retList.extend([value for value in query.fetch(1000)])
        return ArrayCollection(retList)
    
    def initGameChannels(self, user):
        """Initialize the game channels for game, chat, and user upates""" 
        # Setup all the channels
        uM = UserManager()
        channelId = uM.channelId
        
        # Setup the channel
        token = channel.create_channel(channelId + user.alias)
    
        # Return the channel associated with the 
        ch = GameChannel()
        ch.token = token
        
        # Return arraycollection
        return ObjectProxy({'token' : token})
    
    def loginUserToGame(self, user):
        """The login user to the game with the game channels"""
        # The user manager
        um = UserManager()
        
        # Get the datastore user 
        u = User.all().filter('FacebookID =', user.FacebookID).get()
        
        # Login the user. Send the login data to all of the users
        # and the current login state for the user.
        um.loginUser(u)
        return True
    
    def closeGame(self, user):
        """Close all of the game channels and tell the users that user is logged off"""
        # Get the channels and close them
        um = UserManager()

        # Get the datastore user 
        u = User.all().filter('FacebookID =', user.FacebookID).get()
        um.logoutUser(u)
        return True
    
    def sendMessage(self, user, message):
        """Send message from user to everyone logged in to the server"""
        cm = ChatManager()
        
        # Send the message and return
        cm.sendMessage(message, user)
        return True
        
    def satisfiesMinimumDistance(self, latlng):
        """If the tower satisfies the minimum distance from other towers, then it is true"""
        pt = db.GeoPt(latlng['latitude'], latlng['longitude'])
        distance = Constants.minInfluence() * Constants.latIndex() * Constants.latToMiles()
        
        # Find if their is a tower distance away from the pt. If there is even one object, this
        # function will return  a value, and make satisfiesMinimumDistance false.
        value = Tower.proximity_fetch(Tower.all(), pt, max_results = 1, max_distance = distance)
        return value is None
        
    def deleteAllObjects(self):
        """Remove all objects in the database"""
        for cls in [Bounds, User, Road, Portal, Tower, Location]:
            query = cls.all()
            for obj in query.fetch(1000):           # For intial testing it would be rare for their to be more than 1000
                obj.delete()

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
    pyamf.register_class(GameChannel, "%s.GameChannel" % AMF_NAMESPACE)

    
    