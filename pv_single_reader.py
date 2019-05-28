#!/usr/bin/python

import os
import sys
from paraview.simple import *

datadir = str(os.environ.get('MOVIEDIR'))
datatype = str(os.environ.get('DATATYPE'))
numframes = int(os.environ.get('NUMFRAMES'))
base = datadir + '/' + datatype

initfiles = []

for r in range (1,numframes+1):
    initfiles.append(base + "-" + str(r) + ".vtk")

vtkreaders = LegacyVTKReader(FileNames=initfiles)


view = CreateRenderView()

reader0Display = Show(vtkreaders, view)


animationScene = GetAnimationScene()
animationScene.UpdateAnimationUsingDataTimeSteps()


#Reset camera so that axes line up through center of animation figure
view.ResetCamera()
#Create the camera for the view, set view angle for the zoom selection
camera = view.GetActiveCamera()
camera.SetViewAngle(80)

#Group datasets for further manipulation, such as color or other filters
#Group = GroupDatasets(Input=vtkreaders)
#Group_Display = Show(Group, view)

#Change Color red = [1.0, 0.0392156862745098, 0.1803921568627451]
#Group_Display.DiffuseColor = [0.4235294117647059, 1.0, 0.984313725490196]

#Change horizontal (theta) and vertical (phi) camera positions with command line options 
camera.Roll(int(os.environ.get("HORIZ_CAM")))
camera.Elevation(int(os.environ.get("VERT_CAM"))) #Needs to be negative in here so user can input +




RenderAllViews()

jpgdir = str(os.environ.get('JPGDIR'))

SaveAnimation(jpgdir + '/' + datatype + '.jpg', view, ImageResolution=[843, 570],FrameWindow=[0, numframes-1])





