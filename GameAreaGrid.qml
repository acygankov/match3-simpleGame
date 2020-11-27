import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
    id: root

    property var areaItemsList: []
    property var itemActionsQueueList: []
    property int minSideSize: (width > height) ? height : width

    property int selectedIndex: -1

    property bool isActionsLocked: false
    property bool isGameOver: false

    property var areaItemComponent: Qt.createComponent("GameAreaItem.qml")

    function createAreaItem(itemIndex) {
        var itemObject = areaItemComponent.createObject(root)
        itemObject.isDropActive = true
        itemObject.gridSize = gameAreaModel.dimension
        itemObject.itemGridIndex = itemIndex
        itemObject.setItemType(gameAreaModel.getItemType(itemIndex));
        itemObject.isBindingYActive = true
        return itemObject
    }

    //Create and init item objects list
    function initItemsList() {
        if(areaItemsList.length > 0)
            destroyItemsList()
        for (var i = 0; i < gameAreaModel.dimension * gameAreaModel.dimension; i++) {
            areaItemsList[i] = createAreaItem(i)
        }
    }


    //Delete and free item objects
    function destroyItemsList() {
        for (var i = 0; i < areaItemsList.length; i++) {
            areaItemsList[i].destroy()
        }
    }

    function onItemMovedOrAdded() {

    }

    //Process item actions queue
    function processActionQueue() {
        while(itemActionsQueueList.length >= 3) {
            var currentAction = itemActionsQueueList.slice(0, 3)
            itemActionsQueueList = itemActionsQueueList.slice(3)
            switch(currentAction[0]) {
            case 'swap':
                swapItems(currentAction[1], currentAction[2])
                return;
            case 'remove':
                areaItemsList[currentAction[1]].destroyItem()
                break;
            case 'move':
                areaItemsList[currentAction[1]] = areaItemsList[currentAction[2]]
                areaItemsList[currentAction[1]].isDropActive = true
                areaItemsList[currentAction[1]].itemGridIndex = currentAction[1]
                break;
            case 'add':
                areaItemsList[currentAction[1]] = createAreaItem(currentAction[1])
                areaItemsList[currentAction[1]].setItemType(currentAction[2])
                break;
            default:
                break;
            }
        }
        if(!gameAreaModel.checkMoveIsAvailable()) {
            isGameOver = true
            isActionsLocked = true
        }
        else {
            isActionsLocked = false
        }
    }

    //Swap items function in items list
    function swapItems(mainItemIndex, secondItemIndex) {
        areaItemsList[mainItemIndex].swapItem(true, secondItemIndex)
        areaItemsList[secondItemIndex].swapItem(false, mainItemIndex)

        var mainItem = areaItemsList[mainItemIndex]
        var secondItem = areaItemsList[secondItemIndex]

        areaItemsList[mainItemIndex] = secondItem
        areaItemsList[secondItemIndex] = mainItem

        mainItem.itemGridIndex = secondItemIndex
        secondItem.itemGridIndex = mainItemIndex
    }

    //Process item actions queue after swap
    function onItemSwapCompleted(itemIndex) {
        processActionQueue()
    }

    //Item click and swap logic
    function onAreaItemClicked(itemIndex) {
        if(selectedIndex === -1) {
            areaItemsList[itemIndex].isChosen = true
            selectedIndex = itemIndex
            return
        }

        if(selectedIndex === itemIndex) {
            areaItemsList[itemIndex].isChosen = false
            selectedIndex = -1
            return
        }

        areaItemsList[selectedIndex].isChosen = false
        if(gameAreaModel.canItemSwaps(selectedIndex, itemIndex)) {
            swapItems(selectedIndex, itemIndex)
            var swapResult = gameAreaModel.trySwapItems(selectedIndex, itemIndex)
            if(swapResult.length === 0) {
                itemActionsQueueList.push('swap')
                itemActionsQueueList.push(selectedIndex)
                itemActionsQueueList.push(itemIndex)
            }
            else {
                itemActionsQueueList = swapResult
            }
            isActionsLocked = true
        }
        selectedIndex = -1
    }

    Component.onCompleted: {
        initItemsList();
    }
}
