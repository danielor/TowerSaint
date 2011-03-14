'''
Created on Jan 4, 2011
Sessions acts as the interfaces between collections of users over
the google app engine channel api. Sessions are defined for chat,
passive, and active game operation
@author: danielo
'''
import logging
from django.utils import simplejson
from google.appengine.api import channel
from google.appengine.ext import db
from google.appengine.api import memcache
from models import Constants

def getChannelBaseString():
    return "TowerSaint"

class JsonProperty(db.TextProperty):
    """
    The json property stores json encoded information into the
    google datastore
    """
    def validate(self, value):
        return value

    def get_value_for_datastore(self, model_instance):
        result = super(JsonProperty, self).get_value_for_datastore(model_instance)
        result = simplejson.dumps(result)
        return db.Text(result)

    def make_value_from_datastore(self, value):
        try:
            value = simplejson.loads(str(value))
        except:
            pass

        return super(JsonProperty, self).make_value_from_datastore(value)

class ChannelState(db.Model):
    """
    The channel state keeps all of the information associated with 
    the shared state in a single variable
    """
    state = JsonProperty()                              # The data in the channel
    manager = db.TextProperty()                         # The manager associated with the state

class GlobalManager(object):
    """
    A global manager is a  sessions class, which requires the global user state(all of the users).
    All manager that need broadcasting capabilities should inherit this class
    channelId - The global channel identifier
    users - ChannelState object
    """
    def __init__(self):
        """Load all of the data from the channel state"""
        # The channel id
        self.channelId = getChannelBaseString()
        
        # Get the state
        client = memcache.Client()
        state = client.get("users")
        if isinstance(state, db.Query):
            state = state.get()
         
        # The id associated with the manager
        if state is not None:
            self.state = state
        else:
            # Get the user state
            state = self.getUserState()
            logging.error(state)
            
            # Save the state upon cache failure
            if state:
                self.state = state
            else:
                self.state = ChannelState(state={}, manager="users")
            
            if not client.set("users", self.state):
                logging.error("Memcache failed in UserManager")
                
    # The Base string associated with the channel
    def getUserState(self):
        """Perform a gql query and return the state associated with the"""
        return ChannelState.all().filter("manager =", "users").get()

class GameManager(object):
    """
    There is a one to one relationship between the game manager, and a user.
    Using the proximity features of geomodel, we add users that are "close"
    to the user(as in visible, which implies within the distance of the zoom
    level associated with the game). When a game move is performed, the
    update is *only* sent to these neighbors. The idea being that by using
    a proximity graph the load on the server will be greatly decreased.
    """
    def __init__(self, user):
        """
        user - The user making the move in the game
        """
        self.user = user
        
    def build(self, obj):
        """
        Build an object(Tower, Portal, etc.) in the game
        """
        channelId = getChannelBaseString()
        buildMessage = {'BUILD' :{'alias' : self.user.alias, 'buildObject' : obj.toJSON()}}
        
        # Send it to the neighbors
        for key in self.user.neighbors:
            u = db.get(key)
            channel.send_message(channelId + u.alias, simplejson.dumps(buildMessage))
        
        # Send it to the self
        buildOwnerMessage = {'BUILD' : {'alias' : self.user.alias, 'buildObject' : obj.toCompleteJSON()}}
        channel.send_message(channelId + self.user.alias,simplejson.dumps(buildOwnerMessage))
        
class UserManager(GlobalManager):
    """
    The user manager is a borg. All instances of this manager
    have the same state. The user manager keeps a tab of all
    users logged into the application. It will send messages to 
    all logged in users upon login/logout of any other user using
    the channel api. The borg state is enforced by the datastore/
    memcache
    """
    def __init__(self):
        """Load all of the data from the channel state"""
        GlobalManager.__init__(self)
    
    def loginUser(self, user):
        """Add a user to the user list"""
        # Get the state and id
        channelId = self.channelId  
        level = Constants.levelFromExperience(user)  
        jsonState = self.state
        jsonState.state[user.alias] = level
    
        # The key value pair
        addMessage = {"LOGIN": {'alias' : user.alias, 'level' : level }}
        
        # Login in the user on all of the channels
        for alias, _ in jsonState.state.iteritems():
            # Everyone except the user logging in
            if user.alias != alias:
                channel.send_message(channelId + alias, simplejson.dumps(addMessage))
        
        # Send the current state to the addMessage
        allState = {'LOGIN' : [{'alias': alias, 'level':level} for alias, level in jsonState.state.iteritems()]}
        message = simplejson.dumps(allState)
        channel.send_message(channelId + user.alias,message)
        
        # Save the object
        self.state.put()
        
        # Cache 
        client = memcache.Client()
        if not client.replace("users", self.state):
            if not client.set("users", self.state):
                logging.error("Memcache failed in UserManager")
        
    def logoutUser(self, user):
        """Logout the user and broadcast to all other users"""
        # Get the state and id
        channelId = self.channelId   
        jsonState = self.state 
        level = Constants.levelFromExperience(user)
        del jsonState.state[user.alias]
    
        # The key value pair
        addMessage = {"LOGOUT": {'alias' : user.alias, 'level' : level }}
        
        # Login in the user on all of the channels
        for alias, _ in jsonState.state.iteritems():
            # Everyone except the user logging in
            if user.alias != alias:
                channel.send_message(channelId + alias, simplejson.dumps(addMessage))
        
        
        # Save the object
        self.state.put()
        
        # Cache 
        client = memcache.Client()
        if not client.replace("users", self.state):
            if not client.set("users", self.state):
                logging.error("Memcache failed in UserManager")
        
    
class ChatManager(GlobalManager):
    """
    The chat manager does not alter the state, but broadcasts all of the
    information through the channel information
    """
    def __init__(self):
        GlobalManager.__init__(self)
        
    def sendMessage(self, message, user):
        """
        Send the chat message to all of the users
        message - A string to be sent in the chat
        user - The user who sent the message.
        """
        channelId = self.channelId
        jsonState = self.state
        
        # The message to send to everyone
        jMsg = simplejson.dumps({"MESSAGE" : {'user' : user.alias, 'message' : message}})
        
        # Iterate over all of the channels
        for alias, _ in jsonState.state.iteritems():
            channel.send_message(channelId + alias, jMsg)
        