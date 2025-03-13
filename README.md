# OpenCascade Inspector

OpenCascade Inspector is a Qt-based library that provides functionality to interactively inspect low-level content of the OCAF data model, OCCT viewer and Modeling Data. This component is aimed to assist the developers of OCCT-based applications to debug the problematic situations that occur in their applications.

## Overview

Inspector has a plugin-oriented architecture with the following plugins:

| Plugin | OCCT component | Root class of investigated component |
| :----- | :----- | :----- |
| DFBrowser | OCAF | TDocStd_Application |
| VInspector | Visualization | AIS_InteractiveContext |
| ShapeView | Modeling Data | TopoDS_Shape |
| MessageView | Modeling Data | Message_Report |

Each plugin implements logic for a corresponding OCCT component and is embedded in a common framework, allowing you to manage which plugins are loaded and to extend their number by implementing new plugins.

## Getting Started

There are two ways to launch the Inspector:

1. Launch **TInspectorEXE** executable sample
2. Launch DRAW Test Harness, load the INSPECTOR plugin, and use the *tinspector* command

```bash
pload INSPECTOR
tinspector
```

**Note**: Make sure that OCCT is compiled with *BUILD_Inspector* option ON if you don't see the Inspector library in your build directory.

## Using Inspector in a Custom Application

To use Inspector in your own application:

```cpp
#include <inspector/TInspector_Communicator.hxx>

// Create a global communicator instance
static TInspector_Communicator* MyTCommunicator;

void CreateInspector()
{
  NCollection_List<Handle(Standard_Transient)> aParameters;
  // Append parameters in the list

  if (!MyTCommunicator)
  {
    MyTCommunicator = new TInspector_Communicator();

    MyTCommunicator->RegisterPlugin("TKDFBrowser");
    MyTCommunicator->RegisterPlugin("TKVInspector");
    MyTCommunicator->RegisterPlugin("TKShapeView");
    MyTCommunicator->RegisterPlugin("TKMessageView");

    MyTCommunicator->Init(aParameters);
    MyTCommunicator->Activate("TKDFBrowser");
  }
  MyTCommunicator->SetVisible(true);
}
```

## Plugins

### DFBrowser
Visualizes the content of *TDocStd_Application* in a tree view, showing application documents, the hierarchy of *TDF_Labels*, the content of *TDF_Attributes* and interconnection between attributes.

### VInspector
Visualizes interactive objects displayed in *AIS_InteractiveContext* in a tree view with computed selection components for each presentation.

### ShapeView
Visualizes content of *TopoDS_Shape* in a tree view, allowing exploration of shape hierarchy.

### MessageView
Displays content of Message_Report, showing alerts and metrics.

## Building

To build the Inspector:

### Configure OCCT with CMake:

Required 3rd-party libraries:
- Qt5
- FreeType
- Tcl
- OpenCascade

For example, to configure OCCT with CMake:

```bash
mkdir build
cd build
cmake -D3RDPARTY_QT_DIR=/path/to/Qt5 -D3RDPARTY_FREETYPE_DIR=/path/to/FreeType -D3RDPARTY_TCL_DIR=/path/to/Tcl -DOpenCASCADE_DIR=/path/to/OpenCascade /path/to/occt ..
cmake --build .
```

In case if QT, FreeType, Tcl, and OpenCascade are installed in the system, you can skip specifying the corresponding directories.

## License

Inspector is part of OpenCascade Technology and is released under the LGPL 2.1 license with the Open CASCADE exception. See the LICENSE file for details.
