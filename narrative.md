## Jan 2nd
Configuring shared remote postgres instance

```
# Install
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib

# switch to default user
sudo -i -u postgres
```

## Jan 2nd
parallelizing scrapers
- redis queue
  - research phase
  - initialize the queue
  - json data structure
- shared postgres database

Next Actions:
- Mod scraper to get the commit data from a page for the current day and write to a shared database
- Make sure long running the scraper doesn't get blacklisted
- The same redis queue

## Dec 29th
Running tests. See throttle spreadsheet in google drive. Max requests is somewhere between 900 - 1350 an hour

## Dec 28th
Testing HTTP requests and creating estimate for requests needed. Trying to come up with requests allowed per hour from a single IP. The requests we need to gather commit data is really only a function of the amount of gems.

requests_per_day = gems * polls_per_day + C | ex. rph = 100 * 1 hr + 100 users

Of course, there is other requests to consider if we want to scrape user data. 

## Dec 27th
Adding Commit table and logging so we can benchmark our requests. Added logging to rake tasks and installed httplog to benchmark request speeds and amounts. Adding reporter to parse requests logs.

## Dec 27th 
We decided that in order to scale in an interesting way we need to harvest data in as near real time as possible. The only meaninful data that is often updated is commits. The project has three major processes:
1. Scrape Ruby Gems
2. Scrape Users
3. Poll commits to track 'user of the day'

Bottleneck is number of requests per hour allowed by Github. If we can push that up we can get closer to real time data extraction.

## Dec 27th
Adding contributors count for each gem so we can estimate number of requests needed every polling period.

## Dec 27th
Hitting Github 300 times continuously results in a 429 (too many requests). If we can do a request a second then we are making 60 requests a minute or 3600 an hour. Somewhere in this ballpark. This is a major problem. How can we get around this?

## Dec 27th
Problem with scraper. 94,000 duplicates of temparature gem. Was considering running ruby gems scraper massively in parrallel. Realized--duh--ruby gems provides the top 100 gems to us. Created scraper for top 100 gems path. This should speed up iteration speed and debugging. 

## Dec 27th
Running into 429 issues. Concerned about number of requests needed to make project successful.