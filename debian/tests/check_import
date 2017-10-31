#!/usr/bin/env python3

import gi
gi.require_version('Budgie', '1.0')
from gi.repository import Budgie
import sys

x=Budgie.Applet.new()


# test if the applet can be initialised.  This tells us if
# the (re)build has correctly been done
if (type(x).__name__ == 'Applet'):
    sys.exit(0)
else:
    sys.exit(1)
