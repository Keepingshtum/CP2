'Initialise Grid
sub Show(args as Object)
    m.grid = CreateObject("roSGNode", "GridView")
    'm.global.addField(hdPosterUrl,string,alwaysNotify=false)
    '?m.global is the global field, can be used to pass around some values or append values to it
    ' setup UI of view
    m.grid.SetFields({
        style: "zoom"
        posterShape: "16x9"
    })
    m.grid.theme = {
        OverhangoptionsText: "Search and Options"
        global: {
           
        }
    }
    ' This is root content that describes how to populate rest of rows
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    })
    m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")
    m.grid.content = content

    m.top.ComponentController.CallFunc("show", {
        view: m.grid
    })
    m.top.signalBeacon("AppLaunchComplete") ' Do this for app certification reasons
end sub

'Focus Handling
sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(row, selectedIndex[1])
end sub

function onKeyEvent(key, press) as Boolean
	if key = "options" and press
    OpenSearch("")
    end if
end function
