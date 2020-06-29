'Draws the Springboard
function ShowDetailsView(content as Object, index as Integer) as Object
    details = CreateObject("roSGNode", "DetailsView")
    details.SetFields({
        content: content
        jumpToItem: index
    })
    details.ObserveField("currentItem","OnDetailsContentSet")
    details.ObserveField("buttonSelected", "OnButtonSelected")
    m.top.ComponentController.CallFunc("show", {
        view: details
    })
    details.theme = {
    OverhangoptionsText: "Search and Options"
    }
    return details
end function
'Handle User Interaction on Springboard
sub OnDetailsContentSet(event as Object)
    details = event.GetRoSGNode()
    currentItem = event.GetData()
    if currentItem <> invalid
        buttonsToCreate = []

        if currentItem.url <> invalid and currentItem.url <> ""
            buttonsToCreate.Push({ title: "Play", id: "play" })
        else if details.content.TITLE = "series"
            buttonsToCreate.Push({ title: "Episodes", id: "episodes" })
        end if

        if buttonsToCreate.Count() = 0
            buttonsToCreate.Push({ title: "No Content to play", id: "no_content" })
        end if
        btnsContent = CreateObject("roSGNode", "ContentNode")
        btnsContent.Update({ children: buttonsToCreate })
    end if
    details.buttons = btnsContent
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())

    if selectedButton.id = "play"
         OpenVideoView(details.content, details.itemFocused)
    else if selectedButton.id = "episodes"
        if details.currentItem.seasons <> invalid then
            ShowEpisodePickerView(details.currentItem.seasons)
        end if
    else
        ' handle all other button presses
    end if
end sub