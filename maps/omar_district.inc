#if defined _OMAR_DISTRICT_INCLUDED
    #endinput
#endif
#define _OMAR_DISTRICT_INCLUDED

stock LoadOmarDistrict()
{
    // Initial lightweight mapping near Ganton / Grove Street.
    // Coordinates and collision must be verified in a live client.
    CreateObject(1232, 2487.0, -1685.0, 13.5, 0.0, 0.0, 0.0);
    CreateObject(1232, 2500.0, -1685.0, 13.5, 0.0, 0.0, 0.0);
    CreateObject(1280, 2491.0, -1682.0, 13.0, 0.0, 0.0, 90.0);
    CreateObject(1280, 2497.0, -1682.0, 13.0, 0.0, 0.0, 90.0);
    return 1;
}
