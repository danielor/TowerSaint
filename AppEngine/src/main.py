#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import logging

from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from pyamf.remoting.gateway.google import WebAppGateway
from services import TowerService, PortalService, RoadService
from services import register_classes
from pages import BoundsPage

class MainPage(webapp.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('Hello, webapp World!')


def echo(data):
    return data


def main():
    debug_enabled = True

    services = {
        'myservice.echo': echo,
        'tower' : TowerService(),
        'portal' : PortalService(),
        'road' : RoadService(),
    }

    # Register the classes in the AMF namespace
    register_classes()
    
    # Create a gateway to the amf services
    gateway = WebAppGateway(services, logger=logging, debug=debug_enabled)

    application_paths = [('/', gateway), ('/helloworld', MainPage), ('/bunds', BoundsPage)]
    application = webapp.WSGIApplication(application_paths, debug=debug_enabled)

    run_wsgi_app(application)


if __name__ == '__main__':
    main()
