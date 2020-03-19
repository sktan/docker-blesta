# Blesta Docker Container

This docker container is currently being used by Steven to test and develop features for the Blesta billing portal.

At this time, there are some quirks that need to be worked around:
- Updating the containers will make your license invalid, and you will need to reissue it
- You will need to mount volumes to include plugins, modules and gateways
- Cron jobs aren't running at this time

This container also relies on a reverse proxy being setup to forward traffic via HTTPS. This is to work around an issue where sometimes Blesta would not believe that it is running on HTTPS, generating HTTP URLs.
