# geofence

A Simple Flutter project that track user location is within a Geofence and connected Wifi.

## Important Information
- Main status : INSIDE | OUTSIDE
    - If the user still connected with the specific wifi, status will consider INSIDE.
    - If the user still connected with the specific wifi, status will consider OUTSIDE.

- Secondary status : IN THE ZONE | NOT IN THE ZONE
    - If the user location is within the radius of generated circle on the map, status will consider IN THE ZONE.
    - If the user location is outside the radius of generated circle on the map, status will consider NOT IN THE ZONE.

## Getting Started
Home Screen
- Getting location permission from user before proceeding to next page.
** User must allow the permission in order to proceed.

Map Screen
- Tap on map to generate a Circle with default radius 100m.
- Use the FloatActionButton to change the radius (m).
- Use the Setting icon at top right to change the Specific wifi name.

