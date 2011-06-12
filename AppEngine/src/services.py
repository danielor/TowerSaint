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
from models import GameChannel, PurchaseConstants
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
            
            # Set the state of the piece
            piece.setComplete()
            
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
        logging.error("Update Production")
        u = User.all().filter('FacebookID =', user.FacebookID).get()
        if init:
            u.totalMana = user.totalMana
            u.totalStone = user.totalStone
            u.totalWood = user.totalWood
        else:
            # How much time has passed?
            delta = user.productionDate - u.productionDate
            inSeconds = 60.
            totalNumberOfSecond = (delta.microseconds + (delta.seconds + delta.days * 24 * 3600) * 10**6) / 10**6
            totalNumberOfMinutes = float(totalNumberOfSecond / inSeconds)
            logging.error(str(u.totalMana) + ":" + str(u.totalStone) + ":" + str(u.totalWood))

            u.totalMana = int(u.totalMana + totalNumberOfMinutes * (u.completeManaProduction  )) 
            u.totalStone = int(u.totalStone + totalNumberOfMinutes * (u.completeStoneProduction))
            u.totalWood = int(u.totalWood + totalNumberOfMinutes * (u.completeWoodProduction ))
            logging.error(str(u.totalMana) + ":" + str(u.totalStone) + ":" + str(u.totalWood))

        # Save the user
        logging.error(str(u.completeManaProduction) + ":" + str(u.completeStoneProduction) + ":" + str(u.completeWoodProduction))
        u.completeManaProduction = user.completeManaProduction
        u.completeStoneProduction = user.completeStoneProduction
        u.completeWoodProduction = user.completeWoodProduction
        logging.error(str(u.completeManaProduction) + ":" + str(u.completeStoneProduction) + ":" + str(u.completeWoodProduction))
        logging.error(str(u.productionDate))
        logging.error(str(user.productionDate))
        u.productionDate = datetime.datetime.now()
        u.put()
        
        return True
    
    def buildObject(self, obj, user):
        """Build an object in the game. The state information is not relayed to everyone in the
        game because the building command does not imply the completion of the object. @func(
        buildObjectComplete) will relay the new object to all of the users."""
        logging.error("buildObject")
        # Save the object in the datastore
        u = User.all().filter("FacebookID =", user.FacebookID).get()
        obj.user = u
        obj.isComplete = False
        obj.foundingDate = datetime.datetime.now()
        
        # Tell geomodel where we are.
        obj.location = obj.getPosition()[0]
        obj.update_location()
        obj.put()
        
    def buildObjectCancel(self, oldobj, user):
        """Cancel a partially built object do it being destroyed or maually cancelled during
        construction"""
        u =  User.all().filter('FacebookID =', user.FacebookID).get()
        
        # Proximity fetch
        milesToMeters = 1609.4
        distance = Constants.getBaseDistance() * Constants.latToMiles() * milesToMeters
        
        # Find the build object
        cls = oldobj.getClass()
        query = cls.all().filter('isComplete =', False).filter('user =', u)
        obj = cls.proximity_fetch(query, oldobj.getPosition()[0], max_results = 1, max_distance = distance)
        if obj is None:
            logging.error("Unknown objects" + str(oldobj) + ":" + str(user))
            return
        if len(obj) == 0:
            for val in query.fetch(1000):
                logging.error(val.toXML())
                logging.error(val.location)
                logging.error(val.location_geocells)
            # Find out where the error is
            logging.error(str(distance))
            pt = oldobj.getPosition()
            pos = pt[0]
            logging.error(pt)
            logging.error(pos)
            return
            
        obj = obj[0]                # Get the first value of the fetch
        # Delete the built object
        obj.delete()            
        
    def buildObjectComplete(self, oldobj, user, broadcast):
        """Finish the object building"""
        logging.error("buildObjectComplete")
        u =  User.all().filter('FacebookID =', user.FacebookID).get()
        
        # Proximity fetch
        milesToMeters = 1609.4
        distance = Constants.getBaseDistance() * Constants.latToMiles() * milesToMeters
        
        # Find the build object
        cls = oldobj.getClass()
        query = cls.all().filter('isComplete =', False).filter('user =', u)
        pos = oldobj.getPosition()[0]
        obj = cls.proximity_fetch(query, pos, max_results = 1, max_distance = distance)
        if obj is None:
            logging.error("Unknown objects" + str(oldobj) + ":" + str(user))
            return
        if len(obj) == 0:
            for val in query.fetch(1000):
                logging.error(val.toXML())
                logging.error(val.location)
                logging.error(val.location_geocells)
            # Find out where the error is
            logging.error(str(distance))
            pt = oldobj.getPosition()
            pos = pt[0]
            logging.error(pt)
            logging.error(pos)
            return
        obj = obj[0]                # Get the first value of the fetch
        obj.isComplete = True
        obj.put()
        
        # Get the cost of the purchase.
        woodCost = PurchaseConstants.getWoodCost(obj, 0)
        stoneCost = PurchaseConstants.getStoneCost(obj, 0)
        manaCost = PurchaseConstants.getManaCost(obj, 0)
        
        # Update the resources
        currentTime = datetime.datetime.now()
        inSeconds = 60.
        delta = currentTime - u.productionDate
        totalNumberOfSecond = (delta.microseconds + (delta.seconds + delta.days * 24 * 3600) * 10**6) / 10**6
        totalNumberOfMinutes = float(totalNumberOfSecond / inSeconds)
        logging.error(str(woodCost) + ":" + str(stoneCost) + ":" + str(manaCost))
        logging.error(str(u.totalMana) + ":" + str(u.totalStone) + ":" + str(u.totalWood))
        u.totalMana = int(u.totalMana + totalNumberOfMinutes * (u.completeManaProduction ) - woodCost)
        u.totalStone = int(u.totalStone + totalNumberOfMinutes *(u.completeStoneProduction ) - stoneCost)
        u.totalWood = int(u.totalWood + totalNumberOfMinutes * (u.completeWoodProduction ) - manaCost)
        logging.error(str(u.totalMana) + ":" + str(u.totalStone) + ":" + str(u.totalWood))
        u.productionDate = currentTime
        u.put()             # Save the updated resources
        
        # Find out objects in the proximity
        for gameObject in [Portal, Tower, Road]:
            # Filter out users that are already part of the neighbor list
            whichObject = gameObject.all().filter('user !=', u)
            for key in u.neighbors:
                neighbor = db.get(key)
                whichObject.filter('user !=', neighbor)
            
          
            for pos in obj.getPosition():
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
        if broadcast:            
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
        logging.error(str("\n".join([j.toXML() for j in retList])))
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
        
        
        # Find if their is a tower distance away from the pt. If there is even one object, this
        # function will return  a value, and make satisfiesMinimumDistance false.
        for level in Tower.getTowerLevelRange():
            filter = Tower.all().filter('Level =', level)
            box = Constants.getBoundingBoxPerLevel(level, pt)
            value = Tower.bounding_box_fetch(filter, box, max_results = 1)
            logging.error(len(value))
            if len(value) != 0:
                return False
        return True
        
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

    
    