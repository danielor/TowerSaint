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
    channelId = db.TextProperty()                       # The channel id

class UserManager(object):
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
        client = memcache.Client()
        state = client.get("users")
        
        # The id associated with the manager
        
        if state is not None:
            self.state = state
        else:
            # Get the user state
            state = self.getUserState()
            
            # Save the state upon cache failure
            if state:
                self.state = state
            else:
                self.state = ChannelState(state={}, manager="users", channelId = "users")
            
            if not client.set("users", self.state):
                logging.error("Memcache failed in UserManager")
    
    def getUserState(self):
        """Perform a gql query and return the state associated with the"""
        return ChannelState.all().filter("manager =", "UserManager")
    
    def loginUser(self, user):
        """Add a user to the user list"""
        # Get the state and id
        channelId = self.state.channelId    
        self.state.state[user.alias] = user.level
    
        # The key value pair
        addMessage = {"ADD": {'alias' : user.alias, 'level' : user.level }}
        channel.send_message(channelId + user.alias, addMessage)
        
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
        channelId = self.state.channelId    
        del self.state.state[user.alias]
    
        # The key value pair
        addMessage = {"REMOVE": {'alias' : user.alias, 'level' : user.level }}
        channel.send_message(channelId + user.alias, addMessage)
        
        # Save the object
        self.state.put()
        
        # Cache 
        client = memcache.Client()
        if not client.replace("users", self.state):
            if not client.set("users", self.state):
                logging.error("Memcache failed in UserManager")
        
    def getAllUsers(self, user):
        """Upon initialization of the game get all current users of the game"""
        channelId = self.state.channelId
        
        # The add message
        addMessage = {"ADD" : self.state}
        channel.send_message(channelId + user.alias, addMessage)
    
class ChatManager(object):
    """
    The chat manager is a borg. All instances of this manager
    has the same state. The chat manager handles the one chat room.
    """
    _shared_state = {}
    def __init__(self):
        self.__dict__ = self._shared_state