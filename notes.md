milestones1. exploration- find github crawler dumps / find a crawler and run it
- build a database of Ruby gems and their Github repo URLs, based on some criteria2. from the result of Github crawl, capture data
 - ruby gem name
 - description (used for search)3.  search
 - build a web app
 - keywords in the input box
 - a list of repositories with highlighted keywords
 - elastic search (mostly use it to establish indexes)4. a simple ranking algorithm
 - stars
 - number of downloads5. score for developers
 - followers6. advanced ranking algorithm
 - inclusion in other projects
 - developers that contributed to the project
 - developers that include the project

# Models
gem -> 
  url:
  downloads:
  name:

# Developer
dev ->
 username 