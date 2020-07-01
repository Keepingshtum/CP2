'Draws the Springboard
function ShowDetailsView(content as Object, index as Integer) as Object
    m.details = CreateObject("roSGNode", "DetailsView")
    m.details.SetFields({
        content: content
        jumpToItem: index
    })
    m.details.ObserveField("itemLoaded", "OnDetailsItemLoaded") 'Comment out if not using prebuffering
    m.details.ObserveField("currentItem","OnDetailsContentSet")
    m.details.ObserveField("buttonSelected", "OnButtonSelected")
    m.top.ComponentController.CallFunc("show", {
        view: m.details
    })
    m.details.theme = {
    OverhangoptionsText: "Search and Options"
    }
    return m.details
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
'comment out if not using prebuffering
sub OnDetailsItemLoaded()
    ' create a media view so we can start preloading content
    ' we won't show this view until the user selects the "Play" button on the DetailsView
    m.video = CreateObject("roSGNode", "MediaView")
    m.video.ObserveFieldScoped("wasClosed", "OnVideoWasClosed")
    ' we'll use this observer to print the state of the MediaView to the console
    ' this let's us see when prebuffering starts
    m.video.ObserveField("state", "OnVideoState")

    ' preloading also works while endcards are displayed
    m.video.alwaysShowEndcards = true

    m.video.content = m.details.content
    m.video.jumpToItem = m.details.itemFocused

    ' turn on preloading
    ' it's off by default for backward compatibility
    m.video.preloadContent = true
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())

    if selectedButton.id = "play"
         'OpenVideoView(details.content, details.itemFocused) '- Non Prebuffer way (Uncomment if you want to support older devices)
        m.video.control = "play"
        m.top.ComponentController.CallFunc("show", {
        view: m.video
    })
    else if selectedButton.id = "episodes"
        if details.currentItem.seasons <> invalid then
            ShowEpisodePickerView(details.currentItem.seasons)
        end if
    else
        ' handle all other button presses
    end if
end sub
'comment this out if not using prebuffering
sub OnVideoState(event)
  ? "OnVideoState " + m.video.state
end sub
'comment this out if not using prebuffering
sub OnVideoWasClosed()
    m.video = invalid ' clear played video node
    OnDetailsItemLoaded() ' start buffering new one
end sub