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
    
    