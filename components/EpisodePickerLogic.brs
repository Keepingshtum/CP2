function ShowEpisodePickerView(seasonContent = invalid as Object) as Object
    ' Create an CategoryListView object and set the posterShape field
    episodePicker = CreateObject("roSGNode", "CategoryListView")
    episodePicker.posterShape = "16x9"
    content = CreateObject("roSGNode", "ContentNode")
    ' This gets the seasonContent we parsed out in GridHandler
    content.AddFields({
        HandlerConfigCategoryList: {
            name: "SeasonsHandler"
            fields : { seasons: seasonContent }
        }
    })
    episodePicker.content = content
    episodePicker.ObserveField("selectedItem", "OnEpisodeSelected")
    ' This will show the CategoryListView to the View and call SeasonsHandler
    m.top.ComponentController.CallFunc("show", {
        view: episodePicker
    })
    episodePicker.theme = {
    OverhangoptionsText: "Search and Options"
    }
    return episodePicker
end function

sub OnEpisodeSelected(event as Object)
    ' GetRoSGNode returns the object that was being observed
    categoryList = event.GetRoSGNode()
    ' GetData returns the field that was being observed
    itemSelected = event.GetData()
    category = categoryList.content.GetChild(itemSelected[0])
    detailsView = ShowDetailsView(category, itemSelected[1])
end sub
