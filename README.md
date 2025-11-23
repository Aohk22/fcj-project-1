Push on 'dev' branch first.

## Summary

![](high-level-view-2.drawio.png)

1. User sends analysis request for file.
2. Web Server sends request to Query Service. (Query using file hash)
3. Query Service communicates with Database.
4. Database responds to Query Service.
5. Query Service responds to Web Server.
6. If query successful send HTML response to User.
7. If not then send file to Processing Service. (Web Server should hold raw file data)
8. Processing Service sends report back to Web Server.
9. Also stores report in Database.
10. Database syncs.

## Diagram for AWS

![](high-level-view.drawio.png)

**To do**

- Fix terraform due to branch change.
