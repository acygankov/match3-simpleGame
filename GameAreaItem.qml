import QtQuick 2.12
import QtQuick.Particles 2.12
import QtGraphicalEffects 1.12

Item {
    id: root

    property int gridSize: 1
    property int itemGridIndex: -1

    property bool isItemActive: !parent.isActionsLocked
    property bool isDropActive: false
    property bool isSwapActive: false
    property bool isChosen: false
    property bool isBindingYActive: false

    //Type to imageFile map
    readonly property variant itemImagesMap: {
        'red': 'images/res/red.png',
        'green' : 'images/res/green.png',
        'blue': 'images/res/blue.png',
        'yellow' : 'images/res/yellow.png',
        'purple': 'images/res/purple.png',
        'cyan' : 'images/res/cyan.png',
    }

    //Calculated item xPos for item in grid by index
    function getItemXPos(itemIndex, areaGridSize, areaMinSideSize) {
        if (itemIndex >= areaGridSize * areaGridSize)
            return 0
        return (areaMinSideSize / areaGridSize) * Math.floor(itemIndex / areaGridSize)
    }

    //Calculated item yPos for item in grid by index
    function getItemYPos(itemIndex, areaGridSize, areaMinSideSize) {
        if (itemIndex >= areaGridSize * areaGridSize)
            return 0
        return (areaMinSideSize / areaGridSize) * (itemIndex % areaGridSize)
    }

    //Passing itemType to itemElement
    function setItemType(type) {
        itemImage.source = itemImagesMap[type]
    }

    //Swap items method
    function destroyItem() {
        destroyAnimation.start()
        particles.burst(50)
    }

    //Swap items method
    function swapItem(asMain, newIndex) {
        isDropActive = false
        isSwapActive = true
        isBindingYActive = true
        swapYAnimation.from = parent.y + getItemYPos(itemGridIndex, gridSize, parent.minSideSize)
        swapYAnimation.to = parent.y + getItemYPos(newIndex, gridSize, parent.minSideSize)
        swapYAnimation.start()
        if(asMain) {
            z = 1
            swapMainAnimation.start()
        }
    }

    //Swap completed signal handler
    function swapCompleted(isMain) {
        isSwapActive = false
        isDropActive = true
        z = 0
        isBindingYActive = true
        if(isMain)
            parent.onItemSwapCompleted(itemGridIndex)
    }

    //Click signal passing
    function sendClickIndex() {
        parent.onAreaItemClicked(itemGridIndex)
    }

    //Calculated grid cell size
    width: parent.minSideSize / gridSize
    height: parent.minSideSize / gridSize

    //Binding xPos in grid
    x: parent.x + getItemXPos(itemGridIndex, gridSize, parent.minSideSize)
    //Start y coord out of screen
    y: parent.y - (height * 0.8)

    //Binding yPos in grid
    Binding on y {
        when: isBindingYActive
        value: parent.parent.y + getItemYPos(itemGridIndex, gridSize, parent.minSideSize)
    }

    //Drop and spawn animaton
    Behavior on y {
        enabled: isDropActive
        SpringAnimation { spring: 1; damping: 0.3 }

    }

    //Swap animatons
    Behavior on x {
        enabled: isSwapActive
        NumberAnimation {
            duration: 350
        }
    }

    NumberAnimation {
        id: swapYAnimation
        target: root
        property: "y"
        duration: 350
        onRunningChanged: {
            if(!swapYAnimation.running)
                swapCompleted(false)
        }
    }

    SequentialAnimation
    {
        id: swapMainAnimation
        NumberAnimation {
            target: root;
            property: "scale";
            to: 1.2
            duration: 500
        }
        NumberAnimation {
            target: root;
            property: "scale";
            to: 1
            duration: 300
        }
        ScriptAction {
            script: swapCompleted(true)

        }
    }

    //Destroy animaton
    Behavior on opacity{ NumberAnimation { duration: 300 } }

    SequentialAnimation
    {
        id: destroyAnimation
        ScriptAction {
            script: root.opacity = 0
        }
        NumberAnimation {
            target: root;
            property: "scale";
            to: 1.5
            duration: 800
        }
        ScriptAction {
            script:  {
                root.destroy()
            }
        }
    }

    ParticleSystem {
        id: itemParticle
        anchors.centerIn: parent
        ImageParticle {
            source: itemImage.source
            rotationVelocityVariation: 180
        }

        Emitter {
            id: particles
            anchors.centerIn: parent
            emitRate: 0
            lifeSpan: 1000
            velocity: AngleDirection {angleVariation: 180; magnitude: itemRect.width * 1.6; magnitudeVariation: itemRect.width * 1.2}
            size: 16
        }
    }

    //Choose animation
    SequentialAnimation {
        id: chosenAnimation
        NumberAnimation {
            target: root
            property: "y"
            duration: 1000
            easing.type: Easing.OutQuad
            from: root.parent.y + getItemYPos(itemGridIndex, gridSize, parent.minSideSize)
            to: root.parent.y + getItemYPos(itemGridIndex, gridSize, parent.minSideSize) - (root.width / 10)
        }

        NumberAnimation {
            target: root
            property: "y"
            duration: 1500
            easing.type: Easing.OutBounce
            easing.amplitude: 1.5
            from: root.parent.y + getItemYPos(itemGridIndex, gridSize, parent.minSideSize) - (root.width / 10)
            to: root.parent.y + getItemYPos(itemGridIndex, gridSize, parent.minSideSize)
        }
        loops: Animation.Infinite
    }

    onIsChosenChanged: {
        if(isChosen) {
            isBindingYActive = false
            chosenAnimation.start()
        }
        else {
            chosenAnimation.stop()
            isBindingYActive = true
        }
    }

    //AreaItemRectangle
    Rectangle {
        id: itemRect
        anchors.fill: parent
        color: "#00000000"

        //CropCircleRectagle
        Rectangle {
            id: cropImageRect
            width: parent.width * 0.8
            height: parent.height * 0.8
            radius: width / 2
            anchors.centerIn: parent
            clip: true
            color: "#00000000"
            MouseArea {
                anchors.fill: parent
                onClicked:  {
                    if(isItemActive)
                        sendClickIndex()
                }
            }

            //ItemCircleImage
            Image {
                id:itemImage
                width: parent.width
                height: parent.height
                anchors.centerIn: parent

                fillMode: Image.PreserveAspectFit
                mipmap: true
            }
        }
    }
}
