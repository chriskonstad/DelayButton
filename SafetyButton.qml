import QtQuick 2.0

Rectangle {
    id: page
    width: 360
    height: 180
    color: "#5c5c5c"
    border.color: "#5c5c5c"

    Rectangle {
        id: button
        width: page.width/2
        height: page.height/2
        color: backgroundColor
        radius: height/10;
        border.color: backgroundBorderColor;
        border.width: height/15;
        anchors.centerIn: page;

        //Public API
        property bool isChecked: progressBar.done;
        property bool allowInstantUncheck: false;
        property double timeToComplete: 500;
        property color progressColorAnimation: "#2A82DA";
        property color progressColorDone: "green";
        property color backgroundColor: "#353535";
        property color backgroundBorderColor: "white";

        //Public signals
        signal clicked;
        signal pressed;
        signal released;

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            onPressed: {
                progressBar.onButtonDown();
                button.pressed();
            }

            onReleased: {
                progressBar.onButtonUp();
                button.released();
            }
        }

        Rectangle {
            id: progressBar
            width: (button.width - 2*parent.border.width) * percentage;
            color: button.progressColorAnimation;
            radius: button.radius/2;
            anchors.margins: parent.border.width;
            anchors.left: parent.left
            anchors.top: parent.top;
            anchors.bottom: parent.bottom;

            property double percentage: 0;
            property double lineThickness: height/100;
            property double animationInterval: 10;
            property bool done: false;
            property bool lastStatus: false;
            property double fillRatio: animationInterval/(button.timeToComplete ? button.timeToComplete : animationInterval);

            Timer {
                id: timerDown
                interval: progressBar.animationInterval; running: false; repeat: true;
                onTriggered:{
                    progressBar.setPercentage(progressBar.percentage + (progressBar.fillRatio));
                    if(progressBar.percentage >= 1) {
                        progressBar.percentage = 1;
                        progressBar.done = true;
                        timerDown.stop();
                    }
                }
            }

            Timer {
                id: timerUp
                interval: progressBar.animationInterval; running: false; repeat: true;
                onTriggered:{
                    progressBar.setPercentage(progressBar.percentage - (progressBar.fillRatio));
                    if(progressBar.percentage <= 0) {
                        progressBar.setPercentage(0);
                        progressBar.done = false;
                        timerUp.stop();
                    }
                }
            }

            function setPercentage(percent) {
                percentage = percent;
            }

            function onButtonDown() {
                if(!done) {
                    timerUp.stop();
                    timerDown.start();
                } else {
                    if(button.allowInstantUncheck) {
                        setPercentage(0);
                        done = false;
                    } else {
                        timerDown.stop();
                        timerUp.start();
                    }
                }
            }

            function onButtonUp() {
                if(!done) {
                    timerDown.stop();
                    timerUp.start();
                } else {
                    if(!button.allowInstantUncheck) {
                        timerUp.stop();
                        timerDown.start();
                    }
                }

                progressBar.color = done ? button.progressColorDone : button.progressColorAnimation;

                if(done != lastStatus) {
                    button.clicked();
                    console.log("clicked");
                    lastStatus = done;
                }
            }
        }
    }
}
