import QtQuick 2.0

Rectangle {
    id: page
    width: 360
    height: 360

    Rectangle {
        id: buttonBase
        x: 80
        y: 80
        width: 200
        height: 200

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            onPressed: {
                //Ignore button presses outside of the circle
                var x = mouseX - width/2;
                var y = mouseY - height/2;
                var radius = Math.sqrt(x*x + y*y);
                if(radius <= canvas.radiusButton) {
                    canvas.onButtonDown();
                }
            }

            onReleased: {
                //Ignore button presses outside of the circle
                var x = mouseX - width/2;
                var y = mouseY - height/2;
                var radius = Math.sqrt(x*x + y*y);
                if(radius <= canvas.radiusButton) {
                    canvas.onButtonUp();
                }
            }
        }

        Canvas {
            id: canvas
            width: buttonBase.width
            height: buttonBase.height
            antialiasing: true;

            property double arcAngle: Math.PI/2;
            property double lineThickness: 10;
            property double animationInterval: 10;
            property bool done: false;
            property double fillRatio: animationInterval/timeToComplete;
            property double radiusButton: -2*lineThickness + canvas.width/2

            //PUBLIC API
            property bool checked: done;
            property double timeToComplete: 1000;
            property color background: "#6E6E6E"
            property color checkedBackground: "#353535"
            property color arcColor: "#2A82DA"

            Timer {
                id: timerDown
                interval: canvas.animationInterval; running: false; repeat: true;
                onTriggered:{
                    canvas.setAngle(canvas.arcAngle + (canvas.fillRatio*2*Math.PI));
                    if(canvas.arcAngle >= Math.PI/2 + 2*Math.PI) {
                        canvas.done = true;
                        timerDown.stop();
                    }
                }
            }

            Timer {
                id: timerUp
                interval: canvas.animationInterval; running: false; repeat: true;
                onTriggered:{
                    canvas.setAngle(canvas.arcAngle - (canvas.fillRatio*2*Math.PI));
                    if(canvas.arcAngle <= Math.PI/2) {
                        canvas.setAngle(Math.PI/2);
                        canvas.done = false;
                        timerUp.stop();
                    }
                }
            }

            function setAngle(angle) {
                arcAngle = angle;
                canvas.requestPaint();
            }

            function onButtonDown() {
                if(!done) {
                    timerUp.stop();
                    timerDown.start();
                } else {
                    canvas.setAngle(Math.PI/2);
                    canvas.done = false;
                }
            }

            function onButtonUp() {
                if(!done) {
                    timerDown.stop();
                    timerUp.start();
                }
            }

            function drawButtonBase() {
                var ctxCircle = canvas.getContext('2d');
                ctxCircle.beginPath();
                ctxCircle.arc(canvas.x+(canvas.width/2), canvas.y+(canvas.height/2), radiusButton, 0, 2*Math.PI);
                ctxCircle.fillStyle = !done ? background : checkedBackground;
                ctxCircle.fill();
            }

            function drawArc(targetAngle) {
                var ctx = canvas.getContext('2d');
                ctx.beginPath();
                ctx.strokeStyle=arcColor;
                ctx.lineWidth=10;
                ctx.arc(canvas.x+(canvas.width/2),canvas.y+(canvas.height/2),radiusButton + lineThickness/2,Math.PI/2,targetAngle);
                ctx.stroke();
                //console.log("Repainted arc");
            }

            function clearDrawing() {
                var ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);
            }

            onPaint: {
                clearDrawing();
                drawButtonBase();
                drawArc(arcAngle);
            }
        }
    }

}
