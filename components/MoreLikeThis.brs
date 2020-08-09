'Initialise Grid
sub ShowRecs()
    m.grid = CreateObject("roSGNode", "GridView")
    ?"test"
    ' setup UI of view
    m.grid.SetFields({
        style: "zoom"
        posterShape: "16x9"
    })
    m.grid.theme = {
        OverhangoptionsText: "Search and Options"

    }
    ' This is root content that describes how to populate rest of rows
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "MoreLikeThisHandler"
        }
    })
    m.grid.ObserveField("More_rowItemSelected", "OnMoreGridItemSelected")
    m.grid.content = content

    m.top.ComponentController.CallFunc("ShowRecs", {
        view: m.grid
    })
end sub

'Focus Handling
sub OnMoreGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(row, selectedIndex[1])
end sub

function onMoreKeyEvent(key, press) as Boolean
	if key = "options" and press
    OpenSearch()
    end if
end function
