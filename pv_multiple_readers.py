#!/usr/bin/python

import os
import sys
from paraview.simple import *

datadir = str(os.environ.get('MOVIEDIR'))
datatype = str(os.environ.get('DATATYPE'))
numframes = int(os.environ.get('NUMFRAMES'))
numnodes = int(os.environ.get('REAL_NUMNODES'))

base = datadir + '/' + datatype
#Create vtkreaders list
vtkreaders = [[] for vtkreader in range (numnodes)]
#Create each reader for each respective node
readers = [[] for reader in range (numnodes)]
#Create multiple lists for the files on each node
initfiles = [[] for filelist in range (numnodes)]

#Create files
for vtkreader in range (0,numnodes): 
    #set nd%04
    for r in range (1,numframes+1):
         initfiles[vtkreader].append(base + "nd000" + str(vtkreader) + "-" + str(r) + ".vtk")
#Use LegacyVTKReader to read files
for vtkreader in range (0,numnodes):
   vtkreaders[vtkreader] = LegacyVTKReader(FileNames=initfiles[vtkreader])

#Create view for showing readers and for saving animation
view = CreateRenderView()

#Show each reader in the specified view, render each one
for reader in range (0,numnodes):
    readers[reader] = Show(vtkreaders[reader], view)
    Render()

#Create animation scene before camera manipulation
animationScene = GetAnimationScene() 
animationScene.UpdateAnimationUsingDataTimeSteps()

#Reset camera so that axes line up through center of animation figure
view.ResetCamera()
#Create the camera for the view, set view angle for the zoom selection
camera = view.GetActiveCamera()
#TODO: Make command line argument
camera.SetViewAngle(80)

#Group datasets for further manipulation, such as color or other filters
Group = GroupDatasets(Input=vtkreaders)
Group_Display = Show(Group, view)

#Change Color red = [1.0, 0.0392156862745098, 0.1803921568627451]
Group_Display.DiffuseColor = [0.4235294117647059, 1.0, 0.984313725490196]

#Change horizontal (theta) and vertical (phi) camera positions with command line options 
camera.Roll(int(os.environ.get("HORIZ_CAM")))
camera.Elevation(int(os.environ.get("VERT_CAM"))) #Needs to be negative in here so user can input +

RenderAllViews()
#Create .jpg directory
jpgdir = str(os.environ.get('JPGDIR'))
#Save animation with the specified view and frames
SaveAnimation(jpgdir + '/' + datatype + '.jpg', view, ImageResolution=[843, 570], FrameWindow=[0, numframes-1])
