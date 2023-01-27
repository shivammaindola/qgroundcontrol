/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtQuick.Dialogs  1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

QGCPopupDialog {
    id:         root
    title:      qsTr("Edit Position")
    buttons:    mainWindow.showDialogDefaultWidth, StandardButton.Close

    property alias coordinate: controller.coordinate

    property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
    property real   _fieldWidth:    ScreenTools.defaultFontPixelWidth * 10.5

    EditPositionDialogController {
        id: controller

        Component.onCompleted: initValues()
    }

    Column {
        id:         column
        width:      40 * ScreenTools.defaultFontPixelWidth
        spacing:    ScreenTools.defaultFontPixelHeight

        property var cityCoordinates: [
              { city: "Havana", latitude: 23.1135, longitude: -82.3666 },
              { city: "Cairo", latitude: 30.0571, longitude: 31.2272 },
              { city: "Rabat", latitude: 34.0132, longitude: -6.8325 },
              { city: "Tehran", latitude: 35.6961, longitude: 51.4231 },
              { city: "Tunis", latitude: 36.8028, longitude: 10.1797 },
              { city: "Damascus", latitude: 33.5158, longitude: 36.2939 },
              { city: "Dakar", latitude: 14.6937, longitude: -17.4440 },
              { city: "Managua", latitude: 12.1508, longitude: -86.2683 }
          ]

          function isClose(lat1, lon1) {
              var R = 6371;
              for (var i = 0; i < cityCoordinates.length; i++) {
                  var lat2 = cityCoordinates[i].latitude;
                  var lon2 = cityCoordinates[i].longitude;
                  var dLat = (lat2 - lat1) * (Math.PI / 180);
                  var dLon = (lon2 - lon1) * (Math.PI / 180);
                  var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                      Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
                      Math.sin(dLon / 2) * Math.sin(dLon / 2);
                  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                  var d = R * c;
                  if (d < 100) {
                      console.log("within 100km of " + cityCoordinates[i].city);
                      return true;
                  }
              }
              console.log("not within 100km of any city");
              return false;
          }


        GridLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            columnSpacing:  _margin
            rowSpacing:     _margin
            columns:        2

            QGCLabel {
                text: qsTr("Latitude")
            }
            FactTextField {
                fact:               controller.latitude
                Layout.fillWidth:   true
            }

            QGCLabel {
                text: qsTr("Longitude")
            }
            FactTextField {
                fact:               controller.longitude
                Layout.fillWidth:   true
            }

            QGCButton {
                text:               qsTr("Set Geographic")
                Layout.alignment:   Qt.AlignRight
                Layout.columnSpan:  2
                onClicked: {
                    console.log("locations: "+controller.latitude.value+ ", "+controller.longitude.value)
                    var result = column.isClose(controller.latitude.value, controller.longitude.value);
                                   console.log(result);

                    if(!result){
                    controller.setFromGeo()
                    root.close()
                    }
                    else{
                        clearDialog.open()
                    }
                }
                MessageDialog {
                    id: clearDialog
                    visible: false

                    icon: StandardIcon.Warning
                    standardButtons: StandardButton.Yes
                    title: qsTr("Restriction")
                    text: qsTr("Drone cannot fly in this area.")
                    onYes: {
                        clearDialog.visible = false
                    }
                }
            }

            Item { width: 1; height: ScreenTools.defaultFontPixelHeight; Layout.columnSpan: 2}

            QGCLabel {
                text: qsTr("Zone")
            }
            FactTextField {
                fact:               controller.zone
                Layout.fillWidth:   true
            }

            QGCLabel {
                text: qsTr("Hemisphere")
            }
            FactComboBox {
                fact:               controller.hemisphere
                indexModel:         false
                Layout.fillWidth:   true
            }

            QGCLabel {
                text: qsTr("Easting")
            }
            FactTextField {
                fact:               controller.easting
                Layout.fillWidth:   true
            }

            QGCLabel {
                text: qsTr("Northing")
            }
            FactTextField {
                fact:               controller.northing
                Layout.fillWidth:   true
            }

            QGCButton {
                text:               qsTr("Set UTM")
                Layout.alignment:   Qt.AlignRight
                Layout.columnSpan:  2
                onClicked: {
                    controller.setFromUTM()
                    root.close()
                }
            }

            Item { width: 1; height: ScreenTools.defaultFontPixelHeight; Layout.columnSpan: 2}

            QGCLabel {
                text:              qsTr("MGRS")
            }
            FactTextField {
                fact:              controller.mgrs
                Layout.fillWidth:  true
            }

            QGCButton {
                text:              qsTr("Set MGRS")
                Layout.alignment:  Qt.AlignRight
                Layout.columnSpan: 2
                onClicked: {
                    controller.setFromMGRS()
                    root.close()
                }
            }

            Item { width: 1; height: ScreenTools.defaultFontPixelHeight; Layout.columnSpan: 2}

            QGCButton {
                text:              qsTr("Set From Vehicle Position")
                visible:           QGroundControl.multiVehicleManager.activeVehicle && QGroundControl.multiVehicleManager.activeVehicle.coordinate.isValid
                Layout.alignment:  Qt.AlignRight
                Layout.columnSpan: 2
                onClicked: {
                    controller.setFromVehicle()
                    root.close()
                }
            }
        }
    }
}
